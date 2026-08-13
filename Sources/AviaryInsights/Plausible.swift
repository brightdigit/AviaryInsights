//
//  Plausible.swift
//  AviaryInsights
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import OpenAPIRuntime

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Represents an interface to interact with the Plausible API.
///
/// ``Plausible`` is a client for interacting with the Plausible API.
/// It is initialized with a domain, which is typically your app's bundle identifier.
/// The ``Plausible`` client is used to send events to the Plausible API for tracking and analysis.
///
/// To construct a ``Plausible`` instance, you need to provide a domain.
/// The domain is a string that identifies your application, typically the bundle identifier of your app.
///
/// ```swift
/// let plausible = Plausible(defaultDomain: "com.example.yourApp", userAgent: "MyApp/1.0")
/// ```
/// By default ``Plausible`` uses a
/// [`URLSessionTransport`](https://github.com/apple/swift-openapi-urlsession),
/// however you can use alternatives such as
/// [`AsyncHTTPClient`](https://github.com/swift-server/swift-openapi-async-http-client).
///
/// ## Sending Event
/// AviaryInsights provides two ways to send an ``Event`` to the Plausible API:
/// ### Asynchronous Throwing Method
///
/// This method sends an event to the Plausible API and throws an error if the operation fails.
/// This is useful when you want to handle errors in your own way. Here's an example:
///
/// ```swift
/// do {
///     try await plausible.postEvent(event)
/// } catch {
///     print("Failed to post event: \(error)")
/// }
/// ```
///
/// ### Synchronous Method
///
/// This method sends an event to the Plausible API in the background.
/// Delivery failures go to the `onError` handler given at initialization
/// (``defaultErrorHandler`` if none was, which prints). Here's an example:
///
/// ```swift
/// plausible.postEvent(event)
/// ```
/// Both methods also accept optional `forwardedFor` and `debugRequest` headers.
/// In both cases, `event` is an instance of ``Event`` that you want to send to the Plausible API.
public struct Plausible: Sendable {
  // swift-format-ignore: NeverUseForceTry
  // swiftlint:disable force_try
  /// Default server URL for the Plausible API.
  public static let defaultServerURL = try! Servers.Server1.url()
  // swiftlint:enable force_try

  /// Handler used when a caller does not supply one.
  ///
  /// Prints the error's description, preserving the behavior the
  /// fire-and-forget `postEvent` had before the handler existed. Pass
  /// your own to route failures into a logger or metric, or `{ _ in }` to
  /// silence them.
  public static let defaultErrorHandler: @Sendable (any Error) -> Void = { error in
    print(error.localizedDescription)
  }

  private let client: Client

  /// Called when the fire-and-forget `postEvent` fails to deliver.
  internal let onError: @Sendable (any Error) -> Void

  /// Default domain associated with the Plausible instance.
  public let defaultDomain: String

  /// User-Agent string sent with every event request.
  ///
  /// Plausible uses this value to calculate unique visitor IDs and
  /// populate device reports. It should identify your application,
  /// for example `"MyApp/1.0 (com.example.myapp)"`.
  public let userAgent: String

  private init(
    client: Client,
    defaultDomain: String,
    userAgent: String,
    onError: @escaping @Sendable (any Error) -> Void
  ) {
    self.client = client
    self.defaultDomain = defaultDomain
    self.userAgent = userAgent
    self.onError = onError
  }

  /// Initializes a Plausible instance with a custom `ClientTransport`.
  /// - Parameters:
  ///   - transport: Client transport for sending requests.
  ///   - defaultDomain: Default domain associated with the Plausible instance.
  ///   - userAgent: User-Agent string for visitor identification.
  ///   - serverURL: Server URL for the Plausible API. Defaults to `defaultServerURL`.
  ///   - diagnostics: Handler receiving each response's ``PlausibleDiagnostics``
  ///     (status code and the `x-plausible-dropped` bot-filter marker). Defaults
  ///     to `nil` (no reporting).
  ///   - onError: Handler receiving delivery failures from the fire-and-forget
  ///     `postEvent`. Defaults to ``defaultErrorHandler``, which prints.
  public init(
    transport: any ClientTransport,
    defaultDomain: String,
    userAgent: String,
    serverURL: URL = Self.defaultServerURL,
    diagnostics: (@Sendable (PlausibleDiagnostics) -> Void)? = nil,
    onError: @escaping @Sendable (any Error) -> Void = Self.defaultErrorHandler
  ) {
    let middlewares = diagnostics.map {
      [DiagnosticsMiddleware(handler: $0)] as [any ClientMiddleware]
    }
    let client = Client(
      serverURL: serverURL,
      transport: transport,
      middlewares: middlewares ?? []
    )
    self.init(
      client: client,
      defaultDomain: defaultDomain,
      userAgent: userAgent,
      onError: onError
    )
  }

  /// Sends an event to the Plausible API.
  /// - Parameters:
  ///   - event: Event to be sent.
  ///   - forwardedFor: Overrides the client IP addresses Plausible attributes
  ///     the event to (`X-Forwarded-For`). Serialized as a comma-separated
  ///     list; Plausible uses the first valid address. Supports IPv4 and IPv6.
  ///   - debugRequest: When `true`, asks Plausible to answer `200` with the IP
  ///     address it used for visitor counting (`X-Debug-Request`), instead of
  ///     the usual `202`.
  public func postEvent(
    _ event: Event,
    forwardedFor: [IPAddress]? = nil,
    debugRequest: Bool? = nil
  ) async throws {
    let output = try await client.post_sol_event(
      headers: .init(
        User_hyphen_Agent: userAgent,
        X_hyphen_Forwarded_hyphen_For: forwardedFor?.map(\.description).joined(separator: ","),
        X_hyphen_Debug_hyphen_Request: debugRequest
      ),
      body: .init(event: event, defaultDomain: defaultDomain)
    )
    switch output {
    case .accepted, .ok: break
    default: break
    }
  }
}
