# CarRent Pro

CarRent Pro is a Flutter + Riverpod demo that lets users browse a curated fleet of vehicles, inspect car details, submit booking forms, and view a confirmation summary. It showcases reusable UI components, GoRouter-based navigation, mocked repositories, and Riverpod state management.

## Features

- Login screen with validation and mock authentication.
- Car catalogue sourced from a mock `CarRepository`.
- Detail page with hero image, specs grid, and booking CTA.
- Booking form with date picker, pickup location selector, personal info, summary card, and Riverpod-powered submission flow.
- Confirmation screen that renders the latest booking details (passed through router extras or pulled from provider history).
- Booking history list on the home screen driven by Riverpod state.

## Tech Stack

- Flutter 3.x
- Riverpod for state management
- GoRouter for navigation
- Google Fonts, Intl, Cached Network Image
- Share Plus for sharing confirmation details

## Getting Started

```bash
flutter pub get
flutter run
```

### Configure Emulator / Device

- Android: ensure an emulator or device is connected.
- Web: choose Chrome/Edge when prompted by `flutter run`.
- Desktop: enable desktop platforms with `flutter config --enable-windows-desktop` (optional).

## Project Structure

- `lib/main.dart` – app entrypoint wiring Riverpod + router.
- `lib/router/app_router.dart` – GoRouter setup and guards.
- `lib/providers/` – Riverpod providers/notifiers for cars, bookings, auth.
- `lib/models/` – Plain Dart data models (`Car`, `Booking`).
- `lib/screens/` – UI screens (login, car list/detail, booking form, confirmation).
- `lib/components/` – Reusable widgets (if added later).

## Testing & Linting

```bash
flutter test
flutter analyze
```

## Troubleshooting

- **NDK mismatch:** set `ndkVersion = "27.0.12077973"` inside `android/app/build.gradle.kts` if plugins demand it.
- **Hot reload issues:** run `flutter clean && flutter pub get` before re-running.
- **Missing assets/images:** ensure the URLs in `CarRepository` stay valid.

## Future Enhancements

- Replace mock repositories with an API layer.
- Add authentication persistence.
- Integrate payment flow and real-time availability.


