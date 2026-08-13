//
//  DiagnosticsMiddleware.swift
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
