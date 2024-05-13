# ``AviaryInsights``

Easy to use Swift Package for recording pageviews and custom events for [Plausible](https://plausible.io).  

## Overview

[Plausible](https://plausible.io) provides simple and meaningful insights into your website's' or app's traffic without invading the privacy of your visitors. However, integrating Plausible into a Swift application can be complex and time-consuming. AviaryInsights simplifies this process, allowing you to focus on building your application while still gaining the valuable insights that Plausible provides.

``AviaryInsights`` provides a full set of features to work with [Plausible's API](https://plausible.io/docs/events-api):

- **Event tracking** Define and track custom events in your application.
- **Revenue tracking** Track revenue data associated with events.
- **Plausible API integration** Send your events to the [Plausible API](https://plausible.io/docs/events-api) for further analysis.

### Requirements 

**Apple Platforms**

- Xcode 15 or later
- Swift 5.9 or later
- iOS 13 / watchOS 6 / tvOS 13 / visionOS 1 / macCatalyst 13 / macOS 10.15 or later deployment targets

**Linux**

- Ubuntu 20.04 or later
- Swift 5.9 or later

### Installation

To add the AviaryInsights package to your Xcode project, select File > Swift Packages > Add Package Dependency and enter the repository URL.

Using Swift Package Manager add the repository url:

```
https://github.com/brightdigit/AviartyInsights.git
```

### Usage

Here's a basic example for setting up the ``Plausible`` client add sending an ``Event``.

```swift
import AviaryInsights

// Initialize the client with your bundle identifier as the domain
let plausible = Plausible(domain: "com.example.yourApp")

// Define an event
let event = Event(url: "app://localhost/login")

// Send the event
plausible.send(event: event)
```

#### Plausible Client

``Plausible`` is a client for interacting with the [Plausible API](https://plausible.io/docs/events-api). It is initialized with a domain, which is typically your app's bundle identifier. The ``Plausible`` client is used to send events to the [Plausible API](https://plausible.io/docs/events-api) for tracking and analysis.

To construct a ``Plausible`` instance, you need to provide a domain. The domain is a string that identifies your application, typically the bundle identifier of your app.

```swift
let plausible = Plausible(domain: "com.example.yourApp")
```

By default ``Plausible`` uses a [`URLSessionTransport`](https://github.com/apple/swift-openapi-urlsession), however you can use alternatives such as [`AsyncHTTPClient`](https://github.com/swift-server/swift-openapi-async-http-client).

#### Sending an `Event`

``Event`` represents an event in your system. An event has a name and URL, and optionally, a domain, referrer, custom properties (`props`), and revenue information. You can create an ``Event`` instance and send it using the ``Plausible`` client.

To construct an ``Event``, you need to provide at least a name. The name is a string that identifies the event you want to track. Optionally, you can also provide:

- **`name`** string that represents the name of the event. _Default_ is **pageview**.
- **`url`** string that represents the URL where the event occurred. For an app you may wish to use a app url such as `app://localhost/login`.
- `domain` _optional_ string that identifies the domain in which the event occurred. Overrides whatever was set in the ``Plausible`` instance.
- `referrer` _optional_ string that represents the URL of the referrer
- `props` _optional_ dictionary of custom properties associated with the event.
- `revenue` _optional_ `Revenue` instance that represents the revenue data associated with the event

```swift
let event = Event
    name: "eventName", 
    domain: "domain",
    url: "url", 
    referrer: "referrer", 
    props: ["key": "value"], 
    revenue: Revenue(
        currencyCode: "USD", 
        amount: 100
    )
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

In both cases, `event` is an instance of ``Event`` that you want to send to the Plausible API.

## Topics

### Creating a Client

- ``Plausible``

### Building an Event

- ``Event``
- ``Revenue``
