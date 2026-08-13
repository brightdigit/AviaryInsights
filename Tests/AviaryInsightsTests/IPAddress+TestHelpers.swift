//
//  IPAddress+TestHelpers.swift
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

@testable import AviaryInsights

// Sample addresses for tests only — deliberately not part of the public API.
extension IPAddress {
  /// RFC 5737 documentation address `203.0.113.7`.
  internal static let example = IPAddress(203, 0, 113, 7)

  /// RFC 3849 documentation address `2001:db8::1`.
  ///
  /// Built from groups rather than text so no force unwrap is needed; the
  /// fallback is never reached in practice and `IPAddressTests` asserts the
  /// real value.
  internal static let ipv6Example =
    IPAddress(groups: [0x2001, 0x0DB8, 0, 0, 0, 0, 0, 1]) ?? .ipv6Unspecified
}
