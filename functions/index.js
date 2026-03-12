const { Storage } = require('@google-cloud/storage');
const storage = new Storage();
const crypto = require("node:crypto");
const admin = require("firebase-admin");
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
