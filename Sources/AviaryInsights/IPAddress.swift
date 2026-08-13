//
//  IPAddress.swift
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

/// An IPv4 or IPv6 address.
///
/// The value is stored as raw bytes rather than text, so addresses that were
/// spelled differently still compare equal and render the same way:
/// `IPAddress("2001:0db8:0000:0000:0000:0000:0000:0001")` equals
/// `IPAddress("2001:db8::1")` and both describe themselves as `2001:db8::1`.
///
/// ```swift
/// guard let address = IPAddress("203.0.113.7") else { return }
/// try await plausible.postEvent(event, forwardedFor: [address])
/// ```
///
/// There is deliberately no `ExpressibleByStringLiteral` conformance: an
/// invalid literal would have to trap at runtime. Parse with ``init(_:)`` and
/// handle `nil`, or build one from bytes with a non-failing initializer.
public struct IPAddress: Sendable, Hashable, LosslessStringConvertible {
  // The case names match how the versions are written everywhere else.
  // swiftlint:disable identifier_name
  /// The IP version an ``IPAddress`` belongs to.
  public enum Family: Sendable, Hashable {
    /// IPv4: a 32-bit address written as four decimal octets.
    case v4
    /// IPv6: a 128-bit address written as eight hexadecimal groups.
    case v6
  }
  // swiftlint:enable identifier_name

  /// The IPv4 loopback address, `127.0.0.1`.
  public static let loopback = IPAddress(127, 0, 0, 1)

  /// The IPv4 unspecified address, `0.0.0.0`.
  public static let unspecified = IPAddress(0, 0, 0, 0)

  /// The IPv4 limited broadcast address, `255.255.255.255`.
  public static let broadcast = IPAddress(255, 255, 255, 255)

  /// The IPv6 loopback address, `::1`.
  public static let ipv6Loopback = IPAddress(
    family: .v6,
    bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]
  )

  /// The IPv6 unspecified address, `::`.
  public static let ipv6Unspecified = IPAddress(
    family: .v6,
    bytes: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  )

  /// The IP version this address belongs to.
  public let family: Family

  /// The address in network byte order.
  ///
  /// Four bytes for ``Family/v4``, sixteen for ``Family/v6``.
  public let bytes: [UInt8]

  private init(family: Family, bytes: some Collection<UInt8>) {
    self.family = family
    self.bytes = Array(bytes)
  }

  /// Creates an IPv4 address from its four octets.
  ///
  /// - Parameters:
  ///   - first: The most significant octet.
  ///   - second: The second octet.
  ///   - third: The third octet.
  ///   - fourth: The least significant octet.
  public init(_ first: UInt8, _ second: UInt8, _ third: UInt8, _ fourth: UInt8) {
    self.init(family: .v4, bytes: [first, second, third, fourth])
  }

  /// Creates an address from its raw bytes.
  ///
  /// Four bytes make an IPv4 address and sixteen make an IPv6 address; any
  /// other length returns `nil`.
  /// - Parameter bytes: The address in network byte order.
  public init?(bytes: some Collection<UInt8>) {
    switch bytes.count {
    case 4:
      self.init(family: .v4, bytes: bytes)
    case 16:
      self.init(family: .v6, bytes: bytes)
    default:
      return nil
    }
  }

  /// Creates an IPv6 address from its eight 16-bit groups.
  ///
  /// - Parameter groups: Exactly eight groups, most significant first. Any
  ///   other count returns `nil`.
  public init?(groups: [UInt16]) {
    guard groups.count == 8 else {
      return nil
    }
    var bytes: [UInt8] = []
    bytes.reserveCapacity(16)
    for group in groups {
      bytes.append(UInt8(truncatingIfNeeded: group >> 8))
      bytes.append(UInt8(truncatingIfNeeded: group))
    }
    self.init(family: .v6, bytes: bytes)
  }
}
