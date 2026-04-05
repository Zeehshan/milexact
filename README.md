# MilExact

MilExact is a production-ready Flutter mobile app for offline scope-based distance calculation. It uses GetX for routing, state management, and dependency injection, with Hive-backed local persistence for presets, settings, and range card entries.

## Features

- Fully offline on Android and iOS
- Metric and imperial ranging workflows
- Target presets grouped by category
- Manual target entry with unit conversion
- Local range card with editable DOPE and wind fields
- Dark tactical UI optimized for fast field use
- Seeded default categories and presets on first launch

## Tech Stack

- Flutter
- GetX
- Hive

## Project Structure

```text
lib/
  app/
    bindings/
    routes/
    theme/
  data/
    local/
    models/
    repositories/
  modules/
    calculator/
    presets/
    range_card/
    settings/
  services/
  shared/
```

## Running the App

1. Install Flutter 3.41.x or newer with Dart 3.11.x.
2. Fetch packages:

   ```bash
   flutter pub get
   ```

3. Run on a simulator or device:

   ```bash
   flutter run
   ```

## Verification

Use these commands during development:

```bash
dart format lib test
flutter analyze
flutter test
```

## Notes

- Formula logic is centralized in `lib/services/calculation_service.dart`.
- Unit conversion is centralized in `lib/services/unit_conversion_service.dart`.
- All app data is stored locally with no backend, sync, or authentication.
