const { Storage } = require('@google-cloud/storage');
const storage = new Storage();
const crypto = require("node:crypto");
const admin = require("firebase-admin");
const functions = require("firebase-functions");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

admin.initializeApp();

const db = admin.firestore();
const REGION = "europe-central2";
const CODE_TTL_MINUTES = 10;
const MAX_ATTEMPTS = 5;
const MAIL_COLLECTION = "mail";

function generateCode() {
	return Math.floor(1000 + Math.random() * 9000).toString();
}

function hashCode(code) {
	return crypto.createHash("sha256").update(code).digest("hex");
}

function safeEqual(a, b) {
	const aBuffer = Buffer.from(a, "utf8");
	const bBuffer = Buffer.from(b, "utf8");

	if (aBuffer.length !== bBuffer.length) {
		return false;
	}

	return crypto.timingSafeEqual(aBuffer, bBuffer);
}

exports.sendEmailVerificationCode = onCall({ region: REGION }, async (request) => {
	const auth = request.auth;

	if (!auth?.uid) {
		throw new HttpsError("unauthenticated", "You must be signed in.");
	}

	const userRecord = await admin.auth().getUser(auth.uid);
	const email = userRecord.email;

	if (!email) {
		throw new HttpsError(
			"failed-precondition",
			"Your account does not have a valid email address.",
		);
	}

	const code = generateCode();
	const codeHash = hashCode(code);
	const expiresAt = admin.firestore.Timestamp.fromMillis(
		Date.now() + CODE_TTL_MINUTES * 60 * 1000,
	);

	await db.collection("email_verification_codes").doc(auth.uid).set({
		codeHash,
		email,
		attempts: 0,
		maxAttempts: MAX_ATTEMPTS,
		expiresAt,
		createdAt: admin.firestore.FieldValue.serverTimestamp(),
		updatedAt: admin.firestore.FieldValue.serverTimestamp(),
	});

	await db.collection(MAIL_COLLECTION).add({
		to: [email],
		message: {
			subject: "Your verification code",
			text: `Your verification code is ${code}. It expires in ${CODE_TTL_MINUTES} minutes.`,
			html: `<p>Your verification code is <strong>${code}</strong>.</p><p>It expires in ${CODE_TTL_MINUTES} minutes.</p>`,
		},
	});

	logger.info("Verification code sent", { uid: auth.uid });
	return { success: true };
});

exports.verifyEmailVerificationCode = onCall({ region: REGION }, async (request) => {
	const auth = request.auth;

	if (!auth?.uid) {
		throw new HttpsError("unauthenticated", "You must be signed in.");
	}

	const code = request.data?.code;

	if (typeof code !== "string" || !/^\d{4}$/.test(code)) {
		throw new HttpsError("invalid-argument", "Code must be exactly 4 digits.");
	}

	const codeRef = db.collection("email_verification_codes").doc(auth.uid);
	const codeSnap = await codeRef.get();

	if (!codeSnap.exists) {
		throw new HttpsError(
			"not-found",
			"No active verification code found. Please resend a new code.",
		);
	}

	const stored = codeSnap.data();
	const expiresAt = stored.expiresAt;
	const attempts = Number(stored.attempts || 0);
	const maxAttempts = Number(stored.maxAttempts || MAX_ATTEMPTS);

	if (!expiresAt || expiresAt.toMillis() < Date.now()) {
		await codeRef.delete();
		throw new HttpsError(
			"deadline-exceeded",
			"Your verification code has expired. Please request a new one.",
		);
	}

	if (attempts >= maxAttempts) {
		throw new HttpsError(
			"permission-denied",
			"Too many incorrect attempts. Please request a new verification code.",
		);
	}

	const submittedHash = hashCode(code);
	if (!safeEqual(submittedHash, stored.codeHash)) {
		await codeRef.set(
			{
				attempts: attempts + 1,
				updatedAt: admin.firestore.FieldValue.serverTimestamp(),
			},
			{ merge: true },
		);

		throw new HttpsError("invalid-argument", "The verification code is incorrect.");
	}

	await admin.auth().updateUser(auth.uid, { emailVerified: true });
	await codeRef.delete();

	logger.info("Email verified with code", { uid: auth.uid });
	return { success: true };
});

