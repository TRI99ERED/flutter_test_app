import 'package:flutter/material.dart';

class AppTheme extends ThemeExtension<AppTheme> {
  final Color highlightDarkestColor;
  final Color highlightDarkColor;
  final Color highlightMediumColor;
  final Color highlightLightColor;
  final Color highlightLightestColor;
  final Color backgroundStrongestColor;
  final Color backgroundStrongColor;
  final Color backgroundMediumColor;
  final Color backgroundWeakColor;
  final Color backgroundWeakestColor;
  final Color foregroundWeakestColor;
  final Color foregroundWeakColor;
  final Color foregroundMediumColor;
  final Color foregroundStrongColor;
  final Color foregroundStrongestColor;
  final Color successDarkColor;
  final Color successMediumColor;
  final Color successLightColor;
  final Color warningDarkColor;
  final Color warningMediumColor;
  final Color warningLightColor;
  final Color errorDarkColor;
  final Color errorMediumColor;
  final Color errorLightColor;

  const AppTheme({
    this.highlightDarkestColor = const Color(0xFF006FFD),
    this.highlightDarkColor = const Color(0xFF2897FF),
    this.highlightMediumColor = const Color(0xFF6FBAFF),
    this.highlightLightColor = const Color(0xFFB4DBFF),
    this.highlightLightestColor = const Color(0xFFEAF2FF),
    this.backgroundWeakestColor = const Color(0xFFC5C6CC),
    this.backgroundWeakColor = const Color(0xFFD4D6DD),
    this.backgroundMediumColor = const Color(0xFFE8E9F1),
    this.backgroundStrongColor = const Color(0xFFF8F9FE),
    this.backgroundStrongestColor = const Color(0xFFFFFFFF),
    this.foregroundStrongestColor = const Color(0xFF1F2024),
    this.foregroundStrongColor = const Color(0xFF2F3036),
    this.foregroundMediumColor = const Color(0xFF494A50),
    this.foregroundWeakColor = const Color(0xFF71727A),
    this.foregroundWeakestColor = const Color(0xFF8F9098),
    this.successDarkColor = const Color(0xFF298267),
    this.successMediumColor = const Color(0xFF3AC0A0),
    this.successLightColor = const Color(0xFFE7F4E8),
    this.warningDarkColor = const Color(0xFFE86339),
    this.warningMediumColor = const Color(0xFFFFB37C),
    this.warningLightColor = const Color(0xFFFFF4E4),
    this.errorDarkColor = const Color(0xFFED3241),
    this.errorMediumColor = const Color(0xFFFF616D),
    this.errorLightColor = const Color(0xFFFFE2E5),
  });

  @override
  AppTheme copyWith({
    Color? highlightDarkestColor,
    Color? highlightDarkColor,
    Color? highlightMediumColor,
    Color? highlightLightColor,
    Color? highlightLightestColor,
    Color? backgroundStrongestColor,
    Color? backgroundStrongColor,
    Color? backgroundMediumColor,
    Color? backgroundWeakColor,
    Color? backgroundWeakestColor,
    Color? foregroundWeakestColor,
    Color? foregroundWeakColor,
    Color? foregroundMediumColor,
    Color? foregroundStrongColor,
    Color? foregroundStrongestColor,
    Color? successDarkColor,
    Color? successMediumColor,
    Color? successLightColor,
    Color? warningDarkColor,
    Color? warningMediumColor,
    Color? warningLightColor,
    Color? errorDarkColor,
    Color? errorMediumColor,
    Color? errorLightColor,
  }) {
    return AppTheme(
      highlightDarkestColor:
          highlightDarkestColor ?? this.highlightDarkestColor,
      highlightDarkColor: highlightDarkColor ?? this.highlightDarkColor,
      highlightMediumColor: highlightMediumColor ?? this.highlightMediumColor,
      highlightLightColor: highlightLightColor ?? this.highlightLightColor,
      highlightLightestColor:
          highlightLightestColor ?? this.highlightLightestColor,
      backgroundStrongestColor:
          backgroundStrongestColor ?? this.backgroundStrongestColor,
      backgroundStrongColor:
          backgroundStrongColor ?? this.backgroundStrongColor,
      backgroundMediumColor:
          backgroundMediumColor ?? this.backgroundMediumColor,
      backgroundWeakColor: backgroundWeakColor ?? this.backgroundWeakColor,
      backgroundWeakestColor:
          backgroundWeakestColor ?? this.backgroundWeakestColor,
      foregroundWeakestColor:
          foregroundWeakestColor ?? this.foregroundWeakestColor,
      foregroundWeakColor: foregroundWeakColor ?? this.foregroundWeakColor,
      foregroundMediumColor:
          foregroundMediumColor ?? this.foregroundMediumColor,
      foregroundStrongColor:
          foregroundStrongColor ?? this.foregroundStrongColor,
      foregroundStrongestColor:
          foregroundStrongestColor ?? this.foregroundStrongestColor,
      successDarkColor: successDarkColor ?? this.successDarkColor,
      successMediumColor: successMediumColor ?? this.successMediumColor,
      successLightColor: successLightColor ?? this.successLightColor,
      warningDarkColor: warningDarkColor ?? this.warningDarkColor,
      warningMediumColor: warningMediumColor ?? this.warningMediumColor,
      warningLightColor: warningLightColor ?? this.warningLightColor,
      errorDarkColor: errorDarkColor ?? this.errorDarkColor,
      errorMediumColor: errorMediumColor ?? this.errorMediumColor,
      errorLightColor: errorLightColor ?? this.errorLightColor,
    );
  }

