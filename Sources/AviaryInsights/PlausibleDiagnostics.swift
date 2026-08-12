//
//  PlausibleDiagnostics.swift
//  AviaryInsights
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
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
import HTTPTypes
import OpenAPIRuntime

/// Per-request outcome details Plausible does not surface through its status
/// code alone.
///
/// Plausible's events API returns **202 even for events it discards**, so a
/// successful `postEvent` does not prove the event was recorded. The discard
/// signal it exposes is the `x-plausible-dropped: 1` response header — the
/// docs describe it for bot filtering, but it is also set for an unknown
/// `domain` (empirically verified 2026-08-12). See
/// https://plausible.io/docs/events-api.
public struct PlausibleDiagnostics: Sendable {
  /// The HTTP status code of the response (202 on the accepted path).
  public let statusCode: Int

  /// Whether Plausible reported the event dropped
  /// (`x-plausible-dropped: 1` — bot filtering or an unknown `domain`).
  public let dropped: Bool
}

/// A client middleware that reports each response's ``PlausibleDiagnostics``
/// to a caller-supplied handler, so integrators can log why an event vanished.
internal struct DiagnosticsMiddleware: ClientMiddleware {
  private static let droppedHeader = HTTPField.Name("x-plausible-dropped")

  internal let handler: @Sendable (PlausibleDiagnostics) -> Void

  internal init(handler: @escaping @Sendable (PlausibleDiagnostics) -> Void) {
    self.handler = handler
  }

  internal func intercept(
    _ request: HTTPRequest,
    body: HTTPBody?,
    baseURL: URL,
    operationID _: String,
    next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
  ) async throws -> (HTTPResponse, HTTPBody?) {
    let (response, responseBody) = try await next(request, body, baseURL)
    let dropped = Self.droppedHeader.map { response.headerFields[$0] == "1" } ?? false
    handler(
      PlausibleDiagnostics(statusCode: response.status.code, dropped: dropped)
    )
    return (response, responseBody)
  }
}
