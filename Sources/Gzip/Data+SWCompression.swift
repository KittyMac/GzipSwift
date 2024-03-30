//
//  Data+Gzip.swift
//

/*
 The MIT License (MIT)
 
 © 2014-2022 1024jp <wolfrosch.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#if os(Windows)

import SWCompression

import struct Foundation.Data

public enum Gzip {
    public static let maxWindowBits: Int32 = 15
}


/// Compression level whose rawValue is based on the zlib's constants.
public enum CompressionLevel: Int32 {
    case noCompression = 0
    case bestSpeed = 1
    case bestCompression = 2
    case defaultCompression = 9
}


/// Errors on gzipping/gunzipping based on the zlib error codes.
public struct GzipError: Swift.Error {
    public enum Kind: Equatable {
        case stream
        case data
        case memory
        case buffer
        case version
        case unknown(code: Int)
    }
    
    public let kind: Kind
    public let message: String
    
    internal init(code: Int32, msg: UnsafePointer<CChar>?) {
        self.message = msg.flatMap { String(validatingUTF8: $0) } ?? "Unknown gzip error"
        self.kind = {
            switch code {
            default:
                return .unknown(code: Int(code))
            }
        }()
    }
    
    public var localizedDescription: String {
        return self.message
    }
}


extension Data {
    
    /// Whether the receiver is compressed in gzip format.
    public var isGzipped: Bool {
        return self.starts(with: [0x1f, 0x8b])  // check magic number
    }
    
    
    /// Create a new `Data` instance by compressing the receiver using zlib.
    /// Throws an error if compression failed.
    ///
    /// The `wBits` parameter allows for managing the size of the history buffer. The possible values are:
    ///
    ///     Value       Window size logarithm    Input
    ///     +9 to +15   Base 2                   Includes zlib header and trailer
    ///     -9 to -15   Absolute value of wbits  No header and trailer
    ///     +25 to +31  Low 4 bits of the value  Includes gzip header and trailing checksum
    ///
    /// - Parameter level: Compression level.
    /// - Parameter wBits: Manage the size of the history buffer.
    /// - Returns: Gzip-compressed `Data` instance.
    /// - Throws: `GzipError`
    public func gzipped(level: CompressionLevel = .defaultCompression, wBits: Int32 = 0) throws -> Data {
        guard !self.isEmpty else {
            return Data()
        }
        return try GzipArchive.archive(data: self)
    }
    
    
    /// Create a new `Data` instance by decompressing the receiver using zlib.
    /// Throws an error if decompression failed.
    ///
    /// The `wBits` parameter allows for managing the size of the history buffer. The possible values are:
    ///
    ///     Value                        Window size logarithm    Input
    ///     +8 to +15                    Base 2                   Includes zlib header and trailer
    ///     -8 to -15                    Absolute value of wbits  Raw stream with no header and trailer
    ///     +24 to +31 = 16 + (8 to 15)  Low 4 bits of the value  Includes gzip header and trailer
    ///     +40 to +47 = 32 + (8 to 15)  Low 4 bits of the value  zlib or gzip format
    ///
    /// - Parameter wBits: Manage the size of the history buffer.
    /// - Returns: Gzip-decompressed `Data` instance.
    /// - Throws: `GzipError`
    public func gunzipped(wBits: Int32 = 0) throws -> Data {
        guard !self.isEmpty else {
            return Data()
        }
        if isGzipped {
            return try GzipArchive.unarchive(archive: self)
        }
        return try ZlibArchive.unarchive(archive: self)

    }
    
}

#endif
