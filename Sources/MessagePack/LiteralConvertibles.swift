extension MessagePackValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: MessagePackValue...) {
        self = .array(elements)
    }
}

extension MessagePackValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension MessagePackValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (MessagePackValue, MessagePackValue)...) {
        self = .map(elements.reduce(into: [MessagePackValue: MessagePackValue](minimumCapacity: elements.count)) {
            let (key, value) = $1
            $0[key] = value
        })
    }
}

extension MessagePackValue: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .string(value)
    }
}

extension MessagePackValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension MessagePackValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int64) {
        self = .int(value)
    }
}

extension MessagePackValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .nil
    }
}

extension MessagePackValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension MessagePackValue: ExpressibleByUnicodeScalarLiteral {
    public init(unicodeScalarLiteral value: String) {
        self = .string(value)
    }
}
