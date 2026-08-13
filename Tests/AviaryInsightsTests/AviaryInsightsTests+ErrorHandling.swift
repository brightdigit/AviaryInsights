//
//  AviaryInsightsTests+ErrorHandling.swift
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
  private func makeFailingClient(
    failure: ThrowingTransport.Failure,
    onError: @escaping @Sendable (any Error) -> Void
  ) -> Plausible {
    Plausible(
      transport: ThrowingTransport(failure: failure),
      defaultDomain: UUID().uuidString,
      userAgent: UUID().uuidString,
      onError: onError
    )
  }

  @Test internal func postEventInBackgroundReportsFailure() async throws {
    let recorder = ErrorRecorder()
    let failure = ThrowingTransport.Failure()
    let client = makeFailingClient(failure: failure, onError: recorder.handler())
    let postInBackground: (Event) -> Void = client.postEvent
    postInBackground(.random())
    let error = try #require(await recorder.waitForError())
    // The generated client wraps every transport error in a ClientError.
    let underlying = try #require(ErrorRecorder.underlyingError(of: error))
    #expect(underlying as? ThrowingTransport.Failure == failure)
  }

  @Test internal func onErrorCanSuppressFailures() async throws {
    let recorder = ErrorRecorder()
    let client = Plausible(
      transport: ThrowingTransport(),
      defaultDomain: UUID().uuidString,
      userAgent: UUID().uuidString,
      onError: { _ in }
    )
    let postInBackground: (Event) -> Void = client.postEvent
    postInBackground(.random())
    _ = try await recorder.waitForError(attempts: 20)
    #expect(recorder.received.isEmpty)
  }

  @Test internal func onErrorIsSilentOnSuccess() async throws {
    let recorder = ErrorRecorder()
    let transport = MockTransport {
      .init(response: .init(status: .accepted), body: "{}")
    }
    let client = Plausible(
      transport: transport,
      defaultDomain: UUID().uuidString,
      userAgent: UUID().uuidString,
      onError: recorder.handler()
    )
    let postInBackground: (Event) -> Void = client.postEvent
    postInBackground(.random())
    _ = try await recorder.waitForError(attempts: 20)
    #expect(recorder.received.isEmpty)
    #expect(await transport.sentRequests.count == 1)
  }

  @Test internal func throwingOverloadStillThrows() async throws {
    let failure = ThrowingTransport.Failure()
    let client = makeFailingClient(failure: failure, onError: { _ in })
    let thrown = await #expect(throws: (any Error).self) {
      try await client.postEvent(.random())
    }
    let error = try #require(thrown)
    let underlying = try #require(ErrorRecorder.underlyingError(of: error))
    #expect(underlying as? ThrowingTransport.Failure == failure)
  }
}
