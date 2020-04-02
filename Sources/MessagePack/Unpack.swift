import Foundation

public struct Unpacked<ValueType, DataType> {
    public let value: ValueType
    public let remainder: DataType
}

/// Joins bytes to form an integer.
///
/// - parameter data: The input data to unpack.
/// - parameter size: The size of the integer.
///
/// - returns: An integer representation of `size` bytes of data and the not-unpacked remaining data.
private func unpackInteger(_ data: Subdata,
                           count: Int) throws -> Unpacked<UInt64, Subdata> {
    guard count > 0 else {
        throw MessagePackError.invalidArgument
    }

    guard data.count >= count else {
        throw MessagePackError.insufficientData
    }

    var value: UInt64 = 0
    for i in 0 ..< count {
        let byte = data[i]
        value = value << 8 | UInt64(byte)
    }

    return Unpacked(value: value,
                    remainder: data[count ..< data.count])
}

/// Joins bytes to form a string.
///
/// - parameter data: The input data to unpack.
/// - parameter length: The length of the string.
///
/// - returns: A string representation of `size` bytes of data and the not-unpacked remaining data.
private func unpackString(_ data: Subdata,
                          count: Int) throws -> Unpacked<String, Subdata> {
    guard count > 0 else {
        return Unpacked(value: "", remainder: data)
    }

    guard data.count >= count else {
        throw MessagePackError.insufficientData
    }

    let subdata = data[0 ..< count]
    guard let result = String(data: subdata.data,
                              encoding: .utf8) else {
        throw MessagePackError.invalidData
    }

    return Unpacked(value: result,
                    remainder: data[count ..< data.count])
}

/// Joins bytes to form a data object.
///
/// - parameter data: The input data to unpack.
/// - parameter length: The length of the data.
///
/// - returns: A subsection of data representing `size` bytes and the not-unpacked remaining data.
private func unpackData(_ data: Subdata,
                        count: Int) throws -> Unpacked<Subdata, Subdata> {
    guard count >= 0 else {
        throw MessagePackError.invalidArgument
    }

    guard data.count >= count else {
        throw MessagePackError.insufficientData
    }

    return Unpacked(value: data[0 ..< count],
                    remainder: data[count ..< data.count])
}

/// Joins bytes to form an array of `MessagePackValue` values.
///
/// - parameter data: The input data to unpack.
/// - parameter count: The number of elements to unpack.
/// - parameter compatibility: When true, unpacks strings as binary data.
///
/// - returns: An array of `count` elements and the not-unpacked remaining data.
private func unpackArray(_ data: Subdata,
                         count: Int,
                         compatibility: Bool) throws -> Unpacked<[MessagePackValue], Subdata> {
    var values = [MessagePackValue]()
    var remainder = data

    for _ in 0 ..< count {
        let entry = try unpack(remainder,
                               compatibility: compatibility)
        values.append(entry.value)
        remainder = entry.remainder
    }

    return Unpacked(value: values,
                    remainder: remainder)
}

/// Joins bytes to form a dictionary with `MessagePackValue` key/value entries.
///
/// - parameter data: The input data to unpack.
/// - parameter count: The number of elements to unpack.
/// - parameter compatibility: When true, unpacks strings as binary data.
///
/// - returns: An dictionary of `count` entries and the not-unpacked remaining data.
private func unpackMap(_ data: Subdata,
                       count: Int,
                       compatibility: Bool) throws -> Unpacked<[MessagePackValue: MessagePackValue], Subdata> {
    var dict = [MessagePackValue: MessagePackValue](minimumCapacity: count)
    var lastKey: MessagePackValue? = nil

    let unpacked = try unpackArray(data,
                                   count: 2 * count,
                                   compatibility: compatibility)
    for item in unpacked.value {
        if let key = lastKey {
            dict[key] = item
            lastKey = nil
        } else {
            lastKey = item
        }
    }

    return Unpacked(value: dict,
                    remainder: unpacked.remainder)
}

