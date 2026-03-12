import 'dart:typed_data';

abstract interface class IFirebaseFunctionsRepository {
  Future<void> deleteGroupAvatar({
    required String chatId,
    required String filename,
  });

  Future<void> resendEmailVerification();

  Future<void> sendEmailVerification();
  Future<String> uploadGroupAvatar({
    required String chatId,
    required String filename,
    required Uint8List avatarBytes,
  });
  Future<void> verifyEmailCode({required String code});
}
