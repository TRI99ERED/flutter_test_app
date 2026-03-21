import 'package:test_app/src/core/controller/base_controller/base_controller.dart';
import 'package:test_app/src/features/app/app_controller/app_controller.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_firestore_repository/firebase_firestore_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_firestore_repository/ifirebase_firestore_repository.dart';

part 'friends_state.dart';

final class FriendController extends BaseController<FriendState> {
  final AppController _appController;
  final IFirebaseFirestoreRepository _firestoreRepository;

  FriendController({required AppController appController})
    : _appController = appController,
      _firestoreRepository = FirebaseFirestoreRepositoryImpl(),
      super(
        state: const FriendState.idle(message: 'Idle'),
        name: 'FriendsController',
      );

  Stream<List<AuthorizedUser>?> watchFriendsForUser(String userId) {
    return _firestoreRepository.watchFriendsForUser(userId: userId);
  }

  Future<void> sendFriendRequest(
    String currentUserId,
    String friendUserId,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      FriendState.processing(
        message: 'Sending friend request to "$friendUserId"...',
      ),
    );
    try {
      await _firestoreRepository.sendFriendRequest(
        currentUserId: currentUserId,
        friendUserId: friendUserId,
      );
      setState(
        FriendState.idle(
          message: 'Friend request sent to "$friendUserId" successfully',
        ),
      );
    } catch (error, stackTrace) {
      setState(
        FriendState.failed(
          message:
              'Failed to send friend request to "$friendUserId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Stream<List<AuthorizedUser>?> watchFriendIncomingRequestsForUser(
    String userId,
  ) {
    return _firestoreRepository.watchFriendIncomingRequestsForUser(
      userId: userId,
    );
  }

  Stream<List<AuthorizedUser>?> watchFriendOutgoingRequestsForUser(
    String userId,
  ) {
    return _firestoreRepository.watchFriendOutgoingRequestsForUser(
      userId: userId,
    );
  }

  Future<void> acceptFriendRequest({
    required String friendUserId,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      FriendState.processing(
        message: 'Accepting friend request from "$friendUserId"...',
      ),
    );
    try {
      await _firestoreRepository.acceptFriendRequest(
        currentUserId: _appController.state.user is AuthorizedUser
            ? (_appController.state.user as AuthorizedUser).id
            : '',
        friendUserId: friendUserId,
      );
      setState(
        FriendState.idle(
          message: 'Friend request from "$friendUserId" accepted successfully',
        ),
      );
    } catch (error, stackTrace) {
      setState(
        FriendState.failed(
          message:
              'Failed to accept friend request from "$friendUserId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> declineFriendRequest({
    required String friendUserId,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      FriendState.processing(
        message: 'Declining friend request from "$friendUserId"...',
      ),
    );
    try {
      await _firestoreRepository.declineFriendRequest(
        currentUserId: _appController.state.user is AuthorizedUser
            ? (_appController.state.user as AuthorizedUser).id
            : '',
        friendUserId: friendUserId,
      );
      setState(
        FriendState.idle(
          message: 'Friend request from "$friendUserId" declined successfully',
        ),
      );
    } catch (error, stackTrace) {
      setState(
        FriendState.failed(
          message:
              'Failed to decline friend request from "$friendUserId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> cancelFriendRequest({
    required String friendUserId,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      FriendState.processing(
        message: 'Cancelling friend request to "$friendUserId"...',
      ),
    );
    try {
      await _firestoreRepository.cancelFriendRequest(
        currentUserId: _appController.state.user is AuthorizedUser
            ? (_appController.state.user as AuthorizedUser).id
            : '',
        friendUserId: friendUserId,
      );
      setState(
        FriendState.idle(
          message: 'Friend request to "$friendUserId" cancelled successfully',
        ),
      );
    } catch (error, stackTrace) {
      setState(
        FriendState.failed(
          message:
              'Failed to cancel friend request to "$friendUserId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> removeFriend({
    required String friendUserId,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      FriendState.processing(message: 'Removing friend "$friendUserId"...'),
    );
    try {
      await _firestoreRepository.removeFriend(
        currentUserId: _appController.state.user is AuthorizedUser
            ? (_appController.state.user as AuthorizedUser).id
            : '',
        friendUserId: friendUserId,
      );
      setState(
        FriendState.idle(
          message: 'Friend "$friendUserId" removed successfully',
        ),
      );
    } catch (error, stackTrace) {
      setState(
        FriendState.failed(
          message:
              'Failed to remove friend "$friendUserId": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });
}
