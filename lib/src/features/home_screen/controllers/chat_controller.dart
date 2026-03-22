import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:test_app/src/core/controller/base_controller/base_controller.dart';
import 'package:test_app/src/features/app/app_controller/app_controller.dart';
import 'package:test_app/src/features/app/data/models/chat_model.dart';
import 'package:test_app/src/features/app/data/models/message_model.dart';
import 'package:test_app/src/features/app/data/models/project_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_firestore_repository/firebase_firestore_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_firestore_repository/ifirebase_firestore_repository.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_functions_repository/firebase_functions_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_functions_repository/ifirebase_functions_repository.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_storage_repository/firebase_storage_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_storage_repository/ifirebase_storage_repository.dart';

part 'chat_state.dart';

final class ChatController extends BaseController<ChatState> {
  final AppController _appController;
  final IFirebaseFirestoreRepository _firestoreRepository;
  final IFirebaseFunctionsRepository _functionsRepository;
  final IFirebaseStorageRepository _storageRepository;

  ChatController({required AppController appController})
    : _appController = appController,
      _firestoreRepository = FirebaseFirestoreRepositoryImpl(),
      _functionsRepository = FirebaseFunctionsRepositoryImpl(),
      _storageRepository = FirebaseStorageRepositoryImpl(),
      super(
        state: const ChatState.idle(message: 'initialized'),
        name: 'ChatController',
      ) {
    _appController.addListener(_onAppStateChanged);
  }

  void _onAppStateChanged() {
    final appState = _appController.state;
    if (appState.isAuthorized) {
      setState(
        ChatState.idle(
          message:
              'User "${(appState.user as AuthorizedUser).name}" is authorized',
        ),
      );
    } else {
      setState(ChatState.idle(message: 'User is not authorized'));
    }
  }

  Stream<List<DirectChat>?> watchDirectChatsForUser(String userId) {
    return _firestoreRepository.watchDirectChatsForUser(userId);
  }

  Stream<List<GroupChat>?> watchGroupChatsForUser(String userId) {
    return _firestoreRepository.watchGroupChatsForUser(userId);
  }

