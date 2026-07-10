# Architecture & Folder Structure

This project follows a **Feature-First Clean Architecture**, heavily utilizing Riverpod for state management. This structure ensures high scalability, maintainability, and clear separation of concerns as the application grows.

## High-Level Structure

The `lib/` directory is the root of the source code. It is divided into three main areas, plus the application entry points.

```text
lib/
├── core/         # App-wide configurations, network clients, routers, and themes
├── features/     # Isolated, independent features (Feature-First architecture)
├── shared/       # Reusable components (widgets, utils, constants) across features
├── app.dart      # Root application widget (MaterialApp config)
└── main.dart     # Application entry point (initialization)
```

## Directory Responsibilities

### 1. `core/`
Contains foundational code that the rest of the application relies on. Nothing in `core` should depend on anything in `features`.

- `config/`: Environment configuration (e.g., API keys, environment variables).
- `network/`: Base API clients, Dio configurations, and interceptors.
- `router/`: GoRouter setup and route definitions.
- `theme/`: Global application themes, colors, and text styles.

### 2. `features/`
The heart of the application. Each major domain of the app gets its own folder here (e.g., `auth`, `parent`, `student`). Each feature acts as an independent mini-application with a strict, consistent internal structure.

**Standard Feature Internal Structure:**
```text
features/auth/
├── models/         # Data classes, DTOs, and serialization logic
├── presentation/   # UI components: Screens and widgets specific to this feature
├── providers/      # Riverpod providers handling business logic and state
└── repository/     # Data fetching logic, API calls, and local storage interactions
```
*Note: Even if a feature does not immediately require a `repository` or `models` folder, they are included as empty placeholders to maintain consistency and predictability.*

### 3. `shared/`
Contains code that is completely agnostic to any specific feature but is used across multiple features.

- `widgets/`: Reusable, generic UI components like `ActionCard`, custom buttons, or loading indicators.

## Dependency Rules

To keep the architecture clean and prevent spaghetti code:
1. **`core/`** and **`shared/`** can ONLY depend on third-party packages. They cannot depend on anything in `features/`.
2. **`features/`** can depend on `core/` and `shared/`.
3. **Features should not depend on other features.** If Feature A needs data from Feature B, that shared state or logic should be elevated to a global scope or handled via a shared repository, or they should communicate strictly through generic interfaces/providers rather than direct imports of screens or internal logic.
4. Within a feature: `presentation/` depends on `providers/` and `models/`. `providers/` depends on `repository/` and `models/`. `repository/` depends on `models/` and `core/network/`.

## Getting Started

1. When adding a new capability, first determine if it's a completely new **Feature**, or an extension of an existing one.
2. If new, create a new folder under `features/` (e.g. `features/payments/`) with the standard subfolders: `models`, `presentation`, `providers`, `repository`.
3. Keep UI minimal in logic. Delegate all business logic and state mutations to `providers/`.
