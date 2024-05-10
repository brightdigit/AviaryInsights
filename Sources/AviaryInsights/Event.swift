//
//  Event.swift
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

/// Represents an event in Plausible, such as a pageview or a custom event.
public struct Event: Sendable {
  /// Default name for a pageview event.
  public static let pageview = "pageview"

  /// Name of the event.
  public let name: String

  /// Domain name of the site in Plausible.
  public let domain: String?

  /// URL of the page where the event was triggered.
  public let url: String

  /// Referrer for this event.
  public let referrer: String?

  /// Custom properties for the event.
  public let props: [String: any Sendable]?

  /// Revenue data for this event.
  public let revenue: Revenue?

  /// Initializes an event.
  /// - Parameters:
  ///   - url: URL of the page where the event was triggered.
  ///   - name: Name of the event. Defaults to `pageview`.
  ///   - domain: Domain name of the site in Plausible. Defaults to `nil`.
  ///   - referrer: Referrer for this event. Defaults to `nil`.
  ///   - props: Custom properties for the event. Defaults to `nil`.
  ///   - revenue: Revenue data for this event. Defaults to `nil`.
  public init(
    url: String,
    name: String = Self.pageview,
    domain: String? = nil,
    referrer: String? = nil,
    props: [String: (any Sendable)?]? = nil,
    revenue: Revenue? = nil
  ) {
    self.name = name
    self.domain = domain
    self.url = url
    self.referrer = referrer
    self.props = props
    self.revenue = revenue
  }
}