exports.uploadGroupAvatar = onCall({ region: REGION }, async (request) => {
	logger.info("uploadGroupAvatar called", { requestData: request.data });
	const auth = request.auth;
	logger.info("Auth info", { auth });
	const { chatId, filename, avatarBase64 } = request.data;

	if (!auth?.uid) {
		logger.info("No auth UID");
		throw new HttpsError("unauthenticated", "You must be signed in.");
	}
	if (!chatId || !filename || !avatarBase64) {
		logger.info("Missing parameters", { chatId, filename, avatarBase64 });
		throw new HttpsError("invalid-argument", "chatId, filename, and avatarBase64 are required.");
	}

	logger.info("Fetching group doc", { chatId });
	const groupDoc = await db.collection("groupChats").doc(chatId).get();
	logger.info("Group doc fetched", { exists: groupDoc.exists });
	if (!groupDoc.exists) {
		logger.info("Group chat not found", { chatId });
		throw new HttpsError("not-found", "Group chat not found.");
	}
	const groupData = groupDoc.data();
	logger.info("Group data", { groupData });
	if (groupData.ownerId !== auth.uid) {
		logger.info("User not owner", { ownerId: groupData.ownerId, uid: auth.uid });
		throw new HttpsError("permission-denied", "You are not the owner of this group.");
	}

	logger.info("Decoding avatar");
	const buffer = Buffer.from(avatarBase64, 'base64');
	const bucketName = admin.storage().bucket().name;
	const filePath = `avatars/groupChats/${chatId}/${filename}`;
	logger.info("Uploading to bucket", { bucketName, filePath });
	const file = storage.bucket(bucketName).file(filePath);

	await file.save(buffer, {
		contentType: 'image/jpeg', // or detect from filename
		public: true,
	});

	logger.info("Upload complete", { url: `https://storage.googleapis.com/${bucketName}/${filePath}` });
	return { success: true, url: `https://storage.googleapis.com/${bucketName}/${filePath}` };
});

exports.deleteGroupAvatar = onCall({ region: REGION }, async (request) => {
	logger.info("deleteGroupAvatar called", { requestData: request.data });
	const auth = request.auth;
	logger.info("Auth info", { auth });
	const { chatId, filename } = request.data;

	if (!auth?.uid) {
		logger.info("No auth UID");
		throw new HttpsError("unauthenticated", "You must be signed in.");
	}
	if (!chatId || !filename) {
		logger.info("Missing parameters", { chatId, filename });
		throw new HttpsError("invalid-argument", "chatId and filename are required.");
	}

	logger.info("Fetching group doc", { chatId });
	const groupDoc = await db.collection("groupChats").doc(chatId).get();
	logger.info("Group doc fetched", { exists: groupDoc.exists });
	if (!groupDoc.exists) {
		logger.info("Group chat not found", { chatId });
		throw new HttpsError("not-found", "Group chat not found.");
	}
	const groupData = groupDoc.data();
	logger.info("Group data", { groupData });
	if (groupData.ownerId !== auth.uid) {
		logger.info("User not owner", { ownerId: groupData.ownerId, uid: auth.uid });
		throw new HttpsError("permission-denied", "You are not the owner of this group.");
	}

	logger.info("Deleting avatar", { chatId, filename });
	const bucketName = admin.storage().bucket().name;
	const filePath = `avatars/groupChats/${chatId}/${filename}`;
	logger.info("Deleting from bucket", { bucketName, filePath });
	const file = storage.bucket(bucketName).file(filePath);

	await file.delete();

	logger.info("Delete complete", { chatId, filename });
	return { success: true };
});

