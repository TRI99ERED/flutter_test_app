import 'dart:io';

abstract interface class IFirebaseStorageRepository {
  Future<String> uploadUserAvatar({required String userId, required File file});

  Future<void> deleteUserAvatar({required String userId});

  Future<String> uploadGroupChatAvatar({
    required String chatId,
    required File file,
  });

  Future<void> deleteGroupChatAvatar({required String chatId});
}
