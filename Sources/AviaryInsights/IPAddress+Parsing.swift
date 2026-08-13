//
//  IPAddress+Parsing.swift
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

extension IPAddress {
  /// Parses an address from its textual form.
  ///
  /// Accepts IPv4 dotted-quad notation and the IPv6 forms of RFC 4291,
  /// including `::` zero compression and an embedded IPv4 tail such as
  /// `::ffff:203.0.113.7`. Anything else returns `nil`.
  /// - Parameter text: The address to parse.
  public init?(_ text: String) {
    let source = Substring(text)
    guard !source.isEmpty else {
      return nil
    }
    let parsed: IPAddress?
    if source.contains(":") {
      parsed = Self.parseIPv6(source)
    } else {
      parsed = Self.parseIPv4(source).flatMap { IPAddress(bytes: $0) }
    }
    guard let parsed else {
      return nil
    }
    self = parsed
  }

  private static func parseIPv4(_ text: Substring) -> [UInt8]? {
    let parts = text.split(separator: ".", omittingEmptySubsequences: false)
    guard parts.count == 4 else {
      return nil
    }
    let octets = parts.compactMap(parseOctet)
    guard octets.count == 4 else {
      return nil
    }
    return octets
  }

  private static func parseOctet(_ text: Substring) -> UInt8? {
    guard !text.isEmpty, text.count <= 3, text.allSatisfy(isASCIIDigit) else {
      return nil
    }
    return UInt8(text)
  }

  private static func isASCIIDigit(_ character: Character) -> Bool {
    character.isASCII && character.isNumber
  }

  private static func parseIPv6(_ text: Substring) -> IPAddress? {
    guard let split = splitCompression(text) else {
      return nil
    }
    guard let head = parseGroupList(split.head, allowIPv4: split.tail == nil) else {
      return nil
    }
    guard let tail = parseGroupList(split.tail ?? "", allowIPv4: true) else {
      return nil
    }
    return assemble(head: head, tail: tail, compressed: split.tail != nil)
  }

  /// Splits the text around its `::`, if it has one.
  ///
  /// A `nil` `tail` means the address is uncompressed, which is different from
  /// an empty tail: `1::` is compressed with nothing after the `::`.
  private static func splitCompression(
    _ text: Substring
  ) -> (head: Substring, tail: Substring?)? {
    let positions = doubleColonPositions(in: Array(text))
    guard positions.count <= 1 else {
      return nil
    }
    guard let position = positions.first else {
      return (text, nil)
    }
    let start = text.index(text.startIndex, offsetBy: position)
    let end = text.index(start, offsetBy: 2)
    return (text[..<start], text[end...])
  }

  private static func doubleColonPositions(in characters: [Character]) -> [Int] {
    var positions: [Int] = []
    var index = 0
    while index + 1 < characters.count {
      if characters[index] == ":", characters[index + 1] == ":" {
        positions.append(index)
        index += 2
      } else {
        index += 1
      }
    }
    return positions
  }

  private static func parseGroupList(_ text: Substring, allowIPv4: Bool) -> [UInt16]? {
    guard !text.isEmpty else {
      return []
    }
    let tokens = text.split(separator: ":", omittingEmptySubsequences: false)
    var groups: [UInt16] = []
    for (index, token) in tokens.enumerated() {
      let isTail = allowIPv4 && index == tokens.count - 1
      guard let parsed = parseToken(token, allowIPv4: isTail) else {
        return nil
      }
      groups.append(contentsOf: parsed)
    }
    return groups
  }

  private static func parseToken(_ token: Substring, allowIPv4: Bool) -> [UInt16]? {
    if allowIPv4, token.contains(".") {
      guard let octets = parseIPv4(token) else {
        return nil
      }
      return [
        UInt16(octets[0]) << 8 | UInt16(octets[1]),
        UInt16(octets[2]) << 8 | UInt16(octets[3]),
      ]
    }
    guard let group = parseHexGroup(token) else {
      return nil
    }
    return [group]
  }

  private static func parseHexGroup(_ token: Substring) -> UInt16? {
    guard !token.isEmpty, token.count <= 4, token.allSatisfy(isASCIIHexDigit) else {
      return nil
    }
    return UInt16(token, radix: 16)
  }

  private static func isASCIIHexDigit(_ character: Character) -> Bool {
    character.isASCII && character.isHexDigit
  }

  private static func assemble(head: [UInt16], tail: [UInt16], compressed: Bool) -> IPAddress? {
    let count = head.count + tail.count
    guard compressed ? count < 8 : count == 8 else {
      return nil
    }
    let zeros = [UInt16](repeating: 0, count: 8 - count)
    return IPAddress(groups: head + zeros + tail)
  }
}
