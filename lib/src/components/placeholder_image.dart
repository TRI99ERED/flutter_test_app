import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/placeholder_image.svg',
      width: 600,
      height: 600,
    );
  }
}
