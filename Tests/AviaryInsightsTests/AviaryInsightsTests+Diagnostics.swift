//
//  AviaryInsightsTests+Diagnostics.swift
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
  /// What the `diagnostics` handler is told about each response.
  @Suite("Diagnostics") internal struct Diagnostics {
    /// Plausible's discard marker: present and `1` means the event was not
    /// recorded, even though the status is still 202.
    private static let droppedHeader = "x-plausible-dropped"

    /// Builds a 202 response, optionally carrying the discard marker.
    ///
    /// - Parameter dropped: Whether to set `x-plausible-dropped: 1`.
    /// - Returns: The response for `MockTransport` to reply with.
    private static func response(dropped: Bool) throws -> MockTransport.Response {
      let name = try #require(HTTPField.Name(droppedHeader))
      let fields: HTTPFields = dropped ? [name: "1"] : [:]
      return .init(response: .init(status: .accepted, headerFields: fields), body: "{}")
    }

    @Test internal func reportsAcceptedEvent() async throws {
      let recorder = Recorder<PlausibleDiagnostics>()
      let response = try Self.response(dropped: false)
      let (_, client) = Plausible.makeClient(
        defaultDomain: UUID().uuidString,
        diagnostics: recorder.handler(),
        nextResponse: { response }
      )
      try await client.postEvent(.random())
      let diagnostics = try #require(recorder.received.first)
      #expect(recorder.received.count == 1)
      #expect(diagnostics.statusCode == 202)
      #expect(!diagnostics.dropped)
    }

    @Test internal func reportsDroppedEvent() async throws {
      let recorder = Recorder<PlausibleDiagnostics>()
      let response = try Self.response(dropped: true)
      let (_, client) = Plausible.makeClient(
        defaultDomain: UUID().uuidString,
        diagnostics: recorder.handler(),
        nextResponse: { response }
      )
      try await client.postEvent(.random())
      let diagnostics = try #require(recorder.received.first)
      #expect(diagnostics.statusCode == 202)
      #expect(diagnostics.dropped)
    }

    @Test internal func reportsEveryEvent() async throws {
      let recorder = Recorder<PlausibleDiagnostics>()
      let (_, client) = Plausible.makeClient(
        defaultDomain: UUID().uuidString,
        diagnostics: recorder.handler()
      )
      for _ in 0..<3 { try await client.postEvent(.random()) }
      #expect(recorder.received.count == 3)
    }
  }
}
