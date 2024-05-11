# AviaryInsights

Easy to use Swift Package for recording pageviews and custom events for Plausible. 

[![SwiftPM](https://img.shields.io/badge/SPM-Linux%20%7C%20iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
[![Twitter](https://img.shields.io/badge/twitter-@brightdigit-blue.svg?style=flat)](http://twitter.com/brightdigit)
![GitHub](https://img.shields.io/github/license/brightdigit/AviaryInsights)
![GitHub issues](https://img.shields.io/github/issues/brightdigit/AviaryInsights)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/brightdigit/AviaryInsights/AviaryInsights.yml?label=actions&logo=github&?branch=main)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FAviaryInsights%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/brightdigit/AviaryInsights)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fbrightdigit%2FAviaryInsights%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/brightdigit/AviaryInsights)

[![Codecov](https://img.shields.io/codecov/c/github/brightdigit/AviaryInsights)](https://codecov.io/gh/brightdigit/AviaryInsights)
[![CodeFactor Grade](https://img.shields.io/codefactor/grade/github/brightdigit/AviaryInsights)](https://www.codefactor.io/repository/github/brightdigit/AviaryInsights)
[![codebeat badge](https://codebeat.co/badges/94a8313d-2215-4ef6-8690-ab7b3e06369c)](https://codebeat.co/projects/github-com-brightdigit-mistkit-main)
[![Code Climate maintainability](https://img.shields.io/codeclimate/maintainability/brightdigit/AviaryInsights)](https://codeclimate.com/github/brightdigit/AviaryInsights)
[![Code Climate technical debt](https://img.shields.io/codeclimate/tech-debt/brightdigit/AviaryInsights?label=debt)](https://codeclimate.com/github/brightdigit/AviaryInsights)
[![Code Climate issues](https://img.shields.io/codeclimate/issues/brightdigit/AviaryInsights)](https://codeclimate.com/github/brightdigit/AviaryInsights)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)

# Requirements 

## Features

- Event tracking: Define and track custom events in your application.
- Revenue tracking: Track revenue data associated with events.
- Plausible API integration: Send your events to the Plausible API for further analysis.


**Apple Platforms**

- Xcode 15 or later
- Swift 5.9 or later
- iOS 13 / watchOS 6 / tvOS 13 / visionOS 1 / macCatalyst 13 / macOS 10.15 or later deployment targets

**Linux**

- Ubuntu 20.04 or later
- Swift 5.9 or later

## Installation

To add the AviaryInsights package to your Xcode project, select File > Swift Packages > Add Package Dependency and enter the repository URL.

Using Swift Package Manager add the repository url:

```
https://github.com/brightdigit/README.git
```

## Usage

```swift
import AviaryInsights

// Initialize the client with your bundle identifier as the domain
let plausible = Plausible(domain: "com.example.yourApp")

// Define an event
let event = Event(url: "app://localhost/login")

// Send the event
plausible.send(event: event)
```

## Main Components

### Plausible

`Plausible` is a client for interacting with the Plausible API. It is initialized with a domain, which is typically your app's bundle identifier. The `Plausible` client is used to send events to the Plausible API for tracking and analysis.

To construct a `Plausible` instance, you need to provide a domain. The domain is a string that identifies your application, typically the bundle identifier of your app.

```swift
let plausible = Plausible(domain: "com.example.yourApp")
```

By default `Plausible` uses a `URLSessionTransport`, however you can use alternatives such as AsyncClient.

### Event

`Event` represents an event in your system. An event has a name, and optionally, a domain, URL, referrer, custom properties (`props`), and revenue information. You can create an `Event` instance and send it using the `Plausible` client.

To construct an `Event`, you need to provide at least a name. The name is a string that identifies the event you want to track. Optionally, you can also provide:

- **`name`** string that represents the name of the event. _Default_ is **pageview**.
- **`url`** string that represents the URL where the event occurred. For an app you may wish to use a app url such as `app://localhost/login`.
- `domain` _optional_ string that identifies the domain in which the event occurred. Overrides whatever was set in the `Plausible` instance.
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

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) to get started.

## License

AviaryInsights is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
