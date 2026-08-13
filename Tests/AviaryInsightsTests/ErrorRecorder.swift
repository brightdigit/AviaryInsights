//
//  ErrorRecorder.swift
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
import OpenAPIRuntime

/// Collects every error handed to a `Plausible` `onError` handler.
///
/// The handler is a synchronous `@Sendable` closure, so it cannot `await` an
/// actor. A lock is the portable way to read the captured errors back.
internal final class ErrorRecorder: @unchecked Sendable {
  private let lock = NSLock()
  private var storage: [any Error] = []

  /// Everything recorded so far, oldest first.
  internal var received: [any Error] {
    lock.lock()
    defer { lock.unlock() }
    return storage
  }

  /// The transport failure underneath the `ClientError` the generated client
  /// wraps every transport error in.
  internal static func underlyingError(of error: any Error) -> (any Error)? {
    (error as? ClientError)?.underlyingError
  }

  /// A handler to pass as `Plausible.init(onError:)`.
  internal func handler() -> @Sendable (any Error) -> Void {
    { error in
      self.lock.lock()
      defer { self.lock.unlock() }
      self.storage.append(error)
    }
  }

  /// Waits for at least one error.
  ///
  /// The fire-and-forget `postEvent` reports from a `Task` that outlives the
  /// call. Gives up after `attempts` 10ms polls so a regression fails an
  /// assertion rather than hanging.
  /// - Parameter attempts: Polls before giving up. Use a small value when
  ///   asserting that nothing arrives.
  internal func waitForError(attempts: Int = 100) async throws -> (any Error)? {
    for _ in 0..<attempts where received.isEmpty {
      try await Task.sleep(nanoseconds: 10_000_000)
    }
    return received.first
  }
}
