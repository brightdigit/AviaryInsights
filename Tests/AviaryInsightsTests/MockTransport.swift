//
//  MockTransport.swift
//  AviaryInsights
//
//  Created by Leo Dion.
//  Copyright © 2024 BrightDigit.
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

internal final actor MockTransport: ClientTransport {
  // periphery:ignore
  internal struct Request {
    internal init(request: HTTPRequest, body: HTTPBody? = nil, baseURL: URL, operationID: String) {
      self.request = request
      self.body = body
      self.baseURL = baseURL
      self.operationID = operationID
    }

    private let request: HTTPRequest
    internal let body: HTTPBody?
    private let baseURL: URL
    private let operationID: String
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

  internal private(set) var sentRequests = [Request]()
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
    sentRequests.append(.init(request: request, body: body, baseURL: baseURL, operationID: operationID))
    return nextResponse().tuple()
  }
}
