import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/placeholder_image.svg',
      width: 375,
      height: 375,
    );
  }
}

class PlaceholderVideo extends StatelessWidget {
  const PlaceholderVideo({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/placeholder_video.svg',
      width: 375,
      height: 375,
    );
  }
}

enum AvatarSize {
  small(40),
  medium(56),
  large(80);

  final double size;

  const AvatarSize(this.size);
}

class PlaceholderAvatar extends StatelessWidget {
  final AvatarSize size;

  const PlaceholderAvatar({super.key, this.size = AvatarSize.large});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/placeholder_avatar.svg',
      width: size.size,
      height: size.size,
    );
  }
}