  @override
  AppTheme lerp(ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) {
      return this;
    }
    return AppTheme(
      highlightDarkestColor: Color.lerp(
        highlightDarkestColor,
        other.highlightDarkestColor,
        t,
      )!,
      highlightDarkColor: Color.lerp(
        highlightDarkColor,
        other.highlightDarkColor,
        t,
      )!,
      highlightMediumColor: Color.lerp(
        highlightMediumColor,
        other.highlightMediumColor,
        t,
      )!,
      highlightLightColor: Color.lerp(
        highlightLightColor,
        other.highlightLightColor,
        t,
      )!,
      highlightLightestColor: Color.lerp(
        highlightLightestColor,
        other.highlightLightestColor,
        t,
      )!,
      backgroundStrongestColor: Color.lerp(
        backgroundStrongestColor,
        other.backgroundStrongestColor,
        t,
      )!,
      backgroundStrongColor: Color.lerp(
        backgroundStrongColor,
        other.backgroundStrongColor,
        t,
      )!,
      backgroundMediumColor: Color.lerp(
        backgroundMediumColor,
        other.backgroundMediumColor,
        t,
      )!,
      backgroundWeakColor: Color.lerp(
        backgroundWeakColor,
        other.backgroundWeakColor,
        t,
      )!,
      backgroundWeakestColor: Color.lerp(
        backgroundWeakestColor,
        other.backgroundWeakestColor,
        t,
      )!,
      foregroundWeakestColor: Color.lerp(
        foregroundWeakestColor,
        other.foregroundWeakestColor,
        t,
      )!,
      foregroundWeakColor: Color.lerp(
        foregroundWeakColor,
        other.foregroundWeakColor,
        t,
      )!,
      foregroundMediumColor: Color.lerp(
        foregroundMediumColor,
        other.foregroundMediumColor,
        t,
      )!,
      foregroundStrongColor: Color.lerp(
        foregroundStrongColor,
        other.foregroundStrongColor,
        t,
      )!,
      foregroundStrongestColor: Color.lerp(
        foregroundStrongestColor,
        other.foregroundStrongestColor,
        t,
      )!,
      successDarkColor: Color.lerp(
        successDarkColor,
        other.successDarkColor,
        t,
      )!,
      successMediumColor: Color.lerp(
        successMediumColor,
        other.successMediumColor,
        t,
      )!,
      successLightColor: Color.lerp(
        successLightColor,
        other.successLightColor,
        t,
      )!,
      warningDarkColor: Color.lerp(
        warningDarkColor,
        other.warningDarkColor,
        t,
      )!,
      warningMediumColor: Color.lerp(
        warningMediumColor,
        other.warningMediumColor,
        t,
      )!,
      warningLightColor: Color.lerp(
        warningLightColor,
        other.warningLightColor,
        t,
      )!,
      errorDarkColor: Color.lerp(errorDarkColor, other.errorDarkColor, t)!,
      errorMediumColor: Color.lerp(
        errorMediumColor,
        other.errorMediumColor,
        t,
      )!,
      errorLightColor: Color.lerp(errorLightColor, other.errorLightColor, t)!,
    );
  }
}

const appThemeLight = AppTheme();

const appThemeDark = AppTheme(
  backgroundStrongestColor: Color(0xFF1F2024),
  backgroundStrongColor: Color(0xFF2F3036),
  backgroundMediumColor: Color(0xFF494A50),
  backgroundWeakColor: Color(0xFF71727A),
  backgroundWeakestColor: Color(0xFF8F9098),
  foregroundWeakestColor: Color(0xFFC5C6CC),
  foregroundWeakColor: Color(0xFFD4D6DD),
  foregroundMediumColor: Color(0xFFE8E9F1),
  foregroundStrongColor: Color(0xFFF8F9FE),
  foregroundStrongestColor: Color(0xFFFFFFFF),
);
