import 'package:image_picker/image_picker.dart';

abstract interface class IFirebaseStorageRepository {
  Future<String> uploadUserAvatar({
    required String userId,
    required XFile file,
  });

  Future<void> deleteUserAvatar({required String userId});

  Future<String> uploadGroupChatAvatar({
    required String chatId,
    required XFile file,
  });

  Future<void> deleteGroupChatAvatar({required String chatId});
}
