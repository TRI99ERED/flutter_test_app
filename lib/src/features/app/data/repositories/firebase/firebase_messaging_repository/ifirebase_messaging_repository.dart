abstract interface class IFirebaseMessagingRepository {
  Future<void> deleteToken();

  Future<String?> getToken();

  Stream<String> onTokenRefresh();
}
