import 'package:test_app/src/core/controller/base_controller/base_controller.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';

part 'app_state.dart';

final class AppController extends BaseController<AppState> {
  AppController()
    : super(
        state: const AppState.idle(
          message: 'initialized',
          user: UnauthorizedUser(),
        ),
        name: 'AppController',
      ) {
    // NOTE: You can do stuff here
  }

  @override
  void dispose() {
    super.dispose();
  }
}
