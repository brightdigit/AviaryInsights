## What's Changed

* Link OpenAPIURLSession on Linux/Windows/Android by @leogdion in https://github.com/brightdigit/AviaryInsights/pull/35

### Features
* Optional `diagnostics` callback on `Plausible` initializers reports HTTP status and whether Plausible dropped the event (`x-plausible-dropped`)

### Fixes
* Default `Plausible(defaultDomain:userAgent:)` works on Linux, Windows, and Android (no longer Apple-only). WASI still excluded

### Documentation
* Note that `x-plausible-dropped: 1` can mean an unknown domain as well as bot filtering
* README and DocC updated for current `Plausible` / `Event` APIs

### CI / tooling
* Ubuntu matrix includes Swift 6.4 nightly; new `swift-6.4-nightly` Dev Container
* Android API 36 removed from the matrix
* macOS 26 jobs use Xcode 26.6 and simulator OS 26.5
* Swift 6.4 wasm / wasm-embedded temporarily excluded (nightly vs pinned WASM SDK mismatch)
* Dependency pins refreshed; local lint no longer runs periphery

**Full Changelog**: https://github.com/brightdigit/AviaryInsights/compare/1.1.0-beta.1...1.1.0-beta.2
