import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:test_app/src/features/app/data/models/user_model.dart';
import 'package:test_app/src/widgets/common/placeholders.dart';

enum AvatarSize {
  small(40),
  medium(56),
  large(80);

  final double size;

  const AvatarSize(this.size);
}

enum AppAvatarType { raster, vector }

class AppAvatar extends StatelessWidget {
  final String imageUrl;
  final AppAvatarType type;
  final AvatarSize size;

  const AppAvatar({
    super.key,
    required this.imageUrl,
    this.type = AppAvatarType.raster,
    this.size = AvatarSize.small,
  });

  static Widget avatarOrPlaceholder(AuthorizedUser? user, AvatarSize size) {
    if (user == null) {
      return PlaceholderAvatar(size: size);
    }
    final avatarExtention = user.avatarUrl
        .split('?')
        .first
        .split('.')
        .last
        .toLowerCase();
    return user.avatarUrl != ''
        ? AppAvatar(
            imageUrl: user.avatarUrl,
            type: avatarExtention == 'svg'
                ? AppAvatarType.vector
                : AppAvatarType.raster,
            size: size,
          )
        : PlaceholderAvatar(size: size);
  }

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AppAvatarType.raster:
        return ClipRRect(
          borderRadius: BorderRadius.circular(switch (size) {
            AvatarSize.small => 16,
            AvatarSize.medium => 20,
            AvatarSize.large => 32,
          }),
          child: Image.network(
            imageUrl,
            width: size.size,
            height: size.size,
            fit: BoxFit.cover,
          ),
        );
      case AppAvatarType.vector:
        return ClipRRect(
          borderRadius: BorderRadius.circular(switch (size) {
            AvatarSize.small => 16,
            AvatarSize.medium => 20,
            AvatarSize.large => 32,
          }),
          child: SvgPicture.network(
            imageUrl,
            width: size.size,
            height: size.size,
            fit: BoxFit.cover,
          ),
        );
    }
  }
}
