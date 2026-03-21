import 'package:rxdart/rxdart.dart';
import 'package:test_app/src/core/controller/base_controller/base_controller.dart';
import 'package:test_app/src/features/app/app_controller/app_controller.dart';
import 'package:test_app/src/features/app/data/models/project_model.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_firestore_repository/firebase_firestore_repository_impl.dart';
import 'package:test_app/src/features/app/data/repositories/firebase/firebase_firestore_repository/ifirebase_firestore_repository.dart';

part 'project_state.dart';

final class ProjectController extends BaseController<ProjectState> {
  final AppController _appController;
  final IFirebaseFirestoreRepository _firestoreRepository;

  ProjectController({required AppController appController})
    : _appController = appController,
      _firestoreRepository = FirebaseFirestoreRepositoryImpl(),
      super(
        state: const ProjectState.idle(message: 'Idle'),
        name: 'ProjectController',
      );

  Stream<List<Project>?> watchToDoProjectsForUser(
    String userId, [
    String orderBy = 'lastUpdated',
    bool descending = true,
  ]) {
    return _firestoreRepository
        .watchProjectsForUser(userId, orderBy, descending)
        .map((projects) {
          return projects
              ?.where((project) => project.status == ProjectStatus.todo)
              .toList();
        });
  }

  Stream<List<Project>?> watchInProgressProjectsForUser(
    String userId, [
    String orderBy = 'lastUpdated',
    bool descending = true,
  ]) {
    return _firestoreRepository
        .watchProjectsForUser(userId, orderBy, descending)
        .map((projects) {
          return projects
              ?.where((project) => project.status == ProjectStatus.inProgress)
              .toList();
        });
  }

  Stream<List<Project>?> watchFinishedProjectsForUser(
    String userId, [
    String orderBy = 'lastUpdated',
    bool descending = true,
  ]) {
    return _firestoreRepository
        .watchProjectsForUser(userId, orderBy, descending)
        .map((projects) {
          return projects
              ?.where((project) => project.status == ProjectStatus.finished)
              .toList();
        });
  }

  Future<Project> createProjectForUser({
    required String projectName,
    required String projectDescription,
    required List<String> participants,
    required DateTime deadline,
  }) async => await serialExecutor.synchronized(() async {
    setState(
      ProjectState.processing(message: 'Creating project "$projectName"...'),
    );
    try {
      final project = await _firestoreRepository.createProjectForUser(
        (_appController.state.user as AuthorizedUser).id,
        projectName,
        projectDescription,
        participants,
        deadline,
      );
      setState(
        ProjectState.idle(
          message:
              'Project "$projectName" created successfully, id: "${project.id}"',
        ),
      );
      return project;
    } catch (error, stackTrace) {
      setState(
        ProjectState.failed(
          message:
              'Failed to create project "$projectName": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Future<void> updateProject(
    Project project,
  ) async => await serialExecutor.synchronized(() async {
    setState(
      ProjectState.processing(message: 'Updating project "${project.name}"...'),
    );
    try {
      await _firestoreRepository.updateProject(project);
      setState(
        ProjectState.idle(
          message: 'Project "${project.name}" updated successfully',
        ),
      );
    } catch (error, stackTrace) {
      setState(
        ProjectState.failed(
          message:
              'Failed to update project "${project.name}": ${error.toString()}',
          error: error,
          stackTrace: stackTrace,
        ),
      );
      return Future.error(error, stackTrace);
    }
  });

  Stream<List<AuthorizedUser>?> watchProjectParticipants(String projectId) {
    return Rx.combineLatest2(
      _firestoreRepository.watchProjectWithId(projectId),
      _firestoreRepository.watchAllUsers(),
      (Project? project, List<AuthorizedUser>? users) {
        final participantIds = project?.participants.toSet() ?? {};
        return users
            ?.where((user) => participantIds.contains(user.id))
            .toList();
      },
    );
  }

  Stream<Project?> watchProjectWithId(String projectId) {
    return _firestoreRepository.watchProjectWithId(projectId);
  }

  Future<void> deleteProject(String projectId) async =>
      await serialExecutor.synchronized(() async {
        setState(
          ProjectState.processing(message: 'Deleting project "$projectId"...'),
        );
        try {
          await _firestoreRepository.deleteProject(projectId);
          setState(
            ProjectState.idle(
              message: 'Project "$projectId" deleted successfully.',
            ),
          );
        } catch (error, stackTrace) {
          setState(
            ProjectState.failed(
              message:
                  'Failed to delete project "$projectId": ${error.toString()}',
              error: error,
              stackTrace: stackTrace,
            ),
          );
          return Future.error(error, stackTrace);
        }
      });
}
