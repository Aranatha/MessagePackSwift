import Foundation

/// MessagePack specification
/// https://github.com/msgpack/msgpack/blob/master/spec.md

/// Packs an integer into a byte array.
///
/// - parameter value: The integer to split.
/// - parameter parts: The number of bytes into which to split.
///
/// - returns: An byte array representation.
private func packInteger(_ value: UInt64,
                         parts: Int) -> Data {
    assert(parts > 0)
    assert(parts <= 8)
    let bytes = stride(from: (8 * (parts - 1)),
                       through: 0, by: -8).map { shift in
        return UInt8(truncatingIfNeeded: value >> UInt64(shift))
    }
    return Data(bytes)
}

/// Packs an unsigned integer into an array of bytes.
///
/// - parameter value: The value to encode
///
/// - returns: A MessagePack byte representation.
private func packPositiveInteger(_ value: UInt64) -> Data {
    if value <= 0x7f {
        return Data([UInt8(truncatingIfNeeded: value)])
    } else if value <= 0xff {
        return Data([0xcc, UInt8(truncatingIfNeeded: value)])
    } else if value <= 0xffff {
        return Data([0xcd]) + packInteger(value, parts: 2)
    } else if value <= 0xffff_ffff as UInt64 {
        return Data([0xce]) + packInteger(value, parts: 4)
    } else {
        return Data([0xcf]) + packInteger(value, parts: 8)
    }
}

/// Packs a signed integer into an array of bytes.
///
/// - parameter value: The value to encode
///
/// - returns: A MessagePack byte representation.
private func packNegativeInteger(_ value: Int64) -> Data {
    assert(value < 0)
    if value >= -0x20 {
        return Data([0xe0 + 0x1f & UInt8(truncatingIfNeeded: value)])
    } else if value >= -0x7f {
        return Data([0xd0, UInt8(bitPattern: Int8(value))])
    } else if value >= -0x7fff {
        let truncated = UInt16(bitPattern: Int16(value))
        return Data([0xd1]) + packInteger(UInt64(truncated), parts: 2)
    } else if value >= -0x7fff_ffff {
        let truncated = UInt32(bitPattern: Int32(value))
        return Data([0xd2]) + packInteger(UInt64(truncated), parts: 4)
    } else {
        let truncated = UInt64(bitPattern: value)
        return Data([0xd3]) + packInteger(truncated, parts: 8)
    }
}

/// Format to use for packing. Old format encodes binary as invalid utf-8 strings and must be decoded in compatibility mode.
public enum PackFormat {
    case latest
    case old
}

