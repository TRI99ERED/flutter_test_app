import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_messaging_repository/ifirebase_messaging_repository.dart';

class FirebaseMessagingRepositoryImpl implements IFirebaseMessagingRepository {
  @override
  Future<String?> getToken() async {
    if (kIsWeb) {
      return FirebaseMessaging.instance.getToken(
        vapidKey:
            'BHbjDH5S4JRcHyHYGWvSOJDxdJQMCpvh70M1TYzfJy-n8jz-dOkDs5YrY0MRPW8k27DkjYsN-D2KygRJjfqRO98',
      );
    }
    return FirebaseMessaging.instance.getToken();
  }

  @override
  Stream<String> onTokenRefresh() {
    return FirebaseMessaging.instance.onTokenRefresh;
  }
}