/// Unpacks data into a MessagePackValue and returns the remaining data.
///
/// - parameter data: The input data to unpack.
/// - parameter compatibility: When true, unpacks strings as binary data.
///
/// - returns: A `MessagePackValue`and the not-unpacked remaining data.
public func unpack(_ data: Subdata,
                   compatibility: Bool = false) throws -> Unpacked<MessagePackValue, Subdata> {
    guard !data.isEmpty else {
        throw MessagePackError.insufficientData
    }

    let value = data[0]
    let data = data[1 ..< data.endIndex]

    switch value {

    // positive fixint
    case 0x00 ... 0x7f:
        return Unpacked(value: .uint(UInt64(value)),
                        remainder: data)

    // fixmap
    case 0x80 ... 0x8f:
        let count = Int(value - 0x80)
        let unpacked = try unpackMap(data,
                                     count: count,
                                     compatibility: compatibility)
        return Unpacked(value: .map(unpacked.value),
                        remainder: unpacked.remainder)

    // fixarray
    case 0x90 ... 0x9f:
        let count = Int(value - 0x90)
        let unpacked = try unpackArray(data,
                                       count: count,
                                       compatibility: compatibility)
        return Unpacked(value: .array(unpacked.value),
                        remainder: unpacked.remainder)

    // fixstr
    case 0xa0 ... 0xbf:
        let count = Int(value - 0xa0)
        if compatibility {
            let unpacked = try unpackData(data,
                                          count: count)
            return Unpacked(value: .binary(unpacked.value.data),
                            remainder: unpacked.remainder)
        } else {
            let unpacked = try unpackString(data,
                                            count: count)
            return Unpacked(value: .string(unpacked.value),
                            remainder: unpacked.remainder)
        }

    // nil
    case 0xc0:
        return Unpacked(value: .nil,
                        remainder: data)

    // false
    case 0xc2:
        return Unpacked(value: .bool(false),
                        remainder: data)

    // true
    case 0xc3:
        return Unpacked(value: .bool(true),
                        remainder: data)

    // bin 8, 16, 32
    case 0xc4 ... 0xc6:
        let intCount = 1 << Int(value - 0xc4)
        let unpacked1 = try unpackInteger(data,
                                          count: intCount)
        let unpacked2 = try unpackData(unpacked1.remainder,
                                       count: Int(unpacked1.value))
        return Unpacked(value: .binary(unpacked2.value.data),
                        remainder: unpacked2.remainder)

    // ext 8, 16, 32
    case 0xc7 ... 0xc9:
        let intCount = 1 << Int(value - 0xc7)

        let unpacked1 = try unpackInteger(data, //length
                                          count: intCount)
        guard !unpacked1.remainder.isEmpty else {
            throw MessagePackError.insufficientData
        }

        let type = Int8(bitPattern: unpacked1.remainder[0])
        let unpacked2 = try unpackData(unpacked1.remainder[1 ..< unpacked1.remainder.count],
                                       count: Int(unpacked1.value))
        
        if (type == kTimestampType){
            guard let date = dataToDate(unpacked2.value.data) else {
                throw MessagePackError.invalidData
            }
            return Unpacked(value: .timestamp(date),
            remainder: unpacked2.remainder)
        } else {
            return Unpacked(value: .extended(type, unpacked2.value.data),
            remainder: unpacked2.remainder)
        }
        
       // return Unpacked(value: .extended(type, unpacked2.value.data),
       //                 remainder: unpacked2.remainder)

    // float 32
    case 0xca:
        let unpacked = try unpackInteger(data,
                                         count: 4)
        let float = Float(bitPattern: UInt32(truncatingIfNeeded: unpacked.value))
        return Unpacked(value: .float(float),
                        remainder: unpacked.remainder)

    // float 64
    case 0xcb:
        let unpacked = try unpackInteger(data,
                                         count: 8)
        let double = Double(bitPattern: unpacked.value)
        return Unpacked(value: .double(double),
                        remainder: unpacked.remainder)

    // uint 8, 16, 32, 64
    case 0xcc ... 0xcf:
        let count = 1 << (Int(value) - 0xcc)
        let unpacked = try unpackInteger(data,
                                         count: count)
        return Unpacked(value: .uint(unpacked.value),
                        remainder: unpacked.remainder)

    // int 8
    case 0xd0:
        guard !data.isEmpty else {
            throw MessagePackError.insufficientData
        }

        let byte = Int8(bitPattern: data[0])
        return Unpacked(value: .int(Int64(byte)),
                        remainder: data[1 ..< data.count])

    // int 16
    case 0xd1:
        let bytes = try unpackInteger(data,
                                         count: 2)
        let integer = Int16(bitPattern: UInt16(truncatingIfNeeded: bytes.value))
        return Unpacked(value: .int(Int64(integer)),
                        remainder: bytes.remainder)

    // int 32
    case 0xd2:
        let bytes = try unpackInteger(data,
                                         count: 4)
        let integer = Int32(bitPattern: UInt32(truncatingIfNeeded: bytes.value))
        return Unpacked(value: .int(Int64(integer)),
                        remainder: bytes.remainder)

    // int 64
    case 0xd3:
        let bytes = try unpackInteger(data,
                                      count: 8)
        let integer = Int64(bitPattern: bytes.value)
        return Unpacked(value: .int(integer),
                        remainder: bytes.remainder)

    // fixent 1, 2, 4, 8, 16
    case 0xd4 ... 0xd8:
        let count = 1 << Int(value - 0xd4)

        guard !data.isEmpty else {
            throw MessagePackError.insufficientData
        }

        let type = Int8(bitPattern: data[0])
        let subdata = try unpackData(data[1 ..< data.count],
                                     count: count)
        
        
        if (type == kTimestampType){
            guard let date = dataToDate(subdata.value.data) else {
                throw MessagePackError.invalidData
            }
            return Unpacked(value: .timestamp(date),
                            remainder: subdata.remainder)
        } else {
            return Unpacked(value: .extended(type, subdata.value.data),
                            remainder: subdata.remainder)
        }
        

    // str 8, 16, 32
    case 0xd9 ... 0xdb:
        let countSize = 1 << Int(value - 0xd9)
        let count = try unpackInteger(data,
                                      count: countSize)
        if compatibility {
            let subdata = try unpackData(count.remainder,
                                         count: Int(count.value))
            return Unpacked(value: .binary(subdata.value.data),
                            remainder: subdata.remainder)
        } else {
            let string = try unpackString(count.remainder,
                                          count: Int(count.value))
            return Unpacked(value: .string(string.value),
                            remainder: string.remainder)
        }

    // array 16, 32
    case 0xdc ... 0xdd:
        let countSize = 1 << Int(value - 0xdb)
        let count = try unpackInteger(data,
                                      count: countSize)
        let array = try unpackArray(count.remainder,
                                    count: Int(count.value),
                                    compatibility: compatibility)
        return Unpacked(value: .array(array.value),
                        remainder: array.remainder)

    // map 16, 32
    case 0xde ... 0xdf:
        let countSize = 1 << Int(value - 0xdd)
        let count = try unpackInteger(data,
                                      count: countSize)
        let dict = try unpackMap(count.remainder,
                                 count: Int(count.value),
                                 compatibility: compatibility)
        return Unpacked(value: .map(dict.value),
                        remainder: dict.remainder)

    // negative fixint
    case 0xe0 ..< 0xff:
        return Unpacked(value: .int(Int64(value) - 0x100),
                        remainder: data)

    // negative fixint (workaround for rdar://19779978)
    case 0xff:
        return Unpacked(value: .int(Int64(value) - 0x100),
                        remainder: data)

    default:
        throw MessagePackError.invalidData
    }
}

