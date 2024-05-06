//
//  Plausible.swift
//  SimulatorServices
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

public struct Plausible {
  // swiftlint:disable:next force_try
  public static let defaultServerURL = try! Servers.server1()

  private let client: Client
  public let defaultDomain: String

  private init(client: Client, defaultDomain: String) {
    self.client = client
    self.defaultDomain = defaultDomain
  }

  public init(
    transport: any ClientTransport,
    defaultDomain: String,
    serverURL: URL = Self.defaultServerURL
  ) {
    let client = Client(serverURL: serverURL, transport: transport)
    self.init(client: client, defaultDomain: defaultDomain)
  }

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

  public func postEvent(_ event: Event) async throws {
    _ = try await client.post_sol_event(
      body: .init(event: event, defaultDomain: defaultDomain)
    ).accepted
  }
}

extension Plausible {
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
