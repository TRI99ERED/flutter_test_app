import 'dart:ui';

enum HighlightColor {
  darkest(Color.fromARGB(255, 0x00, 0x6F, 0xFD)),
  dark(Color.fromARGB(255, 0x28, 0x97, 0xFF)),
  medium(Color.fromARGB(255, 0x6F, 0xBA, 0xFF)),
  light(Color.fromARGB(255, 0xB4, 0xDB, 0xFF)),
  lightest(Color.fromARGB(255, 0xEA, 0xF2, 0xFF));

  final Color color;

  const HighlightColor(this.color);
}

enum LightColor {
  darkest(Color.fromARGB(255, 0xC5, 0xC6, 0xCC)),
  dark(Color.fromARGB(255, 0xD4, 0xD6, 0xDD)),
  medium(Color.fromARGB(255, 0xE8, 0xE9, 0xF1)),
  light(Color.fromARGB(255, 0xF8, 0xF9, 0xFE)),
  lightest(Color.fromARGB(255, 0xFF, 0xFF, 0xFF));

  final Color color;

  const LightColor(this.color);
}

enum DarkColor {
  darkest(Color.fromARGB(255, 0x1F, 0x20, 0x24)),
  dark(Color.fromARGB(255, 0x2F, 0x30, 0x36)),
  medium(Color.fromARGB(255, 0x49, 0x4A, 0x50)),
  light(Color.fromARGB(255, 0x71, 0x72, 0x7A)),
  lightest(Color.fromARGB(255, 0x8F, 0x90, 0x98));

  final Color color;

  const DarkColor(this.color);
}

enum SuccessColor {
  dark(Color.fromARGB(255, 0x29, 0x82, 0x67)),
  medium(Color.fromARGB(255, 0x3A, 0xC0, 0xA0)),
  light(Color.fromARGB(255, 0xE7, 0xF4, 0xE8));

  final Color color;

  const SuccessColor(this.color);
}

enum WarningColor {
  dark(Color.fromARGB(255, 0xE8, 0x63, 0x39)),
  medium(Color.fromARGB(255, 0xFF, 0xB3, 0x7C)),
  light(Color.fromARGB(255, 0xFF, 0xF4, 0xE4));

  final Color color;

  const WarningColor(this.color);
}

enum ErrorColor {
  dark(Color.fromARGB(255, 0xED, 0x32, 0x41)),
  medium(Color.fromARGB(255, 0xFF, 0x61, 0x6D)),
  light(Color.fromARGB(255, 0xFF, 0xE2, 0xE5));

  final Color color;

  const ErrorColor(this.color);
}

const h1Size = 24.0;
const h2Size = 18.0;
const h3Size = 16.0;
const h4Size = 14.0;
const h5Size = 12.0;

const h1Weight = FontWeight.w800;
const h2Weight = FontWeight.w800;
const h3Weight = FontWeight.w800;
const h4Weight = FontWeight.bold;
const h5Weight = FontWeight.bold;

const bXLSize = 18.0;
const bLSize = 16.0;
const bMSize = 14.0;
const bSSize = 12.0;
const bXSSize = 10.0;

const bXLWeight = FontWeight.normal;
const bLWeight = FontWeight.normal;
const bMWeight = FontWeight.normal;
const bSWeight = FontWeight.normal;
const bXSWeight = FontWeight.w500;

const aLSize = 14.0;
const aMSize = 12.0;
const aSSize = 10.0;

const aLWeight = FontWeight.w600;
const aMWeight = FontWeight.w600;
const aSWeight = FontWeight.w600;

const cMSize = 10.0;

const cMWeight = FontWeight.w600;

// Spacing tokens
const spacing2 = 2.0;
const spacing4 = 4.0;
const spacing6 = 6.0;
const spacing8 = 8.0;
const spacing9 = 9.0;
const spacing10 = 10.0;
const spacing12 = 12.0;
const spacing16 = 16.0;
const spacing24 = 24.0;
const spacing32 = 32.0;
const spacing40 = 40.0;
