//
//  AviaryInsights.swift
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

public struct Revenue {
  public init(currency: String, amount: Double) {
    self.currency = currency
    self.amount = amount
  }

  public let currency: String
  public let amount: Double
}

public struct Event {
  public init(
    name: String,
    domain: String? = nil,
    url: String,
    referrer: String? = nil,
    props: [String: (any Sendable)?]? = nil,
    revenue: Revenue? = nil
  ) {
    self.name = name
    self.domain = domain
    self.url = url
    self.referrer = referrer
    self.props = props
    self.revenue = revenue
  }

  public let name: String
  public let domain: String?
  public let url: String
  public let referrer: String?
  public let props: [String: (any Sendable)?]?
  public let revenue: Revenue?
}

extension Operations.post_sol_event.Input.Body {
  init(event: Event, defaultDomain: String) {
    self = .json(.init(event: event, defaultDomain: defaultDomain))
  }
}

extension Operations.post_sol_event.Input.Body.jsonPayload {
  init(event: Event, defaultDomain: String) {
    let propsContainer: OpenAPIObjectContainer?
    do {
      propsContainer = try event.props.flatMap(OpenAPIObjectContainer.init)
    } catch {
      assertionFailure(error.localizedDescription)
      propsContainer = nil
    }
    self.init(
      name: event.name,
      domain: event.domain ?? defaultDomain,
      url: event.url,
      referrer: event.referrer,
      props: propsContainer
    )
  }
}

public struct Plausible {
  // swiftlint:disable:next force_try
  public static let defaultServerURL = try! Servers.server1()

  private init(client: Client, defaultDomain: String) {
    self.client = client
    self.defaultDomain = defaultDomain
  }

  public init(
    serverURL: URL = Self.defaultServerURL,
    transport: any ClientTransport,
    defaultDomain: String
  ) {
    let client = Client(serverURL: serverURL, transport: transport)
    self.init(client: client, defaultDomain: defaultDomain)
  }

  public init(
    serverURL: URL = Self.defaultServerURL,
    configuration: URLSessionTransport.Configuration? = nil,
    defaultDomain: String
  ) {
    let transport: URLSessionTransport = if let configuration {
      .init(configuration: configuration)
    } else {
      .init()
    }
    self.init(
      serverURL: serverURL,
      transport: transport,
      defaultDomain: defaultDomain
    )
  }

  public init(
    serverURL: URL = Self.defaultServerURL,
    session: URLSession,
    defaultDomain: String
  ) {
    self.init(
      serverURL: serverURL,
      configuration: .init(session: session),
      defaultDomain: defaultDomain
    )
  }

  private let client: Client
  public let defaultDomain: String

  public func postEvent(_ event: Event) {
    Task {
      do {
        try await postEvent(event)
      } catch {
        print(error.localizedDescription)
      }
    }
  }

  public func postEvent(_ event: Event) async throws {
    let response = try await client.post_sol_event(
      body: .json(.init(event: event, defaultDomain: defaultDomain)
      )
    )

    _ = try response.accepted
  }
}
