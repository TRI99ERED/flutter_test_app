abstract interface class IFirebaseMessagingRepository {
  Future<String?> getToken();

  Stream<String> onTokenRefresh();
}
