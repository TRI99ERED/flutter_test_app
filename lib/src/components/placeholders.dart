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

class PlaceholderAvatar extends StatelessWidget {
  const PlaceholderAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/placeholder_avatar.svg',
      width: 375,
      height: 375,
    );
  }
}