/// Unpacks data into a MessagePackValue and returns the remaining data.
///
/// - parameter data: The input data to unpack.
///
/// - returns: A `MessagePackValue` and the not-unpacked remaining data.
public func unpack(_ data: Data,
                   compatibility: Bool = false) throws -> Unpacked<MessagePackValue, Data> {
    let unpacked = try unpack(Subdata(data: data),
                                        compatibility: compatibility)
    return Unpacked(value: unpacked.value,
                    remainder: unpacked.remainder.data)
}

/// Unpacks a data object into a `MessagePackValue`, ignoring excess data.
///
/// - parameter data: The data to unpack.
/// - parameter compatibility: When true, unpacks strings as binary data.
///
/// - returns: The contained `MessagePackValue`.
public func unpackFirst(_ data: Data,
                        compatibility: Bool = false) throws -> MessagePackValue {
    return try unpack(data,
                      compatibility: compatibility).value
}

/// Unpacks a data object into an array of `MessagePackValue` values.
///
/// - parameter data: The data to unpack.
/// - parameter compatibility: When true, unpacks strings as binary data.
///
/// - returns: The contained `MessagePackValue` values.
public func unpackAll(_ data: Data,
                      compatibility: Bool = false) throws -> [MessagePackValue] {
    var values = [MessagePackValue]()

    var remainder = Subdata(data: data)
    while !remainder.isEmpty {
        let entry = try unpack(remainder,
                               compatibility: compatibility)
        values.append(entry.value)
        remainder = entry.remainder
    }

    return values
}

