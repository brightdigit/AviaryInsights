//
//  Recorder.swift
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

/// Collects every value handed to a reporting callback under test.
///
/// Both `diagnostics` and `onError` are synchronous `@Sendable` closures, so
/// neither can `await` an actor. A lock is the portable way to make what they
/// captured readable from the test that installed them, and one generic
/// recorder keeps the two call sites from growing near-identical copies.
internal final class Recorder<Value>: @unchecked Sendable {
  private let lock = NSLock()
  private var storage: [Value] = []

  /// Everything recorded so far, oldest first.
  internal var received: [Value] {
    lock.lock()
    defer { lock.unlock() }
    return storage
  }

  /// A handler to hand to `Plausible` at initialization.
  ///
  /// - Returns: A closure appending each value it is called with.
  internal func handler() -> @Sendable (Value) -> Void {
    { value in
      self.lock.lock()
      defer { self.lock.unlock() }
      self.storage.append(value)
    }
  }

  /// Waits for at least one recorded value.
  ///
  /// The fire-and-forget `postEvent` reports from a `Task` that outlives the
  /// call. Gives up after `attempts` 10ms polls so a regression fails an
  /// assertion rather than hanging.
  /// - Parameter attempts: Polls before giving up. Use a small value when
  ///   asserting that nothing arrives.
  /// - Returns: The first value recorded, or `nil` if none arrived.
  internal func waitForValue(attempts: Int = 100) async throws -> Value? {
    for _ in 0..<attempts where received.isEmpty {
      try await Task.sleep(nanoseconds: 10_000_000)
    }
    return received.first
  }
}
