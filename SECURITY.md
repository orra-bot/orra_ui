# Security policy

## Supported versions

orra_ui is pre-1.0. Security fixes land on `main` and in the next release; older versions are not patched.

| Version | Supported |
| --- | :---: |
| `main` | ✅ |
| 0.1.x | ✅ |
| < 0.1 | ❌ |

## Reporting a vulnerability

**Please do not open a public issue for security problems.**

Report privately through [GitHub's private vulnerability reporting](https://github.com/orra-bot/orra_ui/security/advisories/new). Include:

- the affected package (`orra_ui`, `orra_desktop_shell`, `orra_guardrails`) and version or commit;
- the platform (macOS, Windows, Linux, web);
- steps or a minimal sample that reproduces the problem, and its impact.

You can expect an acknowledgement within 7 days. We'll keep you updated while we work on a fix, and credit you in the advisory unless you prefer to stay anonymous.

## Scope

orra_ui is a UI library, so most issues will be in the window shell's native code (the macOS plugin) or in how it handles files such as saved window state. Vulnerabilities in third-party dependencies (for example `window_manager`) should be reported upstream; let us know as well if orra_ui is affected.