/// Packs a MessagePackValue into an array of bytes.
///
/// - parameter value: The value to encode
///
/// - returns: A MessagePack byte representation.
public func pack(_ value: MessagePackValue, format: PackFormat = .latest) -> Data {
    switch value {
    case .nil:
        return Data([0xc0])

    case .bool(let value):
        return Data([value ? 0xc3 : 0xc2])

    case .int(let value):
        if value >= 0 {
            return packPositiveInteger(UInt64(value))
        } else {
            return packNegativeInteger(value)
        }

    case .uint(let value):
        return packPositiveInteger(value)

    case .float(let value):
        return Data([0xca]) + packInteger(UInt64(value.bitPattern), parts: 4)

    case .double(let value):
        return Data([0xcb]) + packInteger(value.bitPattern, parts: 8)

    case .string(let string):
        let utf8 = string.utf8
        let count = UInt32(utf8.count)
        assert(count <= 0xffff_ffff as UInt32)

        let prefix: Data
        if count <= 0x19 {
            prefix = Data([0xa0 | UInt8(count)])
        } else if count <= 0xff {
            prefix = Data([0xd9, UInt8(count)])
        } else if count <= 0xffff {
            prefix = Data([0xda]) + packInteger(UInt64(count), parts: 2)
        } else {
            prefix = Data([0xdb]) + packInteger(UInt64(count), parts: 4)
        }

        return prefix + utf8

    case .binary(let data):
        let count = UInt32(data.count)
        assert(count <= 0xffff_ffff as UInt32)

        let prefix: Data
        switch format {
        case .latest:
            if count <= 0xff {
                prefix = Data([0xc4, UInt8(count)])
            } else if count <= 0xffff {
                prefix = Data([0xc5]) + packInteger(UInt64(count), parts: 2)
            } else {
                prefix = Data([0xc6]) + packInteger(UInt64(count), parts: 4)
            }
        case .old: // same prefix as strings above
            if count <= 0x19 {
                prefix = Data([0xa0 | UInt8(count)])
            } else if count <= 0xff {
                prefix = Data([0xd9, UInt8(count)])
            } else if count <= 0xffff {
                prefix = Data([0xda]) + packInteger(UInt64(count), parts: 2)
            } else {
                prefix = Data([0xdb]) + packInteger(UInt64(count), parts: 4)
            }
        }

        return prefix + data

    case .array(let array):
        let count = UInt32(array.count)
        assert(count <= 0xffff_ffff as UInt32)

        let prefix: Data
        if count <= 0xe {
            prefix = Data([0x90 | UInt8(count)])
        } else if count <= 0xffff {
            prefix = Data([0xdc]) + packInteger(UInt64(count), parts: 2)
        } else {
            prefix = Data([0xdd]) + packInteger(UInt64(count), parts: 4)
        }

        return prefix + array.flatMap { pack($0, format: format) }

    case .map(let dict):
        let count = UInt32(dict.count)
        assert(count < 0xffff_ffff)

        var data = Data()
        if count <= 0xe {
            data.append(Data([0x80 | UInt8(count)]))
        } else if count <= 0xffff {
            data.append(Data([0xde]))
            data.append(packInteger(UInt64(count), parts: 2))
        } else {
            data.append(Data([0xdf]))
            data.append(packInteger(UInt64(count), parts: 4))
        }

        for (key, value) in dict {
            data.append(pack(key, format: format))
            data.append(pack(value, format: format))
        }

        return data

    case .extended(let type, let data):
        let count = UInt32(data.count)
        assert(count <= 0xffff_ffff as UInt32)

        let unsignedType = UInt8(bitPattern: type)
        var prefix: Data
        switch count {
        case 1:
            prefix = Data([0xd4, unsignedType])
        case 2:
            prefix = Data([0xd5, unsignedType])
        case 4:
            prefix = Data([0xd6, unsignedType])
        case 8:
            prefix = Data([0xd7, unsignedType])
        case 16:
            prefix = Data([0xd8, unsignedType])
        case let count where count <= 0xff:
            prefix = Data([0xc7, UInt8(count), unsignedType])
        case let count where count <= 0xffff:
            prefix = Data([0xc8]) + packInteger(UInt64(count), parts: 2) + Data([unsignedType])
        default:
            prefix = Data([0xc9]) + packInteger(UInt64(count), parts: 4) + Data([unsignedType])
        }

        return prefix + data
        
        case let .timestamp(date):
            let timestampData = dateToData(date)
            precondition(timestampData.count >= 4 && timestampData.count <= 12)
            return pack(.extended(kTimestampType, timestampData), format: format)
        }
}

func dateToData(_ date: Date) -> Data {
    enum timestamp{
        case ts32bit(secs: UInt32) // 32 bit unsigned seconds since 1970-01-01 00:00:00 UTC
        case ts64bit(secs: UInt64, nanos: UInt32) //34 bit unsigned seconds since 1970-01-01 00:00:00 UTC, 30 bit unsigned nanosecs
        case ts96bit(secs:  Int64, nanos: UInt32) //64 bit signed seconds since 1970-01-01 00:00:00 UTC, 32 bit unsigned nanosecs
        case undefined
    }
    
    let secs_to_nanosecs = 1000000000.0
    let seconds32max = Int64(UInt32.max)
    let seconds34max = Int64(UInt32.max) * 4
    let seconds64max = Int64.max
    let seconds64min = Int64.min

    let nanomax = UInt32(999999999)
    
    let timeinterval = date.timeIntervalSince1970
    let seconds  = Int64(timeinterval)
    let nanos = UInt32(abs((timeinterval - Double(seconds)) * secs_to_nanosecs))
    
    let ts : timestamp
    
    switch (seconds, nanos){
    case(0...seconds32max, 0): //t32
        let castSeconds = UInt32(seconds.description)!
        ts = timestamp.ts32bit(secs: UInt32(castSeconds))
    case (0..<seconds34max, 0...nanomax): //t64
        let castSeconds = UInt64(0x3FFFFFFFF) & numericCast(seconds)
        let castNanos = UInt32(0x3FFFFFFF) & numericCast(nanos)
        ts = timestamp.ts64bit(secs: castSeconds, nanos: castNanos)
    case (seconds64min..<seconds64max, 0...nanomax): //t96
        ts = timestamp.ts96bit(secs: Int64(seconds), nanos: UInt32(nanos))
    default:
        ts = timestamp.undefined
    }
    
    switch ts {
    case .ts32bit(let secs):
        let data = packInteger(numericCast(secs), parts: 4)
        return data
    case .ts64bit(let secs, let nanos):
        return packInteger((UInt64(nanos) << 34) | secs, parts: 8)
    case .ts96bit(let secs, let nanos):
        let data1 = packInteger(numericCast(nanos), parts: 4)
        let data2 = packInteger(numericCast(UInt64(bitPattern: secs)), parts: 8)
        return  data1 + data2
    case .undefined:
        return Data()
    }
}
