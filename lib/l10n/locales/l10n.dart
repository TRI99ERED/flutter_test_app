import 'package:flutter/material.dart';
import 'package:test_app/l10n/locales/app_localizations.dart';

export 'package:test_app/l10n/locales/app_localizations.dart';

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
