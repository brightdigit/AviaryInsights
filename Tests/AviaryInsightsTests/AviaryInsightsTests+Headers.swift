//
//  AviaryInsightsTests+Headers.swift
//  AviaryInsights
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
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
import HTTPTypes
import Testing

@testable import AviaryInsights

extension AviaryInsightsTests {
  /// Covers the optional `X-Forwarded-For` and `X-Debug-Request` headers.
  ///
  /// Nested so the suite compiles whether the parent is a `struct` or an
  /// `enum`.
  @Suite("Headers") internal struct Headers {
    private static func transport() -> MockTransport {
      MockTransport { .init(response: .init(status: .accepted), body: "{}") }
    }

    private static func client(transport: MockTransport, userAgent: String) -> Plausible {
      Plausible(
        transport: transport,
        defaultDomain: UUID().uuidString,
        userAgent: userAgent
      )
    }

    private func firstRequest(
      from transport: MockTransport
    ) async throws -> MockTransport.Request {
      var requests = await transport.sentRequests
      for _ in 0..<100 where requests.isEmpty {
        try await Task.sleep(nanoseconds: 10_000_000)
        requests = await transport.sentRequests
      }
      return try #require(requests.first)
    }

    private func header(
      _ name: String,
      on request: MockTransport.Request
    ) throws -> String? {
      let fieldName = try #require(HTTPField.Name(name))
      return request.headerFields[fieldName]
    }

    // A single IPv4 address throughout: the generated client percent-encodes
    // header values, so both the `:` in an IPv6 address and the `,` separating
    // a multi-address list arrive escaped. See the caveat in the README.
    @Test internal func postEventSendsOptionalHeaders() async throws {
      let transport = Self.transport()
      let userAgent = UUID().uuidString
      let client = Self.client(transport: transport, userAgent: userAgent)
      try await client.postEvent(.random(), forwardedFor: [.example], debugRequest: true)
      let request = try await firstRequest(from: transport)
      #expect(try header("User-Agent", on: request) == userAgent)
      #expect(try header("X-Forwarded-For", on: request) == IPAddress.example.description)
      #expect(try header("X-Debug-Request", on: request) == "true")
    }

    @Test internal func postEventOmitsUnsetOptionalHeaders() async throws {
      let transport = Self.transport()
      let client = Self.client(transport: transport, userAgent: UUID().uuidString)
      try await client.postEvent(.random())
      let request = try await firstRequest(from: transport)
      #expect(try header("X-Forwarded-For", on: request) == nil)
      #expect(try header("X-Debug-Request", on: request) == nil)
    }

    @Test internal func postEventInBackgroundSendsOptionalHeaders() async throws {
      let transport = Self.transport()
      let forwardedFor = IPAddress(198, 51, 100, 42)
      let client = Self.client(transport: transport, userAgent: UUID().uuidString)
      // Both overloads apply in an `async throws` context and the `async` one
      // wins, so bind the fire-and-forget one explicitly.
      let post: (Event, [IPAddress]?, Bool?) -> Void = client.postEvent
      post(.random(), [forwardedFor], false)
      let request = try await firstRequest(from: transport)
      #expect(try header("X-Forwarded-For", on: request) == forwardedFor.description)
      #expect(try header("X-Debug-Request", on: request) == "false")
    }
  }
}
