import 'package:image_picker/image_picker.dart';

abstract interface class IFirebaseStorageRepository {
  Future<String> uploadUserAvatar({
    required String userId,
    required XFile file,
  });

  Future<void> deleteUserAvatar({required String userId});
}
