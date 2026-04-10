# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Build:**
```bash
swift build
```

**Test:**
```bash
swift test
```

**Lint & Format:**
```bash
./Scripts/lint.sh
```
- `CI=true` — runs in CI mode (skips auto-formatting, only reports)
- `LINT_MODE=STRICT` — applies strict linting rules
- `FORMAT_ONLY=true` — only formats code, skips linting

## Architecture

AviaryInsights is a Swift Package for recording pageviews and custom events to [Plausible](https://plausible.io), a privacy-focused analytics platform.

**OpenAPI-First Design:** The Plausible API client in `Sources/AviaryInsights/Generated/` is auto-generated from `openapi.yaml`. Never edit generated files directly — edit `openapi.yaml` and regenerate.

**Core types:**
- `Plausible` — main client, initialized with a domain and optional transport
- `Event` — event definition (name, URL, referrer, custom properties, optional `Revenue`)
- `Revenue` — currency/amount struct for e-commerce tracking

**Transport abstraction:** The client accepts any `ClientTransport` from `swift-openapi-runtime`. On Apple platforms, `URLSessionTransport` is used; custom transports (e.g., for WASM or testing) are also supported. Tests use `MockTransport`.

**Platforms:** iOS 13+, macOS 10.15+, watchOS 6+, tvOS 13+, visionOS 1+, macCatalyst 13+, Linux, Android, Windows.

## Toolchain

Tools are managed via Mise (`.mise.toml`):
- **swiftlint** 0.63.2
- **swift-format** 602.0.0
- **swift-openapi-generator** 1.11.1
- **periphery** 3.7.2 (dead code detection)

Run `mise install` to install all tools before running scripts.

## Code Quality

- All source files require MIT license headers
- Strict SwiftLint rules are enforced (explicit ACL, no force unwrapping, etc.) — see `.swiftlint.yml`
- Swift Format rules are in `.swift-format`
- CI runs linting in strict mode (`CI=true LINT_MODE=STRICT`)
