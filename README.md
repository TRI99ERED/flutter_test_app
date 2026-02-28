# test_app

## Icon Font Generation

This project includes a helper script to convert a folder of SVG icons into a
TrueType font and generate a Dart class with all icon codes.

### Setup

Ensure Node.js is installed. Dependencies are managed via `package.json`:

```bash
npm install
```

### Adding new icons

1. Put `.svg` files in `assets/images/icons/`.
2. Run the generator:

   ```bash
   npm run generate-icons
   ```

3. Add the font assets entry in `pubspec.yaml` (already configured):

   ```yaml
   flutter:
     fonts:
       - family: AppIcons
         fonts:
           - asset: assets/fonts/AppIcons.ttf
   ```

4. Use icons in Dart: `Icon(AppIcons.your_icon_name)`.



A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
