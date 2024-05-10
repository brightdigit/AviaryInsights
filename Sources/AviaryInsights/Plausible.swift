//
//  Plausible.swift
//  AviaryInsights
//
//  Created by Leo Dion.
//  Copyright © 2024 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the “Software”), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
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
import OpenAPIURLSession

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Represents an interface to interact with the Plausible API.
public struct Plausible: Sendable {
  // swiftlint:disable force_try
  /// Default server URL for the Plausible API.
  public static let defaultServerURL = try! Servers.server1()
  // swiftlint:enable force_try

  private let client: Client
  /// Default domain associated with the Plausible instance.
  public let defaultDomain: String

  private init(client: Client, defaultDomain: String) {
    self.client = client
    self.defaultDomain = defaultDomain
  }

  /// Initializes a Plausible instance.
  /// - Parameters:
  ///   - transport: Client transport for sending requests.
  ///   - defaultDomain: Default domain associated with the Plausible instance.
  ///   - serverURL: Server URL for the Plausible API. Defaults to `defaultServerURL`.
  public init(
    transport: any ClientTransport,
    defaultDomain: String,
    serverURL: URL = Self.defaultServerURL
  ) {
    let client = Client(serverURL: serverURL, transport: transport)
    self.init(client: client, defaultDomain: defaultDomain)
  }

  /// Initializes a Plausible instance.
  /// - Parameters:
  ///   - defaultDomain: Default domain associated with the Plausible instance.
  ///   - serverURL: Server URL for the Plausible API. Defaults to `defaultServerURL`.
  ///   - configuration: Configuration for URLSessionTransport. Defaults to `nil`.
  public init(
    defaultDomain: String,
    serverURL: URL = Self.defaultServerURL,
    configuration: URLSessionTransport.Configuration? = nil
  ) {
    let transport: URLSessionTransport = if let configuration {
      .init(configuration: configuration)
    } else {
      .init()
    }
    self.init(
      transport: transport,
      defaultDomain: defaultDomain,
      serverURL: serverURL
    )
  }

  /// Initializes a Plausible instance with a custom URLSession.
  /// - Parameters:
  ///   - session: URLSession to use for making requests.
  ///   - defaultDomain: Default domain associated with the Plausible instance.
  ///   - serverURL: Server URL for the Plausible API. Defaults to `defaultServerURL`.
  public init(
    session: URLSession,
    defaultDomain: String,
    serverURL: URL = Self.defaultServerURL
  ) {
    self.init(
      defaultDomain: defaultDomain,
      serverURL: serverURL,
      configuration: .init(session: session)
    )
  }

  /// Sends an event to the Plausible API.
  /// - Parameter event: Event to be sent.
  public func postEvent(_ event: Event) async throws {
    _ = try await client.post_sol_event(
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
