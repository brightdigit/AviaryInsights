//
//  AviaryInsightsTests.swift
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
import Testing

@testable import AviaryInsights

internal struct AviaryInsightsTests {
  private let decoder = JSONDecoder()
  private let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    return encoder
  }()

  private func makeClient(defaultDomain: String) -> (MockTransport, Plausible) {
    let transport = MockTransport {
      .init(response: .init(status: .accepted), body: "{}")
    }
    let client = Plausible(
      transport: transport,
      defaultDomain: defaultDomain,
      userAgent: UUID().uuidString
    )
    return (transport, client)
  }

  private func assert(
    events: [Event],
    requests: [MockTransport.Request],
    defaultDomain: String
  ) async throws {
    for (event, request) in zip(events, requests) {
      let body = try #require(request.body)
      let data = try await Data(collecting: body, upTo: .max)
      let actualJSONPayload = try decoder.decode(
        Operations.post_sol_event.Input.Body.jsonPayload.self,
        from: data
      )
      let expectedJSONPayload = Operations.post_sol_event.Input.Body.jsonPayload(
        event: event,
        defaultDomain: defaultDomain
      )
      let actualEncoded = try encoder.encode(actualJSONPayload)
      let expectedEncoded = try encoder.encode(expectedJSONPayload)
      #expect(actualEncoded == expectedEncoded)
    }
  }

  @Test internal func postEvent() async throws {
    let defaultDomain = UUID().uuidString
    let (transport, client) = makeClient(defaultDomain: defaultDomain)
    let events = (0..<Int.random(in: 10...20)).map { _ in Event.random() }
    for event in events { try await client.postEvent(event) }
    let requests = await transport.sentRequests
    try await assert(events: events, requests: requests, defaultDomain: defaultDomain)
  }
}
