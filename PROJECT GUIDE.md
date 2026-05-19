# 🗺️ Project Guide: Food Aid

Welcome to the Food Aid technical guide. This document provides an overview of the application's architecture, state management flow, and development guidelines to help you contribute effectively.

## 🏗️ Architectural Overview

Food Aid follows a **feature-first** and **layered** architecture pattern tailored for Flutter. The primary goal is separation of concerns, ensuring that UI components are decoupled from business logic and backend services.

### The Layers

1. **Presentation Layer (`screens/` & `widgets/`)**
   - Contains all the UI code built with Flutter widgets.
   - Listens to changes from the Providers.
   - **Rule:** No business logic or direct database calls should be made here.

2. **Business Logic Layer (`providers/`)**
   - Acts as the intermediary between the Presentation and Data layers.
   - Manages application state using the `provider` package.
   - Examples: `AuthProvider`, `DonationProvider`, `LogisticsProvider`.

3. **Data/Service Layer (`services/`)**
   - Handles all interactions with external APIs and Firebase.
   - Contains repository classes that perform CRUD operations on Firestore.
   - **Rule:** Data should be returned to the Providers as parsed Dart Models, not raw JSON/Maps.

4. **Domain Layer (`models/`)**
   - Contains strongly-typed data models.
   - Uses `fromJson` and `toJson` factory methods for serialization.
   - Examples: `UserModel`, `DonationModel`, `EmergencyRequestModel`.

## 🚦 Routing Strategy

The application uses `go_router` for robust, declarative routing, which is essential for handling Web URLs and deep linking seamlessly.

- **Role-Based Redirection:** `AppRouter` checks the user's authentication state and their designated role (Donor, NGO, Logistics, Admin) to redirect them to the correct dashboard upon login.
- **Guards:** Unauthenticated users attempting to access protected routes are automatically redirected to the Login/Onboarding screen.

## 🔄 State Management

We utilize `provider` for state management due to its simplicity and seamless integration with Flutter.

### Best Practices for Providers
- **Granularity:** Keep providers focused on specific domains (e.g., separate `AdminProvider` from `DonationProvider`).
- **`Consumer` Widget:** Prefer using the `Consumer` widget over `Provider.of(context)` when building UI to minimize unnecessary widget rebuilds.
- **State Initialization:** Avoid complex asynchronous initializations inside a Provider's constructor. Use an explicit initialization method called from the UI or Router.

## 🎨 Design System & Theming

- **Theme Provider:** The app supports dynamic switching between Light and Dark modes via `ThemeProvider`.
- **Constants:** All colors, typography (`google_fonts`), and dimensions are defined centrally in the `config/` directory. Avoid hardcoding hex colors or font sizes directly in widgets.
- **Responsiveness:** Ensure all screens use layout builders, `MediaQuery`, or flexible widgets to maintain usability across mobile and web platforms.

## 🛡️ Security & Rules

- **Firestore Rules:** The database is protected by granular Firestore rules (`firestore.rules`). Ensure you test rules thoroughly when modifying data structures.
- **Secrets:** Never commit API keys or sensitive credentials. Always use `.env` via `flutter_dotenv` or similar packages for managing secrets.

## 🚀 Deployment Checklist

Before creating a Pull Request or deploying:
1. **Analyze:** Run `flutter analyze` to ensure there are no linting errors.
2. **Format:** Run `flutter format .` to maintain consistent code style.
3. **Test:** Execute `flutter test` (if applicable) to verify core logic.
4. **Dry Run Web:** Run `flutter build web` to ensure web compilation succeeds.
