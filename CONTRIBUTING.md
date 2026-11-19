# Contributing to NeuroScript AI

This repository contains the source code, design assets, and architectural contracts for **NeuroScript AI**, developed as a CS-400 Final Year Project at the University of Engineering & Technology (UET) Taxila.

To maintain demonstration readiness, prevent architectural drift, and ensure continuous stability, all contributors must strictly follow the development guidelines detailed below.

---

## 1. Core Branching Strategy

* **Protection of `main`:** Direct pushes to the `main` branch are restricted. All contributions must arrive via feature-branch pull requests.
* **Continuous Demoability:** The `main` branch must remain in a runnable, compilable state at all times.
* **Branch Naming Conventions:**
  * Feature branches: `feat/<description>`
  * Bug fixes: `fix/<description>`
  * Documentation and cleanup: `docs/<description>` or `chore/<description>`

---

## 2. Development Workflow

1. **Synchronize Local Environment:**

   ```bash
   git checkout main
   git pull origin main
   ```

2. **Create a Dedicated Branch:**

   ```bash
   git checkout -b feat/your-feature-name
   ```

3. **Verify Locally Before Committing:**

   ```bash
   # Dart & Flutter verification
   dart format --output=none --set-exit-if-changed .
   flutter analyze --fatal-infos
   flutter test

   # Backend proxy verification
   dotnet build server/NeuroScriptProxy/NeuroScriptProxy.sln
   dotnet test server/NeuroScriptProxy/NeuroScriptProxy.sln
   ```

4. **Commit Message Conventions:**
   * Format commits using conventional commit syntax:
     * `feat:` New features or functional modules
     * `fix:` Bug fixes or logic corrections
     * `docs:` Documentation, contracts, or specifications
     * `test:` Unit, widget, or integration tests
     * `chore:` Build scripts, dependencies, or tool configurations

5. **Open a Pull Request:**

   ```bash
   git push -u origin feat/your-feature-name
   ```

---

## 3. Honesty & Verification Rules (Zero Hallucination Policy)

All contributors must adhere strictly to the project rules:

1. **Never Invent Measurements:** Never fabricate benchmark scores, test numbers, device verifications, or dates.
2. **Explicit Uncertainty:** Any unmeasured capability MUST be marked as `"NOT MEASURED YET"` or `"NOT TESTED YET"`.
3. **No Superlatives:** Avoid unsubstantiated marketing phrases (e.g. "production-hardened", "proven", "scientifically validated"). State exact architectural facts and test outcomes instead.
4. **Target Platforms:** Mobile only — Android (API 24+) and iOS (14+). Do NOT re-introduce web or desktop platforms.
