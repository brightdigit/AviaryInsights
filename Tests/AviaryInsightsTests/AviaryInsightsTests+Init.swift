//
//  PlausibleInitTests.swift
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

#if canImport(OpenAPIURLSession)
  import OpenAPIURLSession
#endif

extension AviaryInsightsTests {
  @Test(.enabled(if: isOpenAPIURLSessionAvailable)) internal func initWithDefaultTransport() {
    let domain = UUID().uuidString
    let agent = UUID().uuidString
    #if canImport(OpenAPIURLSession)
      let client = Plausible(defaultDomain: domain, userAgent: agent)
      #expect(client.defaultDomain == domain)
      #expect(client.userAgent == agent)
    #else
      Issue.record("OpenAPIURLSession not available on this platform")
    #endif
  }

  @Test(.enabled(if: isOpenAPIURLSessionAvailable)) internal func initWithURLSessionConfiguration()
  {
    let domain = UUID().uuidString
    let agent = UUID().uuidString
    #if canImport(OpenAPIURLSession)
      let config = URLSessionTransport.Configuration()
      let client = Plausible(defaultDomain: domain, userAgent: agent, configuration: config)
      #expect(client.defaultDomain == domain)
      #expect(client.userAgent == agent)
    #else
      Issue.record("OpenAPIURLSession not available on this platform")
    #endif
  }

  @Test(.enabled(if: isOpenAPIURLSessionAvailable)) internal func initWithURLSession() {
    let domain = UUID().uuidString
    let agent = UUID().uuidString
    #if canImport(OpenAPIURLSession)
      let client = Plausible(session: .shared, defaultDomain: domain, userAgent: agent)
      #expect(client.defaultDomain == domain)
      #expect(client.userAgent == agent)
    #else
      Issue.record("OpenAPIURLSession not available on this platform")
    #endif
  }
}
