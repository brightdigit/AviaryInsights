## What's Changed

* Gate Android and Windows coverage on contains-code-coverage by @leogdion in https://github.com/brightdigit/AviaryInsights/pull/38
* Fix README badges by @leogdion in https://github.com/brightdigit/AviaryInsights/pull/39
* Refactor AviaryInsightsTests to the project's Swift Testing convention by @leogdion in https://github.com/brightdigit/AviaryInsights/pull/41
* Expose X-Forwarded-For and X-Debug-Request through Plausible by @leogdion in https://github.com/brightdigit/AviaryInsights/pull/43
* Replace print-based error handling with an onError handler by @leogdion in https://github.com/brightdigit/AviaryInsights/pull/44

### Features
* `postEvent` accepts optional `forwardedFor: [IPAddress]?` (`X-Forwarded-For`) and `debugRequest: Bool?` (`X-Debug-Request`)
* New public `IPAddress` value type for validated IPv4/IPv6 addresses (byte-backed, RFC 5952 canonical `description`)
* Optional `onError` callback on `Plausible` initializers for fire-and-forget delivery failures (defaults to `Plausible.defaultErrorHandler`, which still prints)

### Known issues
* Generated client percent-encodes header values, so IPv6 addresses and multi-address `forwardedFor` lists reach Plausible escaped — prefer a single IPv4 address until resolved (#42)

### Documentation
* README and DocC cover `onError`, `forwardedFor` / `debugRequest`, and `IPAddress`
* README badges cleaned up (removed retired Code Climate / codebeat / Twitter / Hound; fixed Actions query)

### Tests / CI
* Test target restructured to the project's Swift Testing convention (`AviaryInsightsTests+<Concern>.swift`)
* Vacuous / non-deterministic post-event assertions fixed
* Android and Windows jobs gate Codecov upload on `contains-code-coverage`

**Full Changelog**: https://github.com/brightdigit/AviaryInsights/compare/1.1.0-beta.2...1.1.0-beta.3
