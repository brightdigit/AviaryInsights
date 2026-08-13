//
//  Plausible+URLSession.swift
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

#if canImport(OpenAPIURLSession)
  import Foundation
  import OpenAPIURLSession

  #if canImport(FoundationNetworking)
    import FoundationNetworking
  #endif

  extension Plausible {
    /// Initializes a Plausible instance using the default `URLSessionTransport`.
    /// - Parameters:
    ///   - defaultDomain: Default domain associated with the Plausible instance.
    ///   - userAgent: User-Agent string for visitor identification.
    ///   - serverURL: Server URL for the Plausible API. Defaults to `defaultServerURL`.
    ///   - diagnostics: Handler receiving each response's ``PlausibleDiagnostics``.
    ///     Defaults to `nil` (no reporting).
    public init(
      defaultDomain: String,
      userAgent: String,
      serverURL: URL = Self.defaultServerURL,
      diagnostics: (@Sendable (PlausibleDiagnostics) -> Void)? = nil
    ) {
      self.init(
        transport: URLSessionTransport(),
        defaultDomain: defaultDomain,
        userAgent: userAgent,
        serverURL: serverURL,
        diagnostics: diagnostics
      )
    }

    /// Initializes a Plausible instance with a custom `URLSessionTransport.Configuration`.
    /// - Parameters:
    ///   - defaultDomain: Default domain associated with the Plausible instance.
    ///   - userAgent: User-Agent string for visitor identification.
    ///   - serverURL: Server URL for the Plausible API. Defaults to `defaultServerURL`.
    ///   - configuration: Configuration for URLSessionTransport. Defaults to `nil`.
    ///   - diagnostics: Handler receiving each response's ``PlausibleDiagnostics``.
    ///     Defaults to `nil` (no reporting).
    public init(
      defaultDomain: String,
      userAgent: String,
      serverURL: URL = Self.defaultServerURL,
      configuration: URLSessionTransport.Configuration,
      diagnostics: (@Sendable (PlausibleDiagnostics) -> Void)? = nil
    ) {
      let transport: URLSessionTransport = .init(configuration: configuration)
      self.init(
        transport: transport,
        defaultDomain: defaultDomain,
        userAgent: userAgent,
        serverURL: serverURL,
        diagnostics: diagnostics
      )
    }

    /// Initializes a Plausible instance with a custom URLSession.
    /// - Parameters:
    ///   - session: URLSession to use for making requests.
    ///   - defaultDomain: Default domain associated with the Plausible instance.
    ///   - userAgent: User-Agent string for visitor identification.
    ///   - serverURL: Server URL for the Plausible API. Defaults to `defaultServerURL`.
    ///   - diagnostics: Handler receiving each response's ``PlausibleDiagnostics``.
    ///     Defaults to `nil` (no reporting).
    public init(
      session: URLSession,
      defaultDomain: String,
      userAgent: String,
      serverURL: URL = Self.defaultServerURL,
      diagnostics: (@Sendable (PlausibleDiagnostics) -> Void)? = nil
    ) {
      self.init(
        defaultDomain: defaultDomain,
        userAgent: userAgent,
        serverURL: serverURL,
        configuration: .init(session: session),
        diagnostics: diagnostics
      )
    }
  }
#endif
