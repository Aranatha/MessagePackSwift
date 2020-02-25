import Foundation

extension MessagePackValue {
    /// The number of elements in the `.Array` or `.Map`, `nil` otherwise.
    public func count() throws -> Int {
        switch self {
        case .array(let array):
            return array.count
        case .map(let dict):
            return dict.count
        default:
            throw MessagePackError.unsupportedType
        }
    }

    /// The element at subscript `i` in the `.Array`, `nil` otherwise.
    public subscript (i: Int) -> MessagePackValue? {
        switch self {
        case .array(let array):
            return i < array.count ? array[i] : Optional.none
        default:
            return nil
        }
    }

    /// The element at keyed subscript `key`, `nil` otherwise.
    public subscript (key: MessagePackValue) -> MessagePackValue? {
        switch self {
        case .map(let dict):
            return dict[key]
        default:
            return nil
        }
    }

    /// True if `.Nil`, false otherwise.
    public var isNil: Bool {
        switch self {
        case .nil:
            return true
        default:
            return false
        }
    }

    // MARK: Signed integer values

    /// The signed platform-dependent width integer value if `.int` or an
    /// appropriately valued `.uint`, `nil` otherwise.
    public func intValue() throws -> Int {
        switch self {
        case .int(let value):
            return try Int(msgpk_exactly: value)
        case .uint(let value):
            return try Int(msgpk_exactly: value)
        default:
            throw MessagePackError.unsupportedType
        }
    }

    /// The signed 8-bit integer value if `.int` or an appropriately valued
    /// `.uint`, `nil` otherwise.
    public func int8Value() throws -> Int8 {
        switch self {
        case .int(let value):
            return try Int8(msgpk_exactly: value)
        case .uint(let value):
            return try Int8(msgpk_exactly: value)
        default:
            throw MessagePackError.unsupportedType
        }
    }

    /// The signed 16-bit integer value if `.int` or an appropriately valued
    /// `.uint`, `nil` otherwise.
    public func int16Value() throws -> Int16 {
        switch self {
        case .int(let value):
            return try Int16(msgpk_exactly: value)
        case .uint(let value):
            return try Int16(msgpk_exactly: value)
        default:
            throw MessagePackError.unsupportedType
        }
    }

    /// The signed 32-bit integer value if `.int` or an appropriately valued
    /// `.uint`, `nil` otherwise.
    public func int32Value() throws -> Int32 {
        switch self {
        case .int(let value):
            return try Int32(msgpk_exactly: value)
        case .uint(let value):
            return try Int32(msgpk_exactly: value)
        default:
            throw MessagePackError.unsupportedType
        }
    }

    /// The signed 64-bit integer value if `.int` or an appropriately valued
    /// `.uint`, `nil` otherwise.
    public func int64Value() throws -> Int64 {
        switch self {
        case .int(let value):
            return value
        case .uint(let value):
            return try Int64(msgpk_exactly: value)
        default:
            throw MessagePackError.unsupportedType
        }
    }

    // MARK: Unsigned integer values

    /// The unsigned platform-dependent width integer value if `.uint` or an
    /// appropriately valued `.int`, `nil` otherwise.
    public func uintValue() throws -> UInt {
        switch self {
        case .int(let value):
            return try UInt(msgpk_exactly: value)
        case .uint(let value):
            return try UInt(msgpk_exactly: value)
        default:
            throw MessagePackError.unsupportedType
        }
    }

    /// The unsigned 8-bit integer value if `.uint` or an appropriately valued
    /// `.int`, `nil` otherwise.
    public func uint8Value() throws -> UInt8 {
        switch self {
        case .int(let value):
            return try UInt8(msgpk_exactly: value)
        case .uint(let value):
            return try UInt8(msgpk_exactly: value)
        default:
            throw MessagePackError.unsupportedType
        }
    }

