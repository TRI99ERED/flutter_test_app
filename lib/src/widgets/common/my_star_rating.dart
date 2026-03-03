import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MyStarRating extends StatefulWidget {
  final int rating;
  final ValueChanged<int>? onRatingChanged;

  const MyStarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  }) : assert(rating >= 0 && rating <= 5, 'Rating must be between 0 and 5');

  @override
  State<MyStarRating> createState() => _MyStarRatingState();
}

class _MyStarRatingState extends State<MyStarRating> {
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return IconButton(
            icon: Icon(
              index < _rating ? AppIcons.starFilled : AppIcons.starOutlined,
              color: index < _rating
                  ? HighlightColor.darkest.color
                  : LightColor.dark.color,
              size: 24,
            ),
            onPressed: widget.onRatingChanged != null
                ? () {
                    if (index == _rating - 1) {
                      setState(() {
                        _rating = 0;
                      });
                    } else {
                      setState(() {
                        _rating = index + 1;
                      });
                    }
                    widget.onRatingChanged!(index + 1);
                  }
                : null,
          );
        }),
      ),
    );
  }
}
