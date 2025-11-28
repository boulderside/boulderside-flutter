# Repository Guidelines

## Project Structure & Module Organization
App logic lives in `lib/`, organized by feature modules under `lib/src/`. UI widgets, services, and providers should sit in their respective subfolders, while shared constants belong in `lib/core/`. Flutter integration scaffolding is split between `android/`, `ios/`, and `web/`. Tests mirror source placement under `test/`, and static assets (fonts, icons, mock JSON) stay in `assets/` with entries declared in `pubspec.yaml`. Treat `build/` as disposable output produced by Flutter tooling and keep it untracked in reviews.

## Build, Test, and Development Commands
- `flutter pub get` — sync Dart packages before coding or switching branches.
- `flutter run -d chrome` (or a device id) — start the dev server with hot reload.
- `flutter build apk --release` — produce a production binary; pair with environment configs in `lib/config/`.
- `flutter test` — execute the Dart test suite; add `--coverage` when validating reports for CI.
- `flutter analyze` — run static analysis to catch lint violations early.

## Coding Style & Naming Conventions
Follow the rules in `analysis_options.yaml`, which extend Flutter’s strict lint set. Format all Dart files with `dart format --fix .` before committing; the repo expects two-space indentation, trailing commas in multi-line literals, and descriptive camelCase for variables/functions. Widgets and providers use UpperCamelCase (`AccountSecurityScreen`, `AuthNotifier`). Keep file names in lowercase_with_underscores and align directory names with the feature or domain exposed in navigation routes.

## Testing Guidelines
Write widget tests alongside the feature in `test/<feature>/` and prefer `group()` blocks that mirror screen names (`group('AccountSecurityScreen', ...)`). Stub services with `mocktail` or fake repositories. Aim for critical flows (auth, payments, offline sync) to have at least one golden test or integration smoke in `test_driver/`. Run `flutter test --coverage` locally before opening PRs and attach notes for intentionally skipped cases.

## Commit & Pull Request Guidelines
Commits follow a Conventional Commit style observed in history (`feat: add phone auth #26`, `fix: correct token refresh`). Use the `type: scope` pattern plus linked issue tags. Each PR should target `develop`, describe the user-facing change, list test evidence, and include screenshots or screen recordings for UI modifications. Request review from a module owner, confirm CI status, and rebase if the branch diverges.

## Security & Configuration Tips
Never commit secrets; instead store API keys inside `.env` files excluded via `.gitignore`, then expose them through `--dart-define` flags. When handling authentication modules, verify that token refresh logic lives in secure service classes under `lib/core/security/` and avoid duplicating constants in feature modules.
