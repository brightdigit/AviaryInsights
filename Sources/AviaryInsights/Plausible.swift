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

#if canImport(OpenAPIURLSession)
  import OpenAPIURLSession
#endif

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
/// This method sends an event to the Plausible API in the background and ignores any errors that occur.
/// This is useful when you don't need to handle errors and
/// want to fire-and-forget the event. Here's an example:
///
/// ```swift
/// plausible.postEvent(event)
/// ```
/// In both cases, `event` is an instance of ``Event`` that you want to send to the Plausible API.
public struct Plausible: Sendable {
  // swift-format-ignore: NeverUseForceTry
  // swiftlint:disable force_try
  /// Default server URL for the Plausible API.
  public static let defaultServerURL = try! Servers.Server1.url()
  // swiftlint:enable force_try

  private let client: Client

  /// Default domain associated with the Plausible instance.
  public let defaultDomain: String

  /// User-Agent string sent with every event request.
  ///
  /// Plausible uses this value to calculate unique visitor IDs and
  /// populate device reports. It should identify your application,
  /// for example `"MyApp/1.0 (com.example.myapp)"`.
  public let userAgent: String

  private init(client: Client, defaultDomain: String, userAgent: String) {
    self.client = client
    self.defaultDomain = defaultDomain
    self.userAgent = userAgent
  }

  /// Initializes a Plausible instance with a custom `ClientTransport`.
  /// - Parameters:
  ///   - transport: Client transport for sending requests.
  ///   - defaultDomain: Default domain associated with the Plausible instance.
  ///   - userAgent: User-Agent string for visitor identification.
  ///   - serverURL: Server URL for the Plausible API. Defaults to `defaultServerURL`.
  public init(
    transport: any ClientTransport,
    defaultDomain: String,
    userAgent: String,
    serverURL: URL = Self.defaultServerURL
  ) {
    let client = Client(serverURL: serverURL, transport: transport)
    self.init(client: client, defaultDomain: defaultDomain, userAgent: userAgent)
  }

  #if canImport(OpenAPIURLSession)
    /// Initializes a Plausible instance using the default `URLSessionTransport`.
    /// - Parameters:
    ///   - defaultDomain: Default domain associated with the Plausible instance.
    ///   - userAgent: User-Agent string for visitor identification.
    ///   - serverURL: Server URL for the Plausible API. Defaults to `defaultServerURL`.
    public init(
      defaultDomain: String,
      userAgent: String,
      serverURL: URL = Self.defaultServerURL
    ) {
      self.init(
        transport: URLSessionTransport(),
        defaultDomain: defaultDomain,
        userAgent: userAgent,
        serverURL: serverURL
      )
    }

    /// Initializes a Plausible instance with a custom `URLSessionTransport.Configuration`.
    /// - Parameters:
    ///   - defaultDomain: Default domain associated with the Plausible instance.
    ///   - userAgent: User-Agent string for visitor identification.
    ///   - serverURL: Server URL for the Plausible API. Defaults to `defaultServerURL`.
    ///   - configuration: Configuration for URLSessionTransport. Defaults to `nil`.
    public init(
      defaultDomain: String,
      userAgent: String,
      serverURL: URL = Self.defaultServerURL,
      configuration: URLSessionTransport.Configuration
    ) {
      let transport: URLSessionTransport = .init(configuration: configuration)
      self.init(
        transport: transport,
        defaultDomain: defaultDomain,
        userAgent: userAgent,
        serverURL: serverURL
      )
    }
    /// Initializes a Plausible instance with a custom URLSession.
    /// - Parameters:
    ///   - session: URLSession to use for making requests.
    ///   - defaultDomain: Default domain associated with the Plausible instance.
    ///   - userAgent: User-Agent string for visitor identification.
    ///   - serverURL: Server URL for the Plausible API. Defaults to `defaultServerURL`.
    public init(
      session: URLSession,
      defaultDomain: String,
      userAgent: String,
      serverURL: URL = Self.defaultServerURL
    ) {
      self.init(
        defaultDomain: defaultDomain,
        userAgent: userAgent,
        serverURL: serverURL,
        configuration: .init(session: session)
      )
    }
  #endif

  /// Sends an event to the Plausible API.
  /// - Parameter event: Event to be sent.
  public func postEvent(_ event: Event) async throws {
    _ = try await client.post_sol_event(
      headers: .init(User_hyphen_Agent: userAgent),
      body: .init(event: event, defaultDomain: defaultDomain)
    ).accepted
  }
}

extension Plausible {
  /// Sends the event to Plausible in the background.
  /// - Parameter event: An analytic event to record.
  public func postEvent(_ event: Event) {
    Task {
      do {
        try await postEvent(event)
      } catch {
        print(error.localizedDescription)
      }
    }
  }
}
