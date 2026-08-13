//
//  MockTransport.swift
//  AviaryInsights
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
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
import Testing

internal final actor MockTransport: ClientTransport {
  internal struct Request {
    private let request: HTTPRequest
    internal let body: Data?
    private let baseURL: URL
    private let operationID: String

    /// Headers the client actually put on the wire.
    internal var headerFields: HTTPFields { request.headerFields }

    internal init(request: HTTPRequest, body: Data? = nil, baseURL: URL, operationID: String) {
      self.request = request
      self.body = body
      self.baseURL = baseURL
      self.operationID = operationID
    }

    /// Reads a header off the recorded request, failing the test if absent.
    ///
    /// - Parameter name: Name of the header field to read.
    /// - Returns: The value the client sent for that header.
    internal func headerValue(_ name: String) throws -> String {
      let fieldName = try #require(HTTPField.Name(name))
      return try #require(headerFields[fieldName])
    }
  }

  internal struct Response {
    private let response: HTTPResponse
    private let body: HTTPBody?

    internal init(response: HTTPResponse, body: HTTPBody? = nil) {
      self.response = response
      self.body = body
    }

    fileprivate func tuple() -> (HTTPResponse, HTTPBody?) {
      (response, body)
    }
  }

  internal private(set) var sentRequests: [Request] = []
  private let nextResponse: @Sendable () -> Response

  internal init(nextResponse: @escaping @Sendable () -> Response) {
    sentRequests = []
    self.nextResponse = nextResponse
  }

  internal func send(
    _ request: HTTPRequest,
    body: HTTPBody?,
    baseURL: URL,
    operationID: String
  ) async throws -> (HTTPResponse, HTTPBody?) {
    var bodyData: Data?
    if let body {
      var bytes: [UInt8] = []
      for try await chunk in body { bytes.append(contentsOf: chunk) }
      bodyData = Data(bytes)
    }
    sentRequests.append(
      .init(request: request, body: bodyData, baseURL: baseURL, operationID: operationID)
    )
    return nextResponse().tuple()
  }

  /// Waits for at least `count` requests to arrive.
  ///
  /// Exists for the fire-and-forget `postEvent` overload, whose `Task`
  /// completes after the caller returns. Gives up after roughly a second and
  /// returns whatever was recorded, so a regression fails on the assertion
  /// rather than hanging the suite.
  internal func waitForRequests(count: Int) async throws -> [Request] {
    for _ in 0..<100 where sentRequests.count < count {
      try await Task.sleep(nanoseconds: 10_000_000)
    }
    return sentRequests
  }
}