const sendMessageNotification = async (change, context, chatType) => {
	const messageData = change.data();
	if (!messageData) return;

	const chatId = context.params.chatId;
	const senderId = messageData.senderId;
	let senderName = 'Someone';
	try {
		const senderDoc = await db.collection('users').doc(senderId).get();
		if (senderDoc.exists) {
			senderName = senderDoc.get('name') || senderName;
		}
	} catch (e) {
		logger.warn('Failed to fetch sender name', { senderId, error: e });
	}
	const notification = {
		title: `${senderName}`,
		body: messageData.body || messageData.text || 'You have a new message!',
	};
	const data = {
		type: 'message',
		route: chatType === 'group' ? `/chats/group/${chatId}` : `/chats/direct/${chatId}`,
		title: notification.title,
		body: notification.body,
	};

	if (chatType === 'direct') {
		const chatDoc = await db.collection('directChats').doc(chatId).get();
		if (!chatDoc.exists) return;
		const chat = chatDoc.data();
		const participants = chat.participants || [];
		const recipientId = participants.find(uid => uid !== senderId);
		if (!recipientId) return;
		const userDoc = await db.collection('users').doc(recipientId).get();
		const recipientToken = userDoc.get('fcmToken');
		if (!recipientToken) return;

		const settings = userDoc.get('notificationSettings') || {};
		if (!settings.messageNotificationsEnabled) return;
		const message = {
			token: recipientToken,
			notification,
			data,
			android: {
				notification: {
					channelId: 'direct_chats_channel'
				}
			}
		};
		const messageId = await admin.messaging().send(message);
		logger.info('FCM message sent', { messageId, recipientId, chatId, notification, data, channelId: 'direct_chats_channel' });
	} else if (chatType === 'group') {
		const groupDoc = await db.collection('groupChats').doc(chatId).get();
		if (!groupDoc.exists) return;
		const group = groupDoc.data();
		const participants = group.participants || [];
		for (const memberId of participants) {
			if (memberId === senderId) continue;
			const userDoc = await db.collection('users').doc(memberId).get();
			const recipientToken = userDoc.get('fcmToken');
			if (!recipientToken) continue;

			const settings = userDoc.get('notificationSettings') || {};
			if (!settings.messageNotificationsEnabled) continue;
			const message = {
				token: recipientToken,
				notification,
				data,
				android: {
					notification: {
						channelId: 'group_chats_channel'
					}
				}
			};
			const messageId = await admin.messaging().send(message);
			logger.info('FCM message sent', { messageId, recipientId: memberId, chatId, notification, data, channelId: 'group_chats_channel' });
		}
	}
}

exports.sendGroupChatMessageNotification = functions.region(REGION).firestore
	.document('groupChats/{chatId}/messages/{messageId}')
	.onCreate(async (snap, context) => {
		await sendMessageNotification(snap, context, 'group');
	});

exports.sendDirectChatMessageNotification = functions.region(REGION).firestore
	.document('directChats/{chatId}/messages/{messageId}')
	.onCreate(async (snap, context) => {
		await sendMessageNotification(snap, context, 'direct');
	});

exports.sendFriendRequestNotification = functions.region(REGION).firestore
	.document('users/{userId}/friendIncomingRequests/{requestId}')
	.onCreate(async (snap, context) => {
		const requestData = snap.data();
		if (!requestData) return;
		const recipientId = context.params.userId;
		const senderId = requestData.senderId;
		let senderName = 'Someone';
		try {
			const senderDoc = await db.collection('users').doc(senderId).get();
			if (senderDoc.exists) {
				senderName = senderDoc.get('name') || senderName;
			}
		} catch (e) {
			logger.warn('Failed to fetch sender name', { senderId, error: e });
		}
		const userDoc = await db.collection('users').doc(recipientId).get();
		const recipientToken = userDoc.get('fcmToken');
		if (!recipientToken) return;
		const settings = userDoc.get('notificationSettings') || {};
		if (!settings.friendRequestNotificationsEnabled) return;
		const notification = {
			title: 'Friend Request',
			body: `${senderName} sent you a friend request.`,
		};
		const data = {
			type: 'friend_request',
			route: `/`,
			tab: 1,
			friendsSection: 1,
			title: notification.title,
			body: notification.body,
		};
		const message = {
			token: recipientToken,
			notification,
			data,
			android: {
				notification: {
					channelId: 'friends_channel'
				}
			}
		};
		const messageId = await admin.messaging().send(message);
		logger.info('FCM friend request sent', { messageId, recipientId, notification, data });
	});

exports.sendProjectInviteNotification = functions.region(REGION).firestore
	.document('projects/{projectId}')
	.onUpdate(async (change, context) => {
		const before = change.before.data();
		const after = change.after.data();
		if (!before || !after) return;
		const beforeParticipants = before.participants || [];
		const afterParticipants = after.participants || [];
		const newParticipants = afterParticipants.filter(id => !beforeParticipants.includes(id));
		const projectName = after.name || 'Project';
		for (const recipientId of newParticipants) {
			const userDoc = await db.collection('users').doc(recipientId).get();
			const recipientToken = userDoc.get('fcmToken');
			if (!recipientToken) continue;
			const settings = userDoc.get('notificationSettings') || {};
			if (!settings.projectInviteNotificationsEnabled) continue;
			const notification = {
				title: 'Project Invite',
				body: `You have been invited to join ${projectName}.`,
			};
			const data = {
				type: 'project_invite',
				route: `/projects/${context.params.projectId}`,
				title: notification.title,
				body: notification.body,
			};
			const message = {
				token: recipientToken,
				notification,
				data,
				android: {
					notification: {
						channelId: 'projects_channel'
					}
				}
			};
			const messageId = await admin.messaging().send(message);
			logger.info('FCM project invite sent', { messageId, recipientId, notification, data });
		}
	});

