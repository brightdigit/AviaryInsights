//
//  IPAddressTests.swift
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

import Testing

@testable import AviaryInsights

@Suite("IPAddress") internal struct IPAddressTests {
  /// Dotted-quad forms that must survive a parse/render round trip unchanged.
  private static let ipv4RoundTrips = [
    "0.0.0.0", "127.0.0.1", "203.0.113.7", "198.51.100.42", "255.255.255.255",
  ]

  /// Text on the left must render as the RFC 5952 canonical form on the right.
  private static let ipv6Canonical = [
    ("2001:0db8:0000:0000:0000:0000:0000:0001", "2001:db8::1"),
    ("2001:db8::1", "2001:db8::1"),
    ("::", "::"),
    ("::1", "::1"),
    ("1::", "1::"),
    ("2001:DB8:ABCD:0:0:0:0:1", "2001:db8:abcd::1"),
    ("1:0:0:0:2:0:0:3", "1::2:0:0:3"),
    ("1:0:0:2:0:0:3:4", "1::2:0:0:3:4"),
    ("1:2:3:4:5:6:0:8", "1:2:3:4:5:6:0:8"),
    ("::ffff:203.0.113.7", "::ffff:cb00:7107"),
    ("0:0:0:0:0:ffff:203.0.113.7", "::ffff:cb00:7107"),
  ]

  /// Text that must not parse at all.
  private static let invalidText = [
    "", "256.0.0.1", "1.2.3", "1.2.3.4.5", "1.2.3.4.", "01.2.3.q", "+1.2.3.4",
    " 203.0.113.7", "::1::2", "2001:db8:::1", ":", ":::", "1:2:3:4:5:6:7",
    "1:2:3:4:5:6:7:8:9", "12345::1", "2001:db8::1:", "2001:db8::gggg",
  ]

  @Test internal func ipv4TextRoundTrips() {
    for text in Self.ipv4RoundTrips {
      let address = IPAddress(text)
      #expect(address?.description == text, "\(text)")
      #expect(address?.family == .v4, "\(text)")
      #expect(address?.bytes.count == 4, "\(text)")
    }
  }

  @Test internal func ipv6TextRendersCanonically() {
    for (text, canonical) in Self.ipv6Canonical {
      let address = IPAddress(text)
      #expect(address?.description == canonical, "\(text)")
      #expect(address?.family == .v6, "\(text)")
      #expect(address?.bytes.count == 16, "\(text)")
    }
  }

  @Test internal func canonicalTextRoundTrips() {
    for (text, canonical) in Self.ipv6Canonical {
      #expect(IPAddress(text) == IPAddress(canonical), "\(text)")
    }
  }

  @Test internal func spellingsOfTheSameAddressAreEqual() throws {
    let expanded = try #require(IPAddress("2001:0db8:0000:0000:0000:0000:0000:0001"))
    let compressed = try #require(IPAddress("2001:db8::1"))
    #expect(expanded == compressed)
    #expect(expanded.hashValue == compressed.hashValue)
    #expect(expanded.description == "2001:db8::1")
    #expect(IPAddress("2001:DB8::1") == compressed)
  }

  @Test internal func rejectsInvalidText() {
    for text in Self.invalidText {
      #expect(IPAddress(text) == nil, "\(text)")
    }
  }

  @Test internal func octetInitializerBuildsIPv4() {
    #expect(IPAddress(127, 0, 0, 1) == .loopback)
    #expect(IPAddress(127, 0, 0, 1).description == "127.0.0.1")
    #expect(IPAddress(203, 0, 113, 7) == IPAddress("203.0.113.7"))
    #expect(IPAddress(127, 0, 0, 1).bytes == [127, 0, 0, 1])
  }

  @Test internal func byteInitializerAcceptsOnlyFourOrSixteenBytes() {
    #expect(IPAddress(bytes: [127, 0, 0, 1]) == .loopback)
    #expect(IPAddress(bytes: [UInt8](repeating: 0, count: 16)) == .ipv6Unspecified)
    #expect(IPAddress(bytes: [UInt8](repeating: 0, count: 8)) == nil)
    #expect(IPAddress(bytes: [UInt8](repeating: 0, count: 0)) == nil)
    #expect(IPAddress(bytes: [1, 2, 3]) == nil)
    #expect(IPAddress(bytes: [9, 127, 0, 0, 1].dropFirst()) == .loopback)
  }

  @Test internal func groupInitializerAcceptsOnlyEightGroups() {
    #expect(IPAddress(groups: [0, 0, 0, 0, 0, 0, 0, 1]) == .ipv6Loopback)
    #expect(IPAddress(groups: [0x2001, 0x0DB8, 0, 0, 0, 0, 0, 1]) == IPAddress("2001:db8::1"))
    #expect(IPAddress(groups: [0, 0, 0, 0, 0, 0, 1]) == nil)
    #expect(IPAddress(groups: [0, 0, 0, 0, 0, 0, 0, 0, 1]) == nil)
    #expect(IPAddress(groups: []) == nil)
  }

  @Test internal func constantsHaveTheExpectedValues() {
    #expect(IPAddress.loopback.description == "127.0.0.1")
    #expect(IPAddress.unspecified.description == "0.0.0.0")
    #expect(IPAddress.broadcast.description == "255.255.255.255")
    #expect(IPAddress.ipv6Loopback.description == "::1")
    #expect(IPAddress.ipv6Unspecified.description == "::")
    #expect(IPAddress.loopback.family == .v4)
    #expect(IPAddress.ipv6Loopback.family == .v6)
  }

  @Test internal func testHelperAddressesAreTheDocumentationRanges() {
    #expect(IPAddress.example.description == "203.0.113.7")
    #expect(IPAddress.ipv6Example.description == "2001:db8::1")
  }
}
