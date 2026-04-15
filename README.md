# MilExact

MilExact is a fully offline Flutter mobile app for shooters who need fast field-ready ranging and reference tools. It uses GetX for routing, dependency injection, and controller state, with Hive-backed local persistence for presets, settings, DOPE libraries, range card entries, visual range cards, and local account sessions.

## Features

- Fully offline on Android and iOS
- Metric and imperial ranging workflows with centralized formula services
- MIL and MRAD reticle workflows with direct numeric entry and drag-based reticle measurement
- Quick presets grouped by category with editable metric and imperial dimensions
- Manual target size entry with width and height support
- Distance display in meters, yards, or both
- Local email/password authentication flow with offline session persistence
- Google and Apple sign-in hooks for custom API token exchange
- Local DOPE profile library with editable manual rows only
- Range card entries with manual DOPE, wind, placement, and terrain notes
- Visual range card with arc lines, terrain plotting, target markers, undo, and clear
- Dark tactical UI optimized for fast field use
- Seeded categories, presets, and a sample DOPE profile on first launch

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
    auth/
    dope/
    presets/
    range_card/
    visual_range_card/
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

4. On first launch the app seeds default categories, sample presets, and a sample DOPE profile automatically.

## Main Screens

- `Calculator`: reticle measurement, manual sizing, quick preset selection, and range result output
- `Authentication`: local sign in, sign up, forgot password, check email, and reset password flows
- `Quick Presets`: manage target categories and editable presets
- `DOPE Profiles`: store manual rifle/drop tables for later selection
- `Range Card`: save calculator results and edit field notes
- `Visual Range Card`: plot markers and terrain on a semi-circular tactical reference
- `Settings`: default units, reticle preferences, and live calculation behavior

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
- Reticle interaction state is isolated in `lib/services/reticle_measurement_service.dart`.
- Visual plotting helpers are isolated in `lib/services/visual_range_card_service.dart`.
- Email/password auth is stored on device. Google and Apple sign-in are wired through provider SDKs plus your custom auth API once `AUTH_API_BASE_URL` is configured.
- All app data is stored locally with no backend or cloud sync.
