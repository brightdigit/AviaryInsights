//
//  AviaryInsightsTests.swift
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

@testable import AviaryInsights
import HTTPTypes
import OpenAPIRuntime
import XCTest

final actor MockTransport: ClientTransport {
  internal init(nextResponse: @escaping @Sendable () -> Response) {
    sentRequests = []
    self.nextResponse = nextResponse
  }

  struct Request {
    let request: HTTPRequest
    let body: HTTPBody?
    let baseURL: URL
    let operationID: String
  }

  struct Response {
    let response: HTTPResponse
    let body: HTTPBody?

    func tuple() -> (HTTPResponse, HTTPBody?) {
      (response, body)
    }
  }

  private(set) var sentRequests = [Request]()
  let nextResponse: @Sendable () -> Response

  func send(_ request: HTTPRequest, body: HTTPBody?, baseURL: URL, operationID: String) async throws -> (HTTPResponse, HTTPBody?) {
    sentRequests.append(.init(request: request, body: body, baseURL: baseURL, operationID: operationID))
    return nextResponse().tuple()
  }
}

extension Revenue {
  static func random() -> Revenue {
    .init(currency: UUID().uuidString, amount: .random(in: 20 ... 999))
  }
}

final class AviaryInsightsTests: XCTestCase {
  func randomProps() -> [String: (any Sendable)?] {
    var values = [String: (any Sendable)?]()
    let keyCount: Int = .random(in: 3 ... 7)
    for _ in 0 ..< keyCount {
      let value: any Sendable
      let type: Bool = .random()
      switch type {
      case false:
        value = Int.random(in: 100 ... 999)
      case true:
        value = UUID().uuidString
      }
      values[UUID().uuidString] = value
    }
    return values
  }

  func testPostEvent() async throws {
    let transport = MockTransport {
      .init(response: .init(status: .accepted), body: "{}")
    }

    let defaultDomain = UUID().uuidString
    let client = Plausible(transport: transport, defaultDomain: defaultDomain)
    let events: [Event] = {
      let count: Int = .random(in: 10 ... 20)
      return (0 ..< count).map { _ in
        Event(
          url: UUID().uuidString,
          name: UUID().uuidString,
          domain: Bool.random() ? UUID().uuidString : nil,
          referrer: Bool.random() ? UUID().uuidString : nil,
          props: Bool.random() ? randomProps() : nil,
          revenue: Bool.random() ? .random() : nil
        )
      }
    }()

    for event in events {
      try await client.postEvent(event)
    }

    let requests = await transport.sentRequests
    let decoder = JSONDecoder()
    for (event, request) in zip(events, requests) {
      guard let body = request.body else {
        XCTAssertNotNil(request.body)
        continue
      }
      let data = try await Data(collecting: body, upTo: .max)
      let actualJSONPayload = try decoder.decode(Operations.post_sol_event.Input.Body.jsonPayload.self, from: data)
      let expectedJSONPayload = Operations.post_sol_event.Input.Body.jsonPayload(event: event, defaultDomain: defaultDomain)
      XCTAssertEqual(actualJSONPayload, expectedJSONPayload)
    }
    // XCTest Documentation
    // https://developer.apple.com/documentation/xctest

    // Defining Test Cases and Test Methods
    // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
  }
}
