import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';

const double radioButtonSmallSize = 0.8;
const double radioButtonMediumSize = 1.2;
const double radioButtonLargeSize = 1.6;

class AppRadioButton<T> extends StatelessWidget {
  final T value;
  final double size;
  final bool enabled;

  const AppRadioButton({
    super.key,
    required this.value,
    this.size = radioButtonSmallSize,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: size,
      child: Radio<T>(
        value: value,
        enabled: enabled,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side:
            WidgetStateBorderSide.fromMap(<WidgetStatesConstraint, BorderSide?>{
              WidgetState.disabled: BorderSide(
                color:
                    Theme.of(
                      context,
                    ).extension<AppTheme>()?.backgroundMediumColor ??
                    const Color(0xFFE8E9F1),
                width: 1.5,
              ),
              WidgetState.selected: BorderSide(
                color:
                    Theme.of(
                      context,
                    ).extension<AppTheme>()?.highlightDarkestColor ??
                    const Color(0xFF006FFD),
                width: 5.5,
              ),
              WidgetState.any: BorderSide(
                color:
                    Theme.of(
                      context,
                    ).extension<AppTheme>()?.backgroundWeakestColor ??
                    const Color(0xFFC5C6CC),
                width: 1.5,
              ),
            }),
        fillColor: WidgetStateProperty.fromMap(<WidgetStatesConstraint, Color?>{
          WidgetState.disabled: Theme.of(
            context,
          ).extension<AppTheme>()?.backgroundMediumColor,
          WidgetState.selected: Theme.of(
            context,
          ).extension<AppTheme>()?.highlightDarkestColor,
          WidgetState.any: Theme.of(
            context,
          ).extension<AppTheme>()?.backgroundStrongestColor,
        }),
        innerRadius: WidgetStatePropertyAll(0),
      ),
    );
  }
}

class AppRadioTile<T> extends StatelessWidget {
  final T value;
  final String title;
  final double buttonSize;
  final bool enabled;
  final ValueChanged<T>? onChanged;

  const AppRadioTile({
    super.key,
    required this.value,
    required this.title,
    this.buttonSize = radioButtonSmallSize,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled && onChanged != null ? () => onChanged!(value) : null,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing8,
        ),
        backgroundColor: Theme.of(
          context,
        ).extension<AppTheme>()?.backgroundStrongestColor,
        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: h4Size,
              fontWeight: h4Weight,
              color: Theme.of(
                context,
              ).extension<AppTheme>()?.foregroundStrongestColor,
              fontFamily: GoogleFonts.inter().fontFamily,
              decoration: TextDecoration.none,
            ),
          ),
          AppRadioButton(value: value, size: buttonSize, enabled: enabled),
        ],
      ),
    );
  }
}
