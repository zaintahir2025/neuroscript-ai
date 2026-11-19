# Developer Environment Setup & Engineering Guidelines

This document provides setup instructions, architectural conventions, standard CLI commands, and release workflows for contributors and software engineers working on NeuroScript AI.

---

## 1. Prerequisites & Toolchain

Ensure your local workstation has the required SDK versions installed:

* **Flutter SDK:** `>=3.47.5` (Stable Channel)
* **Dart SDK:** `^3.13.4`
* **.NET SDK:** `10.0 LTS` (Required for building and testing the ASP.NET Core proxy)
* **Android Development:** Android Studio with Android SDK Platform 34+, Android SDK Build-Tools 34.0.0+, and NDK installed. Minimum supported deployment target is **API 24 (Android 7.0)**.
* **iOS Development (macOS host only):** Xcode 15+ with CocoaPods installed. Minimum supported deployment target is **iOS 14.0**.
* **Node.js & npm (optional):** Node 20+ for executing `markdownlint-cli` and `markdown-link-check`.

---

## 2. Initial Repository Setup

```bash
# 1. Clone the repository
git clone https://github.com/zaintahir2025/neuroscript-ai.git
cd neuroscript-ai

# 2. Fetch Flutter packages
flutter pub get

# 3. Generate Drift database and Riverpod boilerplate
dart run build_runner build --delete-conflicting-outputs

# 4. Verify environment health
flutter doctor
```

---

## 3. Standard Developer Commands

Always run these verification commands before creating a pull request or pushing commits:

```bash
# Format code across the repository
dart format .

# Static code analysis (enforces zero issues under strict rules)
flutter analyze

# Run the complete Flutter test suite (110 automated tests)
flutter test

# Build and test the backend ASP.NET Core proxy
dotnet build server/NeuroScriptProxy/NeuroScriptProxy.sln
dotnet test server/NeuroScriptProxy/NeuroScriptProxy.sln

# Lint markdown documentation
npx --yes markdownlint-cli README.md docs/*.md
```

---

## 4. How to Add a New Feature

Features follow a domain-driven, feature-first structure under `lib/features/<feature_name>/`:

```text
lib/features/<feature_name>/
├── controllers/          # Riverpod StateNotifier / Notifier classes
├── screens/              # Top-level screen widgets (invoked via GoRouter)
└── widgets/              # Reusable sub-widgets private to this feature
```

### Step-by-Step Implementation Workflow

1. **Define Schema & Drift Table (if persistence is required):**
   * Add table definitions in `lib/data/database/tables.dart`.
   * Re-run code generator: `dart run build_runner build --delete-conflicting-outputs`.
2. **Implement Domain Repository:**
   * Declare repository contracts in `lib/data/repositories/repository_interfaces.dart`.
   * Implement concrete logic in `lib/data/repositories/app_repositories.dart`.
3. **Expose Reactive State with Riverpod:**
   * Create a provider or `Notifier` in `lib/features/<feature_name>/controllers/`.
   * Use `ref.watch()` to consume streams from the Drift database repository.
4. **Build Accessible UI:**
   * Consume theme tokens from `Theme.of(context)` to respect active profiles (ADHD, Dyslexia, Autism).
   * Ensure minimum touch target size of $48 \times 48\text{ dp}$.
5. **Write Automated Tests:**
   * Create corresponding test files under `test/` mirroring `lib/` directory structure.
   * Add unit tests for controllers and widget tests for screens.

---

## 5. Branching Strategy & Git Commit Conventions

* **Main Branch (`main`):** Production-ready, passing all CI checks.
* **Feature Branches:** Use standard naming prefixes:
  * `feat/<feature-name>`: New user-facing capabilities
  * `fix/<bug-name>`: Bug fixes and error resolutions
  * `chore/<task-name>`: Dependency updates, refactoring, documentation
* **Conventional Commits:** Commit messages must follow the [Conventional Commits](https://www.conventionalcommits.org/) standard:

  ```text
  feat(ocr): add continuous luminance boost for low-light scans
  fix(db): ensure foreign key cascade delete on deleted lessons
  docs(api): document rate limit retry-after header behavior
  test(srs): add unit test for leitner box 5 advancement
  ```

---

## 6. Continuous Integration (CI) Architecture

The GitHub Actions workflow (`.github/workflows/ci.yml`) runs on every push and pull request to `main`:

* **`flutter-check` Job (Ubuntu):**
  1. Checks out repository.
  2. Sets up Flutter SDK `>=3.47.5` with caching.
  3. Validates formatting (`dart format --output=none --set-exit-if-changed .`).
  4. Runs static analysis (`flutter analyze --fatal-infos`).
  5. Runs all 110 Flutter unit, widget, and contract tests (`flutter test`).
* **`dotnet-check` Job (Ubuntu):**
  1. Sets up .NET 10.0 SDK.
  2. Restores and builds `server/NeuroScriptProxy/NeuroScriptProxy.sln`.
  3. Runs all 9 xUnit backend integration tests (`dotnet test`).
* **`docs-check` Job (Ubuntu):**
  1. Executes markdownlint and markdown link verification to prevent broken documentation links.
