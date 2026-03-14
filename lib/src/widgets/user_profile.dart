import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/src/features/app/app_scope.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/app_avatar.dart';
import 'package:test_app/src/widgets/common/app_button.dart';
import 'package:test_app/src/widgets/common/app_list_title.dart';
import 'package:test_app/src/widgets/common/app_loader.dart';
import 'package:test_app/src/widgets/common/app_text_field.dart';
import 'package:test_app/src/widgets/common/error_state.dart';
import 'package:test_app/src/widgets/common/styles.dart';

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

  Widget _buildProfileView() {
    return Column(
      spacing: spacing16,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: AppAvatar.avatarOrPlaceholder(widget.user, AvatarSize.large),
        ),
        Column(
          spacing: spacing8,
          children: [
            Text(
              'Name:',
              style: TextStyle(
                fontSize: h3Size,
                fontWeight: h3Weight,
                color: DarkColor.darkest.color,
              ),
            ),
            Text(
              widget.user.name,
              style: TextStyle(
                fontSize: bMSize,
                fontWeight: bMWeight,
                color: DarkColor.darkest.color,
              ),
            ),
          ],
        ),
        Column(
          spacing: spacing8,
          children: [
            Text(
              'Handle:',
              style: TextStyle(
                fontSize: h3Size,
                fontWeight: h3Weight,
                color: DarkColor.darkest.color,
              ),
            ),
            if (widget.user.handle.isNotEmpty)
              Text(
                '@${widget.user.handle}',
                style: TextStyle(
                  fontSize: bMSize,
                  fontWeight: bMWeight,
                  color: DarkColor.darkest.color,
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
      child: Column(
        spacing: spacing16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppButtonPrimary(
                text: 'Pick Avatar',
                onPressed: () async {
                  await context.appController.uploadUserAvatar();
                },
              ),
              AppAvatar.avatarOrPlaceholder(widget.user, AvatarSize.medium),
            ],
          ),
          Text(
            'Name:',
            style: TextStyle(
              fontSize: h3Size,
              fontWeight: h3Weight,
              color: DarkColor.darkest.color,
            ),
          ),
          AppTextField(
            placeholder: 'Enter your name',
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name cannot be empty';
              }
              return null;
            },
            onChanged: (_) => _validateForm(),
          ),
          Text(
            'Handle:',
            style: TextStyle(
              fontSize: h3Size,
              fontWeight: h3Weight,
              color: DarkColor.darkest.color,
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
                    message: 'Error loading users: ${asyncSnapshot.error}',
                  ),
                );
              }
              final users = asyncSnapshot.data ?? [];
              return AppTextField(
                placeholder: 'Enter your handle',
                controller: _handleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }
                  if (value.contains(' ')) {
                    return 'Handle cannot contain spaces';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                    return 'Handle can only contain letters, numbers, and underscores';
                  }
                  final isHandleTaken = users.any(
                    (user) =>
                        user.handle.toLowerCase() ==
                            _handleController.text.toLowerCase() &&
                        user.id != widget.user.id,
                  );
                  if (isHandleTaken) {
                    return 'Handle is already taken';
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
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(spacing32),
        width: MediaQuery.sizeOf(context).width * 0.8,
        height: MediaQuery.sizeOf(context).height * 0.8,
        decoration: BoxDecoration(
          color: LightColor.lightest.color,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            spacing: spacing8,
            children: [
              AppListTitle(
                title: switch (widget.mode) {
                  UserProfileMode.view => 'User Profile',
                  UserProfileMode.edit => 'Edit Profile',
                },
              ),
              switch (widget.mode) {
                UserProfileMode.view => _buildProfileView(),
                UserProfileMode.edit => _buildProfileEdit(),
              },
              Spacer(),
              if (widget.mode == UserProfileMode.edit)
                ValueListenableBuilder(
                  valueListenable: _isFormValid,
                  builder: (context, value, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: AppButtonPrimary(
                        text: 'Save',
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
                                context.pop();
                              }
                            : null,
                      ),
                    );
                  },
                ),
              SizedBox(
                width: double.infinity,
                child: AppButtonPrimary(
                  text: 'Close',
                  onPressed: () {
                    context.pop();
                  },
                ),
              ),
            ],
          ),
        ),
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
