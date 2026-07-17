# Contributing to HapoPay

Thank you for your interest in contributing to HapoPay! This document provides guidelines and standards for contributing to this Flutter mobile application.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [Commit Message Convention](#commit-message-convention)
- [Architecture Guidelines](#architecture-guidelines)
- [Documentation](#documentation)

---

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md) before contributing.

---

## Getting Started

### Prerequisites

- **Flutter SDK**: 3.22.0+
- **Dart**: 3.4.0+
- **Android Studio** / **VS Code** with Flutter/Dart plugins
- **Xcode 15+** (macOS only, for iOS development)
- **Django Backend** running locally or accessible via network

### Initial Setup

```bash
# 1. Fork and clone the repository
git clone https://github.com/<your-username>/hapopay_flutter.git
cd hapopay_flutter

# 2. Add upstream remote
git remote add upstream https://github.com/HapoTV/hapopay_flutter.git

# 3. Install dependencies
flutter pub get

# 4. Configure environment (optional)
cp .env.example .env.dev
# Edit .env.dev with your credentials

# 5. Generate code (Riverpod)
flutter pub run build_runner build --delete-conflicting-outputs

# 6. Verify setup
flutter doctor
flutter run --dart-define-from-file=.env.dev
```

---

## Development Workflow

### Branch Strategy

| Branch Type | Prefix | Purpose |
|-------------|--------|---------|
| Feature | `feat/` | New functionality |
| Bug Fix | `fix/` | Bug fixes |
| Chore | `chore/` | Maintenance, tooling, dependencies |
| Documentation | `docs/` | Documentation only |
| Refactor | `refactor/` | Code restructuring |
| Test | `test/` | Test additions/improvements |

**Branch naming**: `<type>/<issue-number>-<short-description>`

Examples:
- `feat/42-add-dark-mode-toggle`
- `fix/15-qr-scanner-permission-crash`
- `chore/8-update-dependencies`

### Workflow Steps

1. **Sync with upstream**
   ```bash
   git fetch upstream
   git checkout main
   git rebase upstream/main
   ```

2. **Create feature branch**
   ```bash
   git checkout -b feat/42-add-dark-mode-toggle
   ```

3. **Develop with incremental commits**
   - Write code
   - Run tests locally
   - Commit with conventional messages

4. **Push and open PR**
   ```bash
   git push origin feat/42-add-dark-mode-toggle
   ```

---

## Code Standards

### Language & Framework

- **Dart**: Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- **Flutter**: Follow [Flutter style guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- **State Management**: Riverpod (code generation via `riverpod_generator`)
- **Navigation**: GoRouter
- **Networking**: Dio with interceptors
- **Storage**: `flutter_secure_storage` for secrets, `shared_preferences` for settings

### Formatting & Linting

```bash
# Format code
dart format .

# Analyze (run before committing)
flutter analyze

# Run linter with strict rules
dart analyze --fatal-infos
```

**Configuration**: `analysis_options.yaml` defines project rules. Do not modify without team consensus.

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Files | snake_case | `rewards_repository.dart` |
| Classes/Types | PascalCase | `RewardsRepository` |
| Variables/Functions | camelCase | `fetchRewards()` |
| Constants | lowerCamelCase | `defaultTimeout` |
| Private members | `_prefix` | `_apiClient` |
| Riverpod Providers | `<name>Provider` | `rewardsProvider` |

### Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Root application widget (MaterialApp config)
├── core/                        # App-wide infrastructure (no dependencies on features)
│   ├── config/                  # Environment/config wiring
│   ├── network/                 # Dio client + auth interceptors/events
│   ├── router/                  # GoRouter setup
│   ├── services/                # Shared services (e.g., biometrics)
│   ├── storage/                 # Secure/local storage abstractions
│   └── theme/                   # Global theming
├── features/                    # Feature modules
│   ├── auth/
│   │   ├── data/               # DTOs + datasources + implementations
│   │   ├── domain/             # Entities + repository interfaces
│   │   ├── models/             # Feature models (if applicable)
│   │   ├── presentation/      # Screens + Riverpod providers/state
│   │   └── repository/         # Repository interfaces/abstractions + impls
│   ├── parent/
│   │   ├── models/
│   │   ├── presentation/
│   │   └── repository/
│   └── student/
│       ├── models/
│       ├── presentation/
│       ├── providers/
│       └── repository/
└── shared/                      # Reusable cross-feature widgets/services
    ├── services/
    └── widgets/
```


---

## Testing Requirements

### Test Types

| Type | Location | Command | Coverage Target |
|------|----------|---------|-----------------|
| Unit | `test/unit/` | `flutter test test/unit/` | ≥ 80% |
| Widget | `test/widget/` | `flutter test test/widget/` | Key flows |
| Integration | `integration_test/` | `flutter test integration_test/` | Critical paths |

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Run specific test file
flutter test test/unit/rewards_repository_test.dart
```

### Test Guidelines

- Write tests for new features and bug fixes
- Use `mocktail` for mocking dependencies
- Test business logic in isolation (unit tests)
- Test UI behavior and state changes (widget tests)
- Integration tests for critical user flows (auth, payments)
- Follow AAA pattern: Arrange, Act, Assert

---

## Pull Request Process

### Before Opening a PR

- [ ] Code compiles: `flutter analyze` passes
- [ ] Tests pass: `flutter test` passes
- [ ] Code formatted: `dart format .` applied
- [ ] Branch rebased on latest `main`
- [ ] Commit messages follow convention
- [ ] Self-review completed

### PR Requirements

1. **Title**: Use conventional commit format (see below)
2. **Description**: Include:
   - What changes were made
   - Why the changes were necessary
   - How to test the changes
   - Related issue number (e.g., `Closes #42`)
3. **Checklist**:
   - [ ] Tests added/updated
   - [ ] Documentation updated (if applicable)
   - [ ] No breaking changes (or marked `BREAKING` in title)
   - [ ] Screenshots for UI changes
4. **Review**: At least 1 maintainer approval required
5. **CI**: All checks must pass

### PR Title Format

```
<type>(<scope>): <description>

#<issue-number>
```

Examples:
- `feat(rewards): add progress bar for achievement tiers #42`
- `fix(auth): handle token refresh on 401 response #15`
- `BREAKING: feat(api): change JWT token structure #8`

---

## Commit Message Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, missing semicolons, etc. |
| `refactor` | Code restructuring |
| `test` | Adding/updating tests |
| `chore` | Maintenance, dependencies, tooling |
| `perf` | Performance improvement |
| `ci` | CI/CD changes |

### Examples

```bash
# Feature
feat(auth): add biometric login support

# Bug fix
fix(qr): handle camera permission denial gracefully

# With breaking change
BREAKING: feat(api): change JWT token structure

# With body and footer
feat(rewards): add achievement badge system

Implement tiered achievement badges with progress tracking.
Integrates with backend /api/rewards/achievements endpoint.

Closes #101
```

---

## Architecture Guidelines

### Clean Architecture Layers

Each feature follows clean architecture:

```
features/<feature>/
├── data/
│   ├── datasources/      # Remote/local data sources
│   ├── repositories/     # Repository implementations
│   └── models/           # DTOs, API models
├── domain/
│   ├── entities/         # Business entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Business logic
└── presentation/
    ├── providers/        # Riverpod providers
    ├── screens/          # Full-screen UI
    └── widgets/          # Reusable UI components
```

### State Management (Riverpod)

- Use code-generated providers (`@riverpod`)
- Prefer `AsyncValue` for async state
- Separate business logic into `AsyncNotifier` or `Notifier`
- Keep UI widgets stateless when possible

### Dependency Injection

- Define providers in `presentation/providers/`
- Use `ProviderScope` at app root
- Override in tests with `ProviderScope(overrides: [...])`

---

## Documentation

### Required Documentation

- **New features**: Update `docs/FEATURES.md`
- **Architecture changes**: Update `docs/ARCHITECTURE.md`
- **Setup changes**: Update `docs/SETUP.md`
- **Design tokens**: Update `docs/DESIGNS.md`

### Code Documentation

- Document public APIs with `///` comments
- Complex logic: inline comments explaining *why*
- Riverpod providers: document purpose and dependencies

---

## Getting Help

- **Issues**: Check `issues.md` for existing tasks
- **Discussions**: Use GitHub Discussions for questions
- **Maintainers**: Tag `@HapoTV` in PRs for review

---

## Recognition

Contributors are recognized in:
- `CONTRIBUTORS.md` (auto-generated from commits)
- Release notes for significant contributions

---

Happy coding!^^