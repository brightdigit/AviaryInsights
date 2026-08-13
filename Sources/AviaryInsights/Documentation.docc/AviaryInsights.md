# ``AviaryInsights``

Easy to use Swift Package for recording pageviews and custom events for [Plausible](https://plausible.io).  

## Overview

[Plausible](https://plausible.io) provides simple and meaningful insights into your website's' or app's traffic without invading the privacy of your visitors. However, integrating Plausible into a Swift application can be complex and time-consuming. AviaryInsights simplifies this process, allowing you to focus on building your application while still gaining the valuable insights that Plausible provides.

``AviaryInsights`` provides a full set of features to work with [Plausible's API](https://plausible.io/docs/events-api):

- **Event tracking** Define and track custom events in your application.
- **Revenue tracking** Track revenue data associated with events.
- **Plausible API integration** Send your events to the [Plausible API](https://plausible.io/docs/events-api) for further analysis.
- **Discard diagnostics** Observe HTTP status and `x-plausible-dropped` via ``PlausibleDiagnostics``.

### Requirements 

**Apple Platforms**

- Xcode 15 or later
- Swift 5.9 or later
- iOS 13 / watchOS 6 / tvOS 13 / visionOS 1 / macCatalyst 13 / macOS 10.15 or later deployment targets

**Linux / Windows / Android**

- Swift 5.9 or later
- Default `URLSessionTransport` initializer is available (WASI requires a custom `ClientTransport`)

### Installation

To add the AviaryInsights package to your Xcode project, select File > Swift Packages > Add Package Dependency and enter the repository URL.

Using Swift Package Manager add the repository url:

```
https://github.com/brightdigit/AviaryInsights.git
```

### Usage

Here's a basic example for setting up the ``Plausible`` client and sending an ``Event``.

```swift
import AviaryInsights

// Initialize the client with your Plausible site domain and app User-Agent
let plausible = Plausible(
  defaultDomain: "com.example.yourApp",
  userAgent: "MyApp/1.0 (com.example.yourApp)"
)

// Define an event
let event = Event(url: "app://localhost/login")

// Send the event (fire-and-forget)
plausible.postEvent(event)
```

#### Plausible Client

``Plausible`` is a client for interacting with the [Plausible API](https://plausible.io/docs/events-api). It is initialized with a domain (your Plausible site) and a User-Agent string used for visitor identification.

```swift
let plausible = Plausible(
  defaultDomain: "com.example.yourApp",
  userAgent: "MyApp/1.0 (com.example.yourApp)"
)
```

By default ``Plausible`` uses a [`URLSessionTransport`](https://github.com/apple/swift-openapi-urlsession) on Apple platforms, Linux, Windows, and Android. WASI builds need an explicit custom `ClientTransport`. You can also use alternatives such as [`AsyncHTTPClient`](https://github.com/swift-server/swift-openapi-async-http-client).

#### Sending an `Event`

``Event`` represents an event in your system. An event has a name and URL, and optionally, a domain, referrer, custom properties (`props`), revenue, and interactive flag. You can create an ``Event`` instance and send it using the ``Plausible`` client.

To construct an ``Event``, provide at least a `url`. Optionally:

- **`name`** string that represents the name of the event. _Default_ is **pageview**.
- **`url`** string that represents the URL where the event occurred. For an app you may wish to use a app url such as `app://localhost/login`.
- `domain` _optional_ string that identifies the domain in which the event occurred. Overrides whatever was set in the ``Plausible`` instance.
- `referrer` _optional_ string that represents the URL of the referrer
- `props` _optional_ dictionary of custom properties associated with the event.
- `revenue` _optional_ `Revenue` instance that represents the revenue data associated with the event
- `interactive` _optional_ whether the event affects bounce rate

```swift
let event = Event(
  url: "app://localhost/checkout",
  name: "purchase",
  domain: "com.example.yourApp",
  referrer: "app://localhost/cart",
  props: ["plan": "pro"],
  revenue: Revenue(currency: "USD", amount: 100),
  interactive: true
)
```

AviaryInsights provides two ways to send events to the Plausible API:

##### Asynchronous Throwing Method

This method sends an event to the Plausible API and throws an error if the operation fails. This is useful when you want to handle errors in your own way. Here's an example:

```swift
do {
    try await plausible.postEvent(event)
} catch {
    print("Failed to post event: \(error)")
}
```

##### Synchronous Method

This method sends an event to the Plausible API in the background and ignores any errors that occur. This is useful when you don't need to handle errors and want to fire-and-forget the event. Here's an example:

```swift
plausible.postEvent(event)
```

Delivery failures are reported to the `onError` handler you pass at initialization. It defaults to `Plausible.defaultErrorHandler`, which prints the error's description — the behavior this method has always had. Supply your own to route failures into a logger or metric, or `{ _ in }` to silence them entirely:

```swift
let plausible = Plausible(
  defaultDomain: "com.example.yourApp",
  userAgent: "MyApp/1.0 (com.example.yourApp)",
  onError: { error in
    logger.error("Plausible delivery failed: \(error)")
  }
)
```

Errors arrive wrapped in an `OpenAPIRuntime.ClientError`; its `underlyingError` is the transport failure. When a caller needs to react to the outcome inline, use the throwing `async` method instead.

In both cases, `event` is an instance of ``Event`` that you want to send to the Plausible API.

##### Optional Request Headers

Both methods accept two optional headers the [Plausible events API](https://plausible.io/docs/events-api) supports:

- **`forwardedFor`** overrides the client IP addresses Plausible attributes the event to (`X-Forwarded-For`). Pass an array of ``IPAddress`` values; they are joined with commas and Plausible uses the first valid one.
- **`debugRequest`** asks Plausible to answer `200` with the IP address it used for visitor counting, instead of the usual `202` (`X-Debug-Request`).

``IPAddress`` is a byte-backed value type that parses IPv4 dotted-quad and IPv6 (RFC 4291, including `::` compression and an embedded IPv4 tail) and renders back the RFC 5952 canonical form. It has no string-literal conformance, so parsing is explicit and failable:

```swift
guard let address = IPAddress("203.0.113.7") else { return }

try await plausible.postEvent(
  event,
  forwardedFor: [address],
  debugRequest: true
)
```

You can also build one without parsing with ``IPAddress/init(_:_:_:_:)``, ``IPAddress/init(bytes:)`` or ``IPAddress/init(groups:)``, or use the constants ``IPAddress/loopback``, ``IPAddress/unspecified``, ``IPAddress/broadcast``, ``IPAddress/ipv6Loopback`` and ``IPAddress/ipv6Unspecified``.

Both parameters default to `nil`, in which case the header is not sent at all.

> Note: the generated client percent-encodes header values, so `forwardedFor` currently reaches Plausible escaped whenever the value contains a reserved character — the `:` of an IPv6 address *and* the `,` joining a multi-address list (`203.0.113.7%2C198.51.100.42`). Until that is resolved, pass a single IPv4 address.

#### Diagnostics

Plausible's events API often returns **202 even when it discards the event**. The discard signal is the `x-plausible-dropped: 1` response header (bot filtering or an unknown `domain`). Pass a `diagnostics` handler to observe each response:

```swift
let plausible = Plausible(
  defaultDomain: "com.example.yourApp",
  userAgent: "MyApp/1.0 (com.example.yourApp)",
  diagnostics: { diagnostics in
    if diagnostics.dropped {
      // Event was not recorded (bot filter or unknown domain)
    }
  }
)
```

See ``PlausibleDiagnostics`` for `statusCode` and `dropped`.

## Topics

### Creating a Client

- ``Plausible``
- ``PlausibleDiagnostics``

### Addressing a Visitor

- ``IPAddress``

### Building an Event

- ``Event``
- ``Revenue``
