# Security Policy

## 1. Supported Versions

| Version | Supported | Notes |
| :--- | :--- | :--- |
| `0.3.x` | :white_check_mark: | Current active release branch (`chore/stack-and-cleanup`). |
| `< 0.3.0` | :x: | End of life; upgrade to `0.3.0` or later. |

---

## 2. Reporting a Vulnerability

The NeuroScript AI engineering team takes security and student privacy seriously. If you discover a vulnerability or potential data leakage risk in the mobile client or backend proxy, please report it responsibly:

* **Email:** Send details to `zaintahir2025@gmail.com` with the subject line `[SECURITY] NeuroScript AI Vulnerability Report`.
* **Details to Include:**
  * Component affected (Mobile client, Drift database, Keystore, or ASP.NET Core proxy).
  * Proof of concept or reproduction steps.
  * Potential impact on user note confidentiality or cryptographic integrity.
* **Response Timeline:** We will acknowledge receipt within 48 hours and provide a remediation plan within 7 days.
* **Public Disclosure:** Please do not open public GitHub issues for security vulnerabilities until a patch has been landed.

---

## 3. Cryptographic Architecture & Gaps

* **Local Storage:** Encrypted with AES-256 via `sqlite3mc` in SQLCipher-compatible mode. The 256-bit master key is maintained in `FlutterSecureStorage` (Android KeyStore / iOS Keychain).
* **Proxy Gateway:** Operates statelessly for note contents; API keys are isolated strictly in server environment variables.
* **Known Gaps:** As documented in [docs/PRIVACY_AND_SECURITY.md](docs/PRIVACY_AND_SECURITY.md), uninstalling the app purges operating system keystore entries, preventing database decryption after reinstallation.
