//
//  AviaryInsightsTests+PostEvent.swift
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

extension AviaryInsightsTests {
  /// What reaches the wire when an event is posted.
  @Suite("Post Event") internal struct PostEvent {
    /// How many events the batch test posts.
    ///
    /// Fixed rather than random so a failure reproduces from the test name
    /// alone. WASI runs a smaller batch because its interpreter is slow.
    private static let eventCount: Int = {
      #if os(WASI)
        3
      #else
        16
      #endif
    }()

    @Test internal func postsEveryEvent() async throws {
      let defaultDomain = UUID().uuidString
      let (transport, client) = Plausible.makeClient(defaultDomain: defaultDomain)
      let events = (0..<Self.eventCount).map { _ in Event.random() }
      for event in events { try await client.postEvent(event) }
      let requests = await transport.sentRequests
      try Plausible.assert(events: events, requests: requests, defaultDomain: defaultDomain)
    }

    @Test internal func postsInBackground() async throws {
      let defaultDomain = UUID().uuidString
      let (transport, client) = Plausible.makeClient(defaultDomain: defaultDomain)
      let event = Event.random()
      // In an `async throws` context the two `postEvent` overloads both apply
      // and the async one wins, so name the fire-and-forget one explicitly.
      let postInBackground: (Event) -> Void = client.postEvent
      postInBackground(event)
      let requests = try await transport.waitForRequests(count: 1)
      try Plausible.assert(events: [event], requests: requests, defaultDomain: defaultDomain)
    }

    @Test internal func sendsUserAgent() async throws {
      let userAgent = UUID().uuidString
      let (transport, client) = Plausible.makeClient(
        defaultDomain: UUID().uuidString,
        userAgent: userAgent
      )
      try await client.postEvent(.random())
      let request = try #require(await transport.sentRequests.first)
      #expect(try request.headerValue("User-Agent") == userAgent)
    }
  }
}
