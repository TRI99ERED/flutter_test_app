# Copilot Workspace Instructions for test_app

## Overview
This workspace is a Flutter application with Firebase integration and custom icon font generation. It follows standard Flutter project structure with some custom scripts and conventions.

## Build & Run
- **Flutter app:**
  - Run: `flutter run`
  - Build: `flutter build <platform>`
- **Icon font generation:**
  - Prerequisite: Node.js
  - Install dependencies: `npm install`
  - Generate icons: `npm run generate-icons`
- **Firebase Functions:**
  - Located in `functions/`
  - Emulate: `npm run serve` (in `functions/`)
  - Deploy: `npm run deploy` (in `functions/`)

## Key Conventions
- **SVG icons:** Place in `assets/images/icons/` and run the generator script.
- **Font assets:** Managed in `pubspec.yaml` under `flutter/fonts`.
- **Localization:** Uses `l10n.yaml` and `lib/l10n/` for i18n.
- **Themes:** Defined in `lib/src/features/themes/`.
- **Routing:** Uses custom router in `lib/src/router/`.
- **App entry:** Main logic in `lib/main.dart`.

## Documentation
- See `README.md` for icon font workflow and general getting started.
- No additional docs or contributing guides found.

## Agent Guidance
- **Link, don't embed:** Reference `README.md` and code for details, avoid duplicating instructions.
- **ApplyTo:** These instructions apply to the entire workspace.

---

## Example Prompts
- "How do I add a new icon to the app?"
- "How do I run the app with Firebase emulators?"
- "Where is theming configured?"

## Next Steps
- Consider adding `CONTRIBUTING.md` for contribution guidelines.
- Add architecture docs if the project grows in complexity.
