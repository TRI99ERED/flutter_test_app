import 'package:flutter/material.dart';
// TODO: Remove go_router once migration is complete
// import 'package:go_router/go_router.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/widgets/common/app_avatar.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_nav_bar.dart';
import 'package:test_app/src/widgets/common/app_text_field.dart';
import 'package:test_app/src/widgets/common/error_state.dart';
import 'package:test_app/src/features/themes/styles.dart';

enum UserProfileMode { view, edit }

class UserProfile extends StatefulWidget {
  final AuthorizedUser user;
  final UserProfileMode mode;

  const UserProfile({
    super.key,
    required this.user,
    this.mode = UserProfileMode.view,
  });

  static void show(
    BuildContext context,
    AuthorizedUser user, {
    UserProfileMode mode = UserProfileMode.view,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(216),
      builder: (context) => UserProfile(user: user, mode: mode),
    );
  }

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _nameController = TextEditingController();
  final _handleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _isFormValid = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _handleController.text = widget.user.handle;
    _nameController.addListener(_validateForm);
    _handleController.addListener(_validateForm);
  }

  void _validateForm() {
    if (_formKey.currentState != null) {
      final isValid = _formKey.currentState!.validate();
      _isFormValid.value = isValid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavBar(
        title: widget.mode == UserProfileMode.view
            ? context.l10n.userProfileTitle
            : context.l10n.editProfileTitle,
        leftText: context.l10n.closeLabel,
        onPressedLeft: () => Navigator.of(context).pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(spacing16),
        child: Column(
          spacing: spacing8,
          children: [
            Expanded(
              child: switch (widget.mode) {
                UserProfileMode.view => _buildProfileView(),
                UserProfileMode.edit => _buildProfileEdit(),
              },
            ),
            if (widget.mode == UserProfileMode.edit)
              ValueListenableBuilder(
                valueListenable: _isFormValid,
                builder: (context, value, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: AppButtonPrimary(
                      text: context.l10n.saveLabel,
                      onPressed: value
                          ? () async {
                              await context.appController.updateUser(
                                widget.user.copyWith(
                                      name: _nameController.text,
                                      handle: _handleController.text,
                                    )
                                    as AuthorizedUser,
                              );
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            }
                          : null,
                    ),
                  );
                },
              ),
            SizedBox(
              width: double.infinity,
              child: AppButtonPrimary(
                text: context.l10n.closeLabel,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView() {
    return ListView(
      children: [
        Center(
          child: StreamBuilder(
            stream: context.appController.watchUserWithId(widget.user.id),
            builder: (context, asyncSnapshot) {
              return AppAvatar.avatarOrPlaceholder(
                asyncSnapshot.data ?? widget.user,
                AvatarSize.large,
              );
            },
          ),
        ),
        Column(
          spacing: spacing8,
          children: [
            Text(
              context.l10n.nameLabel,
              style: TextStyle(
                fontSize: h3Size,
                fontWeight: h3Weight,
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundStrongestColor,
              ),
            ),
            Text(
              widget.user.name,
              style: TextStyle(
                fontSize: bMSize,
                fontWeight: bMWeight,
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundStrongestColor,
              ),
            ),
          ],
        ),
        Column(
          spacing: spacing8,
          children: [
            Text(
              context.l10n.handleLabel,
              style: TextStyle(
                fontSize: h3Size,
                fontWeight: h3Weight,
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundStrongestColor,
              ),
            ),
            if (widget.user.handle.isNotEmpty)
              Text(
                '@${widget.user.handle}',
                style: TextStyle(
                  fontSize: bMSize,
                  fontWeight: bMWeight,
                  color: Theme.of(
                    context,
                  ).extension<AppTheme>()?.foregroundStrongestColor,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileEdit() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButtonPrimary(
                text: context.l10n.pickAnAvatarLabel,
                onPressed: () async {
                  await context.appController.uploadUserAvatar();
                },
              ),
              StreamBuilder(
                stream: context.appController.watchUserWithId(widget.user.id),
                builder: (context, asyncSnapshot) {
                  return AppAvatar.avatarOrPlaceholder(
                    asyncSnapshot.data ?? widget.user,
                    AvatarSize.medium,
                  );
                },
              ),
            ],
          ),
          Text(
            context.l10n.nameLabel,
            style: TextStyle(
              fontSize: h3Size,
              fontWeight: h3Weight,
              color: Theme.of(
                context,
              ).extension<AppTheme>()?.foregroundStrongestColor,
            ),
          ),
          AppTextField(
            placeholder: context.l10n.enterYourNameLabel,
            controller: _nameController,
            validator: getValidatorForKeyboardType(context, TextInputType.name),
            onChanged: (_) => _validateForm(),
          ),
          Text(
            context.l10n.handleLabel,
            style: TextStyle(
              fontSize: h3Size,
              fontWeight: h3Weight,
              color: Theme.of(
                context,
              ).extension<AppTheme>()?.foregroundStrongestColor,
            ),
          ),
          StreamBuilder(
            stream: context.appController.watchAllUsers(),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: AppLoader());
              }
              if (asyncSnapshot.hasError) {
                return Center(
                  child: ErrorState(
                    message:
                        '${context.l10n.errorLoadingUsersMessage}: ${asyncSnapshot.error}',
                  ),
                );
              }
              final users = asyncSnapshot.data ?? [];
              return AppTextField(
                placeholder: context.l10n.enterYourHandleLabel,
                controller: _handleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }
                  if (value.contains(' ')) {
                    return context.l10n.handleCannotContainSpacesMessage;
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                    return context
                        .l10n
                        .handleCanOnlyContainLettersNumbersAndUnderscoresMessage;
                  }
                  final isHandleTaken = users.any(
                    (user) =>
                        user.handle.toLowerCase() ==
                            _handleController.text.toLowerCase() &&
                        user.id != widget.user.id,
                  );
                  if (isHandleTaken) {
                    return context.l10n.handleIsAlreadyTakenMessage;
                  }
                  return null;
                },
                onChanged: (_) => _validateForm(),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _handleController.dispose();
    super.dispose();
  }
}
