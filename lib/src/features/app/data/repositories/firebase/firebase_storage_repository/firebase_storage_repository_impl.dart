import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_storage_repository/ifirebase_storage_repository.dart';

class FirebaseStorageRepositoryImpl implements IFirebaseStorageRepository {
  @override
  Future<String> uploadUserAvatar({required String userId, XFile? file}) async {
    try {
      await deleteUserAvatar(userId: userId);
      final metadata = switch (file!.name.split('.').last.toLowerCase()) {
        'jpg' || 'jpeg' => SettableMetadata(contentType: 'image/jpeg'),
        'png' => SettableMetadata(contentType: 'image/png'),
        'svg' => SettableMetadata(contentType: 'image/svg+xml'),
        'gif' => SettableMetadata(contentType: 'image/gif'),
        'webp' => SettableMetadata(contentType: 'image/webp'),
        _ => throw Exception('Unsupported file type'),
      };
      final ref = FirebaseStorage.instance.ref().child(
        'avatars/$userId/avatar.${file.name.split('.').last.toLowerCase()}',
      );
      await ref.putData(await file.readAsBytes(), metadata);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  @override
  Future<void> deleteUserAvatar({required String userId}) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('avatars/$userId');
      final ListResult result = await ref.listAll();
      for (var item in result.items) {
        await item.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete avatar: $e');
    }
  }

  @override
  Future<String> uploadGroupChatAvatar({
    required String chatId,
    required XFile file,
  }) async {
    try {
      await deleteGroupChatAvatar(chatId: chatId);
      final metadata = switch (file.name.split('.').last.toLowerCase()) {
        'jpg' || 'jpeg' => SettableMetadata(contentType: 'image/jpeg'),
        'png' => SettableMetadata(contentType: 'image/png'),
        'svg' => SettableMetadata(contentType: 'image/svg+xml'),
        'gif' => SettableMetadata(contentType: 'image/gif'),
        'webp' => SettableMetadata(contentType: 'image/webp'),
        _ => throw Exception('Unsupported file type'),
      };
      final ref = FirebaseStorage.instance.ref().child(
        'avatars/groups/$chatId/avatar.${file.name.split('.').last.toLowerCase()}',
      );
      await ref.putData(await file.readAsBytes(), metadata);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Failed to upload group chat avatar: $e');
    }
  }

  @override
  Future<void> deleteGroupChatAvatar({required String chatId}) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(
        'avatars/groups/$chatId',
      );
      final ListResult result = await ref.listAll();
      for (var item in result.items) {
        await item.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete group chat avatar: $e');
    }
  }
}
