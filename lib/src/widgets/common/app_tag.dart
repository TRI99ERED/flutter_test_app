import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppTag extends StatefulWidget {
  final String? text;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final bool isSelected;
  final VoidCallback? onPressed;

  const AppTag({
    super.key,
    this.text,
    this.leftIcon,
    this.rightIcon,
    this.isSelected = false,
    this.onPressed,
  }) : assert(
         text != null || leftIcon != null || rightIcon != null,
         'At least one of text, leftIcon, or rightIcon must be provided',
       );

  @override
  State<AppTag> createState() => _AppTagState();
}

class _AppTagState extends State<AppTag> {
  final _isSelected = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _isSelected.value = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isSelected,
      builder: (context, value, child) {
        return FilledButton(
          onPressed: () {
            _isSelected.value = !_isSelected.value;
            if (widget.onPressed != null) {
              widget.onPressed!();
            }
          },
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(horizontal: spacing8, vertical: spacing6),
            ),
            backgroundColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (_isSelected.value) {
                return HighlightColor.darkest.color;
              }
              return HighlightColor.lightest.color;
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (_isSelected.value) {
                return LightColor.lightest.color;
              }
              return HighlightColor.darkest.color;
            }),
            shadowColor: WidgetStateProperty.all(Colors.transparent),
            shape: WidgetStateProperty.all(const StadiumBorder()),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leftIcon != null) ...[
                Icon(widget.leftIcon!, size: 16),
                if (widget.text != null || widget.rightIcon != null)
                  SizedBox(width: spacing4),
              ],
              if (widget.text != null) ...[
                Text(
                  widget.text!,
                  style: const TextStyle(
                    fontSize: cMSize,
                    fontWeight: cMWeight,
                  ),
                ),
                if (widget.rightIcon != null) SizedBox(width: spacing4),
              ],
              if (widget.rightIcon != null) Icon(widget.rightIcon!, size: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _isSelected.dispose();
    super.dispose();
  }
}
