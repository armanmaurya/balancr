# Balancr - AI Coding Instructions

Balancr is a Flutter expense-sharing app for managing group finances and tracking shared expenses.

## Architecture Overview

This app follows **Clean Architecture** with **feature-based organization**:

- **`lib/features/`**: Domain-driven modules (`auth/`, `contacts/`, `transaction/`, `settings/`, `splash/`)
  - Each feature contains: `data/`, `domain/`, `presentation/` subdirectories
  - Domain layer: `entities/`, `repositories/` 
  - Presentation layer: `pages/`, `providers/`, `widgets/`

- **`lib/core/router/`**: GoRouter-based navigation using `app_router.dart` and `routes.dart`

- **`lib/providers/`**: Global state management (mix of Provider and Riverpod)
  - `theme_provider.dart`, `language_provider.dart`, `ledger_provider.dart`
  - Note: Project uses **both Provider and Riverpod** patterns

- **`lib/models/`**: Shared data models (`person.dart`, `transaction.dart`)

## Key Dependencies & Integrations

- **Firebase**: Authentication, Firestore for data persistence
- **State Management**: Provider + Riverpod hybrid approach 
- **Navigation**: GoRouter with declarative routing
- **Localization**: flutter_localizations with `l10n/` directory
- **UI**: Material Design with custom theming support

## Development Patterns

### State Management Strategy
```dart
// Global state: Provider pattern
ChangeNotifierProvider(create: (_) => ThemeProvider(isDark: isDark))

// Feature state: Riverpod providers
ProviderScope(child: MultiProvider(...))
```

### Firebase Integration
- Initialize in `main.dart` with `firebase_options.dart`
- Authentication through `features/auth/`
- Firestore data models handle multiple date formats (DateTime, int, String)

### Model Conventions
```dart
// Models support multiple data source formats
factory Transaction.fromMap(Map<String, dynamic> map, {required String id}) {
  // Handles DateTime, int (milliseconds), String parsing
}
```

### Navigation Pattern
- Centralized routing in `core/router/app_router.dart`
- Route constants in `routes.dart`
- Uses GoRouter for declarative navigation

## Essential Commands

```bash
# Setup
flutter pub get
flutter run

# Firebase (if configuration changes)
flutterfire configure

# Build for Android
flutter build apk
flutter run -d android

# Localization
flutter gen-l10n
```

## Project-Specific Notes

- **Package name discrepancy**: pubspec.yaml uses `ledger_book_flutter` but project is called `balancr`
- **Dual state management**: Don't mix Provider and Riverpod in same feature - follow existing patterns
- **Firebase setup**: Android-only configuration (iOS/web not configured)
- **Contacts integration**: Uses `flutter_contacts` with permission handling
- **Theme persistence**: Stored in SharedPreferences, loaded at app startup

## File Organization Conventions

- Feature modules follow strict data/domain/presentation separation
- Shared models in top-level `models/` directory
- Global providers in `providers/` directory
- Navigation logic centralized in `core/router/`
- Assets organized by type: `assets/icons/`, `assets/illustrations/`

When adding new features, follow the established Clean Architecture pattern and maintain the existing state management approach within each feature boundary.