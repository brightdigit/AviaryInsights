//
//  Plausible+TestHelpers.swift
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
import Testing

@testable import AviaryInsights

extension Plausible {
  private static let decoder = JSONDecoder()
  private static let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    return encoder
  }()

  /// The response ``makeClient(defaultDomain:userAgent:diagnostics:onError:nextResponse:)``
  /// replies with unless a test overrides it.
  ///
  /// Plausible's normal `202 Accepted` with an empty JSON body.
  /// - Returns: An accepted response carrying `{}`.
  internal static func acceptedResponse() -> MockTransport.Response {
    .init(response: .init(status: .accepted), body: "{}")
  }

  /// Builds a ``Plausible`` backed by a ``MockTransport``, returning both so a
  /// test can inspect what was sent.
  ///
  /// - Parameters:
  ///   - defaultDomain: Default domain for the client.
  ///   - userAgent: User-Agent the client sends. Random by default.
  ///   - diagnostics: Optional diagnostics handler to install.
  ///   - onError: Delivery-failure handler for the fire-and-forget overload.
  ///   - nextResponse: Response the transport replies with.
  /// - Returns: The transport and the client wired to it.
  internal static func makeClient(
    defaultDomain: String,
    userAgent: String = UUID().uuidString,
    diagnostics: (@Sendable (PlausibleDiagnostics) -> Void)? = nil,
    onError: @escaping @Sendable (any Error) -> Void = Plausible.defaultErrorHandler,
    nextResponse: @escaping @Sendable () -> MockTransport.Response = Plausible.acceptedResponse
  ) -> (MockTransport, Plausible) {
    let transport = MockTransport(nextResponse: nextResponse)
    let client = Plausible(
      transport: transport,
      defaultDomain: defaultDomain,
      userAgent: userAgent,
      diagnostics: diagnostics,
      onError: onError
    )
    return (transport, client)
  }

  /// Asserts each recorded request carries the JSON payload its event implies.
  ///
  /// `zip` stops at the shorter sequence, so the count is required up front:
  /// without it a run that recorded nothing would loop zero times and pass
  /// having asserted nothing at all.
  /// - Parameters:
  ///   - events: Events that were posted, in order.
  ///   - requests: Requests the transport recorded, in order.
  ///   - defaultDomain: Domain the client was built with.
  internal static func assert(
    events: [Event],
    requests: [MockTransport.Request],
    defaultDomain: String
  ) throws {
    try #require(requests.count == events.count)
    for (event, request) in zip(events, requests) {
      let data = try #require(request.body)
      let actual = try encodedPayload(from: data)
      let expected = try encodedPayload(for: event, defaultDomain: defaultDomain)
      #expect(actual == expected)
    }
  }

  /// Re-encodes a recorded request body through the sorted-keys encoder.
  ///
  /// - Parameter data: The raw body bytes the transport recorded.
  /// - Returns: The payload encoded with sorted keys.
  private static func encodedPayload(from data: Data) throws -> Data {
    let payload = try decoder.decode(
      Operations.post_sol_event.Input.Body.jsonPayload.self,
      from: data
    )
    return try encoder.encode(payload)
  }

  /// Encodes the payload an event should have produced.
  ///
  /// - Parameters:
  ///   - event: The event that was posted.
  ///   - defaultDomain: Domain the client was built with.
  /// - Returns: The expected payload encoded with sorted keys.
  private static func encodedPayload(for event: Event, defaultDomain: String) throws -> Data {
    let payload = Operations.post_sol_event.Input.Body.jsonPayload(
      event: event,
      defaultDomain: defaultDomain
    )
    return try encoder.encode(payload)
  }
}