    /// The unsigned 16-bit integer value if `.uint` or an appropriately valued
    /// `.int`, `nil` otherwise.
    public func uint16Value() throws -> UInt16 {
        switch self {
        case .int(let value):
            return try UInt16(msgpk_exactly: value)
        case .uint(let value):
            return try UInt16(msgpk_exactly: value)
        default:
            throw MessagePackError.unsupportedType
        }
    }

    /// The unsigned 32-bit integer value if `.uint` or an appropriately valued
    /// `.int`, `nil` otherwise.
    public func uint32Value() throws -> UInt32 {
        switch self {
        case .int(let value):
            return try UInt32(msgpk_exactly: value)
        case .uint(let value):
            return try UInt32(msgpk_exactly: value)
        default:
            throw MessagePackError.unsupportedType
        }
    }

    /// The unsigned 64-bit integer value if `.uint` or an appropriately valued
    /// `.int`, `nil` otherwise.
    public func uint64Value() throws -> UInt64 {
        switch self {
        case .int(let value):
            return try UInt64(msgpk_exactly: value)
        case .uint(let value):
            return value
        default:
            throw MessagePackError.unsupportedType
        }
    }

    /// The contained array if `.Array`, `nil` otherwise.
    public func arrayValue() throws -> [MessagePackValue] {
        switch self {
        case .array(let array):
            return array
        default:
            throw MessagePackError.unsupportedType
        }
    }

    /// The contained boolean value if `.Bool`, `nil` otherwise.
    public func boolValue() throws -> Bool {
        switch self {
        case .bool(let value):
            return value
        default:
            throw MessagePackError.unsupportedType
        }
    }

    /// The contained floating point value if `.Float` or `.Double`, `nil` otherwise.
    public func floatValue() throws -> Float {
        switch self {
        case .float(let value):
            return value
        case .double(let value):
            guard let float = Float(exactly: value) else {
                throw MessagePackError.inexact
            }
            return float
        default:
            throw MessagePackError.unsupportedType
        }
    }

    /// The contained double-precision floating point value if `.Float` or `.Double`, `nil` otherwise.
    public func doubleValue() throws -> Double {
        switch self {
        case .float(let value):
            guard let double = Double(exactly: value) else {
                throw MessagePackError.inexact
            }
            return double
        case .double(let value):
            return value
        default:
            throw MessagePackError.unsupportedType
        }
    }

    /// The contained string if `.String`, `nil` otherwise.
    public func stringValue() throws -> String {
        switch self {
        case .binary(let data):
            guard let string = String(data: data, encoding: .utf8) else {
                throw MessagePackError.invalidData
            }
            return string
        case .string(let string):
            return string
        default:
            throw MessagePackError.unsupportedType
        }
    }

    /// The contained data if `.Binary` or `.Extended`, `nil` otherwise.
    public func dataValue() throws -> Data {
        switch self {
        case .binary(let bytes):
            return bytes
        case .extended(_, let data):
            return data
        default:
            throw MessagePackError.unsupportedType
        }
    }
    
    /// The contained timestamp as Date
    public var timestampValue: Date? {
        switch self {
        case let .timestamp(date):
            return date
        default:
            return nil
        }
    }

    /// The contained type and data if Extended, `nil` otherwise.
    public func extendedValue() throws -> (Int8, Data) {
        guard case let .extended(type, data) = self else {
            throw MessagePackError.unsupportedType
        }
        return (type, data)
    }

    /// The contained type if `.Extended`, `nil` otherwise.
    public func extendedType() throws -> Int8 {
        guard case let .extended(type, _) = self else {
            throw MessagePackError.unsupportedType
        }
        return type
    }

    /// The contained dictionary if `.Map`, `nil` otherwise.
    public func dictionaryValue() throws -> [MessagePackValue: MessagePackValue] {
        guard case let .map(dict) = self else {
            throw MessagePackError.unsupportedType
        }
        return dict
    }
}
