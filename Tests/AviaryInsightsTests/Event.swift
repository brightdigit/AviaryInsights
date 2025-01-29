//
//  Event.swift
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

import AviaryInsights
import Foundation

extension Event {
  private static func randomProps() -> [String: (any Sendable)?] {
    var values = [String: (any Sendable)?]()
    let keyCount: Int = .random(in: 3 ... 7)
    for _ in 0 ..< keyCount {
      let value: any Sendable
      let type: Bool = .random()
      switch type {
      case false:
        value = Int.random(in: 100 ... 999)
      case true:
        value = UUID().uuidString
      }
      values[UUID().uuidString] = value
    }
    return values
  }

  internal static func random() -> Event {
    Event(
      url: UUID().uuidString,
      name: UUID().uuidString,
      domain: Bool.random() ? UUID().uuidString : nil,
      referrer: Bool.random() ? UUID().uuidString : nil,
      props: Bool.random() ? randomProps() : nil,
      revenue: Bool.random() ? .random() : nil
    )
  }
}
