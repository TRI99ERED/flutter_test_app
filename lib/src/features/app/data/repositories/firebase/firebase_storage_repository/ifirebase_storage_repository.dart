import 'dart:io';

abstract interface class IFirebaseStorageRepository {
  Future<void> deleteUserAvatar({required String userId});

  Future<List<String>> uploadMessageImages({
    required String chatId,
    required List<File> files,
  });

  Future<List<String>> uploadSavedMessageImages({
    required String userId,
    required List<File> files,
  });

  Future<String> uploadUserAvatar({required String userId, required File file});
}