  Future<DirectChat> createDirectChat({
    required List<String> participants,
    required String chatName,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      ChatState.processing(message: 'Creating direct chat "$chatName"...'),
    );
    try {
      final chat = await _firestoreRepository.createDirectChat(
        participants: participants,
        chatName: chatName,
      );
      setState(
        ChatState.idle(
          message:
              'Direct chat "$chatName" created successfully, id: "${chat.id}"',
        ),
      );
      return chat;
    } catch (error, stackTrace) {
      setState(
        ChatState.failed(
          message:
              'Failed to create direct chat "$chatName": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<GroupChat> createGroupChat({
    required String chatName,
    required List<String> participants,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      ChatState.processing(message: 'Creating group chat "$chatName"...'),
    );
    try {
      final chat = await _firestoreRepository.createGroupChat(
        chatName: chatName,
        participants: participants,
        ownerId: (_appController.state.user as AuthorizedUser).id,
      );
      setState(
        ChatState.idle(
          message:
              'Group chat "$chatName" created successfully, id: "${chat.id}"',
        ),
      );
      return chat;
    } catch (error, stackTrace) {
      setState(
        ChatState.failed(
          message:
              'Failed to create group chat "$chatName": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Stream<List<Message>?> watchMessagesForDirectChat(String chatId) {
    return _firestoreRepository.watchMessagesForDirectChat(chatId: chatId);
  }

  Stream<List<Message>?> watchMessagesForGroupChat(String chatId) {
    return _firestoreRepository.watchMessagesForGroupChat(chatId: chatId);
  }

  Future<Message> createDirectChatMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String body,
    required List<File> imageFiles,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      ChatState.processing(
        message: 'Sending message "$body" in direct chat "$chatId"...',
      ),
    );
    try {
      List<String> imageUrls = [];
      if (imageFiles.isNotEmpty) {
        imageUrls = await _storageRepository.uploadMessageImages(
          files: imageFiles,
          chatId: chatId,
        );
      }
      final message = await _firestoreRepository.createDirectChatMessage(
        chatId: chatId,
        senderId: senderId,
        body: body,
        imageUrls: imageUrls,
      );
      setState(
        ChatState.idle(
          message:
              'Message "$body" sent successfully in direct chat "$chatId", id: "${message.id}"',
        ),
      );
      return message;
    } catch (error, stackTrace) {
      setState(
        ChatState.failed(
          message:
              'Failed to send message "$body" in direct chat "$chatId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<Message> createGroupChatMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String body,
    required List<File> imageFiles,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      ChatState.processing(
        message: 'Sending message "$body" in group chat "$chatId"...',
      ),
    );
    try {
      List<String> imageUrls = [];
      if (imageFiles.isNotEmpty) {
        imageUrls = await _storageRepository.uploadMessageImages(
          files: imageFiles,
          chatId: chatId,
        );
      }
      final message = await _firestoreRepository.createGroupChatMessage(
        chatId: chatId,
        senderId: senderId,
        body: body,
        imageUrls: imageUrls,
      );
      setState(
        ChatState.idle(
          message:
              'Message "$body" sent successfully in group chat "$chatId", id: "${message.id}"',
        ),
      );
      return message;
    } catch (error, stackTrace) {
      setState(
        ChatState.failed(
          message:
              'Failed to send message "$body" in group chat "$chatId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> updateDirectChatLastMessage({
    required String chatId,
    required String lastMessage,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      ChatState.processing(
        message: 'Updating last message for direct chat "$chatId"...',
      ),
    );
    try {
      await _firestoreRepository.updateDirectChatLastMessage(
        chatId: chatId,
        lastMessage: lastMessage,
      );
      setState(
        ChatState.idle(
          message:
              'Last message for direct chat "$chatId" updated successfully',
        ),
      );
    } catch (error, stackTrace) {
      setState(
        ChatState.failed(
          message:
              'Failed to update last message for direct chat "$chatId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> updateGroupChatLastMessage({
    required String chatId,
    required String lastMessage,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      ChatState.processing(
        message: 'Updating last message for group chat "$chatId"...',
      ),
    );
    try {
      await _firestoreRepository.updateGroupChatLastMessage(
        chatId: chatId,
        lastMessage: lastMessage,
      );
      setState(
        ChatState.idle(
          message: 'Last message for group chat "$chatId" updated successfully',
        ),
      );
    } catch (error, stackTrace) {
      setState(
        ChatState.failed(
          message:
              'Failed to update last message for group chat "$chatId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Stream<int?> watchDirectChatUnreadCount(String chatId) {
    return _firestoreRepository.watchDirectChatUnreadCount(chatId: chatId);
  }

  Stream<Map<String, int>?> watchGroupChatUnreadCounts(String chatId) {
    return _firestoreRepository.watchGroupChatUnreadCounts(chatId: chatId);
  }

  Future<void> updateDirectChatUnreadCount({
    required String chatId,
    required int unreadCount,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      ChatState.processing(
        message: 'Updating unread count for direct chat "$chatId"...',
      ),
    );
    try {
      await _firestoreRepository.updateDirectChatUnreadCount(
        chatId: chatId,
        unreadCount: unreadCount,
      );
      setState(
        ChatState.idle(
          message:
              'Unread count for direct chat "$chatId" updated successfully',
        ),
      );
    } catch (error, stackTrace) {
      setState(
        ChatState.failed(
          message:
              'Failed to update unread count for direct chat "$chatId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> updateGroupChatUnreadCounts({
    required String chatId,
    required Map<String, int> unreadCounts,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      ChatState.processing(
        message: 'Updating unread counts for group chat "$chatId"...',
      ),
    );
    try {
      await _firestoreRepository.updateGroupChatUnreadCounts(
        chatId: chatId,
        unreadCounts: unreadCounts,
      );
      setState(
        ChatState.idle(
          message:
              'Unread counts for group chat "$chatId" updated successfully',
        ),
      );
    } catch (error, stackTrace) {
      setState(
        ChatState.failed(
          message:
              'Failed to update unread counts for group chat "$chatId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> deleteDirectChat(String chatId) async =>
      await serialExecutor.synchronized(() async {
        setState(
          ChatState.processing(message: 'Deleting direct chat "$chatId"...'),
        );
        try {
          await _firestoreRepository.deleteDirectChat(chatId);
          setState(
            ChatState.idle(
              message: 'Direct chat "$chatId" deleted successfully',
            ),
          );
        } catch (error, stackTrace) {
          setState(
            ChatState.failed(
              message:
                  'Failed to delete direct chat "$chatId": ${error.toString()}',
              error: error,
              stackTrace: stackTrace,
            ),
          );
          return Future.error(error, stackTrace);
        }
      });

  Future<void> deleteGroupChat(
    String chatId,
  ) async => await serialExecutor.synchronized(() async {
    setState(ChatState.processing(message: 'Deleting group chat "$chatId"...'));
    try {
      await _firestoreRepository.deleteGroupChat(chatId);
      final projects = await _firestoreRepository
          .watchProjectsForUser(
            (_appController.state.user as AuthorizedUser).id,
            'lastUpdated',
            true,
          )
          .first;
      final associatedProject = projects?.firstWhere(
        (p) => p.groupChatId == chatId,
        orElse: () => Project(
          id: '',
          name: '',
          description: '',
          ownerId: '',
          participants: [],
          status: ProjectStatus.todo,
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
          deadline: DateTime.now(),
        ),
      );
      if (associatedProject != null && associatedProject.id.isNotEmpty) {
        await _firestoreRepository.updateProject(
          associatedProject.copyWith(groupChatId: ''),
        );
      }
      setState(
        ChatState.idle(message: 'Group chat "$chatId" deleted successfully'),
      );
    } catch (error, stackTrace) {
      setState(
        ChatState.failed(
          message: 'Failed to delete group chat "$chatId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Stream<DirectChat?> watchDirectChatWithId(String chatId) {
    return _firestoreRepository.watchDirectChatWithId(chatId);
  }

  Stream<GroupChat?> watchGroupChatWithId(String chatId) {
    return _firestoreRepository.watchGroupChatWithId(chatId);
  }

  Stream<List<Chat>?> watchAllChatsForUser(String userId) {
    return _firestoreRepository.watchAllChatsForUser(userId);
  }

  Future<void> uploadGroupChatAvatar(
    String chatId,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      ChatState.processing(
        message: 'Uploading avatar for group chat "$chatId"...',
      ),
    );
    try {
      final imageFile = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (imageFile == null) {
        setState(
          ChatState.idle(
            message: 'Group chat avatar upload cancelled for chat "$chatId".',
          ),
        );
        return;
      }
      final url = await _functionsRepository.uploadGroupAvatar(
        chatId: chatId,
        filename: imageFile.files.first.name,
        avatarBytes: imageFile.files.first.bytes!,
      );
      await _firestoreRepository.updateGroupChatAvatarUrl(
        chatId: chatId,
        url: url,
      );
      setState(
        ChatState.idle(
          message: 'Avatar uploaded successfully for group chat "$chatId".',
        ),
      );
    } catch (error, stackTrace) {
      setState(
        ChatState.failed(
          message:
              'Failed to upload avatar for group chat "$chatId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> deleteGroupChatAvatar(
    String chatId,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      ChatState.processing(
        message: 'Deleting avatar for group chat "$chatId"...',
      ),
    );
    try {
      final currentAvatarUrl = await _firestoreRepository
          .watchGroupChatWithId(chatId)
          .map((chat) => chat?.avatarUrl)
          .firstWhere((url) => url != null, orElse: () => null);
      if (currentAvatarUrl == null || currentAvatarUrl.isEmpty) {
        setState(
          ChatState.idle(
            message: 'No avatar to delete for group chat "$chatId".',
          ),
        );
        return;
      }
      await _functionsRepository.deleteGroupAvatar(
        chatId: chatId,
        filename: currentAvatarUrl.split('/').last,
      );
      setState(
        ChatState.idle(
          message: 'Avatar deleted successfully for group chat "$chatId".',
        ),
      );
    } catch (error, stackTrace) {
      setState(
        ChatState.failed(
          message:
              'Failed to delete avatar for group chat "$chatId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> updateUserCurrentDirectChatId({
    required String userId,
    String currentDirectChatId = '',
  }) async => await serialExecutor.synchronized(() async {
    setState(
      ChatState.processing(
        message: 'Updating current direct chat for user "$userId"...',
      ),
    );
    try {
      await _firestoreRepository.updateUserCurrentDirectChatId(
        userId: userId,
        currentDirectChatId: currentDirectChatId,
      );
      setState(
        ChatState.idle(
          message:
              'Current direct chat updated successfully for user "$userId".',
        ),
      );
    } catch (error, stackTrace) {
      setState(
        ChatState.failed(
          message:
              'Failed to update current direct chat for user "$userId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> updateUserCurrentGroupChatId({
    required String userId,
    String currentGroupChatId = '',
  }) async => await serialExecutor.synchronized(() async {
    setState(
      ChatState.processing(
        message: 'Updating current group chat for user "$userId"...',
      ),
    );
    try {
      await _firestoreRepository.updateUserCurrentGroupChatId(
        userId: userId,
        currentGroupChatId: currentGroupChatId,
      );
      setState(
        ChatState.idle(
          message:
              'Current group chat updated successfully for user "$userId".',
        ),
      );
    } catch (error, stackTrace) {
      setState(
        ChatState.failed(
          message:
              'Failed to update current group chat for user "$userId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Stream<String?> watchUserCurrentDirectChatId(String userId) {
    return _appController
        .watchUserWithId(userId)
        .map((user) => user?.currentDirectChatId);
  }

  Stream<String?> watchUserCurrentGroupChatId(String userId) {
    return _appController
        .watchUserWithId(userId)
        .map((user) => user?.currentGroupChatId);
  }

  Future<void> updateGroupChat(
    GroupChat chat,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      ChatState.processing(message: 'Updating group chat "${chat.id}"...'),
    );
    try {
      await _firestoreRepository.updateGroupChat(chat);
      setState(
        ChatState.idle(
          message: 'Group chat "${chat.id}" updated successfully.',
        ),
      );
    } catch (error, stackTrace) {
      setState(
        ChatState.failed(
          message:
              'Failed to update group chat "${chat.id}": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Stream<String> watchGroupChatAvatarUrl(String chatId) {
    return _firestoreRepository
        .watchGroupChatWithId(chatId)
        .map((chat) => chat?.avatarUrl ?? '');
  }

  Future<void> saveMessage(SavedMessage message) async =>
      await serialExecutor.synchronized(() async {
        setState(ChatState.processing(message: 'Saving message...'));
        try {
          await _firestoreRepository.saveMessage(
            (_appController.state.user as AuthorizedUser).id,
            message,
          );
          setState(
            ChatState.idle(
              message: 'Message saved successfully, id: "${message.id}"',
            ),
          );
        } catch (error, stackTrace) {
          setState(
            ChatState.failed(
              message: 'Failed to save message: ${error.toString()}',
              error: error,
              stackTrace: stackTrace,
            ),
          );
          return Future.error(error, stackTrace);
        }
      });

  Stream<List<SavedMessage>?> watchSavedMessages() {
    return _firestoreRepository.watchSavedMessages(
      (_appController.state.user as AuthorizedUser).id,
    );
  }

  Future<void> createSavedMessage(String body, List<File> imageFiles) async =>
      await serialExecutor.synchronized(() async {
        setState(ChatState.processing(message: 'Creating saved message...'));
        try {
          List<String> imageUrls = [];
          if (imageFiles.isNotEmpty) {
            imageUrls = await _storageRepository.uploadSavedMessageImages(
              files: imageFiles,
              userId: (_appController.state.user as AuthorizedUser).id,
            );
          }
          await _firestoreRepository.createSavedMessage(
            (_appController.state.user as AuthorizedUser).id,
            body,
            imageUrls,
          );
          setState(
            ChatState.idle(message: 'Saved message created successfully.'),
          );
        } catch (error, stackTrace) {
          setState(
            ChatState.failed(
              message: 'Failed to create saved message: ${error.toString()}',
              error: error,
              stackTrace: stackTrace,
            ),
          );
          return Future.error(error, stackTrace);
        }
      });

  Future<void> deleteSavedMessage(String messageId) async =>
      await serialExecutor.synchronized(() async {
        setState(ChatState.processing(message: 'Deleting saved message...'));
        try {
          await _firestoreRepository.deleteSavedMessage(
            (_appController.state.user as AuthorizedUser).id,
            messageId,
          );
          setState(
            ChatState.idle(message: 'Saved message deleted successfully.'),
          );
        } catch (error, stackTrace) {
          setState(
            ChatState.failed(
              message: 'Failed to delete saved message: ${error.toString()}',
              error: error,
              stackTrace: stackTrace,
            ),
          );
          return Future.error(error, stackTrace);
        }
      });

  Future<void> updateGroupChatCurrentUserUnreadCount({
    required String chatId,
    required int unreadCount,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      ChatState.processing(
        message:
            'Updating this user\'s unread count for group chat "$chatId"...',
      ),
    );
    try {
      final groupChatUnreadCounts = await watchGroupChatWithId(
        chatId,
      ).map((chat) => chat?.unreadCounts ?? {}).first;
      final updatedUnreadCounts = Map<String, int>.from(groupChatUnreadCounts)
        ..[(_appController.state.user as AuthorizedUser).id] = unreadCount;
      await _firestoreRepository.updateGroupChatUnreadCounts(
        chatId: chatId,
        unreadCounts: updatedUnreadCounts,
      );
      setState(
        ChatState.idle(
          message:
              'This user\'s unread count updated successfully for group chat "$chatId".',
        ),
      );
    } catch (error, stackTrace) {
      setState(
        ChatState.failed(
          message:
              'Failed to update this user\'s unread count for group chat "$chatId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<List<File>> pickMessageImages({required String chatId}) async =>
      await serialExecutor.synchronized(() async {
        setState(ChatState.processing(message: 'Picking message image...'));
        try {
          final imageFile = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: true,
          );
          if (imageFile == null || imageFile.files.isEmpty) {
            setState(
              ChatState.idle(
                message:
                    'Message image selection cancelled for chat "$chatId".',
              ),
            );
            return [];
          }
          final files = imageFile.files
              .map(
                (file) => file.path != null
                    ? File(file.path!)
                    : File.fromRawPath(file.bytes!),
              )
              .toList();
          setState(ChatState.idle(message: 'Message image selected.'));
          return files;
        } catch (error, stackTrace) {
          setState(
            ChatState.failed(
              message: 'Failed to pick message image: ${error.toString()}',
              error: error,
              stackTrace: stackTrace,
            ),
          );
          return Future.error(error, stackTrace);
        }
      });

  Future<List<File>>
  pickSavedMessageImages() async => await serialExecutor.synchronized(() async {
    setState(ChatState.processing(message: 'Picking saved message image...'));
    try {
      final imageFile = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (imageFile == null || imageFile.files.isEmpty) {
        setState(
          ChatState.idle(message: 'Saved message image selection cancelled.'),
        );
        return [];
      }
      final files = imageFile.files
          .map(
            (file) => file.path != null
                ? File(file.path!)
                : File.fromRawPath(file.bytes!),
          )
          .toList();
      setState(ChatState.idle(message: 'Saved message image selected.'));
      return files;
    } catch (error, stackTrace) {
      setState(
        ChatState.failed(
          message: 'Failed to pick saved message image: ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });
}
