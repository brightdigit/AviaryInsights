//
//  IPAddress+Description.swift
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
  /// The canonical textual form of the address.
  ///
  /// IPv4 addresses render as dotted-quad. IPv6 addresses follow RFC 5952:
  /// lowercase hexadecimal, no leading zeros within a group, and the longest
  /// run of two or more all-zero groups collapsed to `::` — the leftmost run
  /// when several are equally long.
  public var description: String {
    switch family {
    case .v4:
      Self.describeIPv4(bytes)
    case .v6:
      Self.describeIPv6(bytes)
    }
  }

  private static func describeIPv4(_ bytes: [UInt8]) -> String {
    bytes.map { String($0) }.joined(separator: ".")
  }

  private static func describeIPv6(_ bytes: [UInt8]) -> String {
    let groups = stride(from: 0, to: bytes.count, by: 2).map { offset in
      UInt16(bytes[offset]) << 8 | UInt16(bytes[offset + 1])
    }
    guard let run = longestZeroRun(in: groups) else {
      return hexJoined(groups[...])
    }
    return hexJoined(groups[..<run.lowerBound]) + "::" + hexJoined(groups[run.upperBound...])
  }

  private static func hexJoined(_ groups: ArraySlice<UInt16>) -> String {
    groups.map { String($0, radix: 16) }.joined(separator: ":")
  }

  private static func longestZeroRun(in groups: [UInt16]) -> Range<Int>? {
    var best: Range<Int>?
    var start: Int?
    for index in 0...groups.count {
      if index < groups.count, groups[index] == 0 {
        start = start ?? index
        continue
      }
      best = longer(best, start.map { $0..<index })
      start = nil
    }
    return best
  }

  private static func longer(_ current: Range<Int>?, _ candidate: Range<Int>?) -> Range<Int>? {
    guard let candidate, candidate.count >= 2 else {
      return current
    }
    guard let current else {
      return candidate
    }
    return candidate.count > current.count ? candidate : current
  }
}