func dataToDate(_ bytes: Data) -> Date? {

    let secs_to_nanosecs = 1000000000.0

    enum timestamp : Int {
        case ts32bit = 4 // 32 bit unsigned seconds since 1970-01-01 00:00:00 UTC
        case ts64bit = 8 //34 bit unsigned seconds since 1970-01-01 00:00:00 UTC, 30 bit unsigned nanosecs
        case ts96bit = 12 //64 bit signed seconds since 1970-01-01 00:00:00 UTC, 32 bit unsigned nanosecs
    }
    
    guard let ts = timestamp.init(rawValue: bytes.count) else {
        return nil
    }
    
    switch ts {
    case .ts32bit:
        let timeinterval = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        timeinterval.pointee = 0
        let rawdata = Foundation.Data(bytes: bytes.reversed(), count: MemoryLayout<UInt32>.size) // reverse deals with little/big Endian
        timeinterval.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<UInt32>.size, {ptr in
            rawdata.copyBytes(to: ptr, count: MemoryLayout<UInt32>.size)
        })
  
//        rawdata.copyBytes(to: UnsafeMutablePointer<UInt8>(timeinterval), count: MemoryLayout<UInt32>.size)
        //rawdata.getBytes(&timeinterval, length: sizeof(UInt32))
        let date = Date(timeIntervalSince1970: Double(timeinterval.pointee))
        timeinterval.deinitialize(count: 1)
        return date
    case .ts64bit:
        let data = UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        data.pointee = 0
        let rawdata = Foundation.Data(bytes: bytes.reversed(), count: MemoryLayout<UInt64>.size) // reverse deals with little/big Endian
        data.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<UInt64>.size, {ptr in
            rawdata.copyBytes(to: ptr, count: MemoryLayout<UInt64>.size)
        })

       // rawdata.copyBytes(to: UnsafeMutablePointer<UInt8>(data), count: MemoryLayout<UInt64>.size)

        let seconds = Double(UInt64(0x3ffffffff) & data.pointee)
        let nanos = Double(data.pointee >> 34)
        let timeinterval = seconds + nanos / secs_to_nanosecs
        let date = Date(timeIntervalSince1970: timeinterval)
        data.deinitialize(count: 1)

        return date
    case .ts96bit:
        let nanos = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        nanos.pointee = 0
        let seconds = UnsafeMutablePointer<Int64>.allocate(capacity: 1)
        seconds.pointee = 0
        let rawdata = Foundation.Data(bytes: bytes.reversed(), count: MemoryLayout<UInt32>.size+MemoryLayout<Int64>.size) // reverse deals with little/big Endian
        
        seconds.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Int64>.size, {ptr in
            rawdata.copyBytes(to: ptr, count: MemoryLayout<Int64>.size)
        })


        //rawdata.copyBytes(to: UnsafeMutablePointer<UInt8>(seconds), count: MemoryLayout<Int64>.size)
        
        let range = Range<Int>.init(uncheckedBounds: (MemoryLayout<Int64>.size, MemoryLayout<Int64>.size + MemoryLayout<UInt32>.size))

        nanos.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<UInt32>.size, {ptr in
            rawdata.copyBytes(to: ptr, from: range)
        })
//        rawdata.copyBytes(to: UnsafeMutablePointer<UInt8>(nanos), from: range)

        
        //rawdata.getBytes(&seconds, range: NSRange(location: 0, length: sizeof(Int64)))
        //rawdata.getBytes(&nanos, range: NSRange(location: sizeof(Int64), length: sizeof(UInt32)))
        let timeinterval = Double(seconds.pointee) + Double(nanos.pointee) / secs_to_nanosecs
        let date = Date(timeIntervalSince1970: timeinterval)
        seconds.deinitialize(count: 1)
        nanos.deinitialize(count: 1)

        return date
    }

}
