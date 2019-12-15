import Foundation

/*
 * The implementation of MessagePackEncoder/Decoder heavily references JSONEncoder.swift and PlistEncoder.swift
 * from the Swift foundation library. As the logic required to implement this correctly is non-trivial and
 * complicated, I kept the structure pretty much the same as JSONEncoder and PlistEncoder so that it is easy
 * for anyone to cross reference. For your info, JSONEncoder is a single file with 2.1k lines of code =x.
 *
 * Warning for anyone who wants to modify this file, please make sure you understood all the code in JSONEncoder.swift
 * and PlistEncoder.swift before doing so. There are reasons for why things are done in a particular way.
 *
 * Swift repo commit at time of reference: 2771eb520c4e3058058baf6bb3f6dba6184a17d3
 */

// MARK: - MessagePackEncoder

open class MessagePackEncoder {
    open var userInfo: [CodingUserInfoKey: Any] = [:]
    
    fileprivate struct _Options {
        let userInfo: [CodingUserInfoKey: Any]
    }
    
    fileprivate var options: _Options {
        return _Options(userInfo: userInfo)
    }
    
    public init() {}
    
    open func encode<T: Encodable>(_ value: T) throws -> Data {
        let messagePack = try self.messagePack(with: value)
        return try encode(messagePack: messagePack)
    }
    
    open func encode(messagePack: MessagePackValue) throws -> Data {
        return pack(messagePack)
    }
    
    open func messagePack<T: Encodable>(with value: T) throws -> MessagePackValue {
        let encoder = __MessagePackEncoder(options: options)
        
        guard let box = try encoder.box_(value) else {
            throw EncodingError.invalidValue(value,
                                             EncodingError.Context(codingPath: [],
                                                                   debugDescription: "Top-level \(T.self) did not encode any values."))
        }
        
        return box.messagePackValue
    }
}

// MARK: _MessagePackEncoder

fileprivate class __MessagePackEncoder: Encoder {
    
    fileprivate var storage: _MessagePackEncodingStorage
    
    fileprivate let options: MessagePackEncoder._Options
    
    var codingPath: [CodingKey]
    
    var userInfo: [CodingUserInfoKey: Any] {
        options.userInfo
    }
    
    fileprivate init(options: MessagePackEncoder._Options,
                     codingPath: [CodingKey] = []) {
        self.options = options
        self.storage = _MessagePackEncodingStorage()
        self.codingPath = codingPath
    }
    
    fileprivate var canEncodeNewValue: Bool {
        return storage.count == codingPath.count
    }
    
    func container<Key>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
        let topContainer: _MessagePackDictionaryBox
        if canEncodeNewValue {
            topContainer = storage.pushKeyedContainer()
        } else {
            guard let container = storage.containers.last as? _MessagePackDictionaryBox else {
                preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
            }
            
            topContainer = container
        }
        
        let container = _MessagePackKeyedEncodingContainer<Key>(referencing: self,
                                                                codingPath: codingPath,
                                                                wrapping: topContainer)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let topContainer: _MessagePackArrayBox
        if canEncodeNewValue {
            topContainer = storage.pushUnkeyedContainer()
        } else {
            guard let container = storage.containers.last as? _MessagePackArrayBox else {
                preconditionFailure("Attempt to push new unkeyed encoding container when already previously encoded at this path.")
            }
            
            topContainer = container
        }
        
        return _MessagePackUnkeyedEncodingContainer(referencing: self,
                                                    codingPath: codingPath,
                                                    wrapping: topContainer)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

// MARK: Encoding Storage

fileprivate struct _MessagePackEncodingStorage {
    private(set) fileprivate var containers: [_MessagePackBox] = []
    
    fileprivate init() {}
    
    fileprivate var count: Int {
        return containers.count
    }
    
    fileprivate mutating func pushKeyedContainer() -> _MessagePackDictionaryBox {
        let dictionary = _MessagePackDictionaryBox()
        containers.append(dictionary)
        return dictionary
    }
    
    fileprivate mutating func pushUnkeyedContainer() -> _MessagePackArrayBox {
        let array = _MessagePackArrayBox()
        containers.append(array)
        return array
    }
    
    fileprivate mutating func push(container: _MessagePackBox) {
        containers.append(container)
    }
    
    fileprivate mutating func popContainer() -> _MessagePackBox {
        precondition(containers.count > 0, "Empty container stack.")
        return containers.popLast()!
    }
}

// MARK: Encoding Containers

fileprivate struct _MessagePackKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K
    
    private let encoder: __MessagePackEncoder
    
    private let container: _MessagePackDictionaryBox
    
    private(set) var codingPath: [CodingKey]
    
    fileprivate init(referencing encoder: __MessagePackEncoder,
                     codingPath: [CodingKey],
                     wrapping container: _MessagePackDictionaryBox) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    // MARK: - KeyedEncodingContainerProtocol Methods
    
    mutating func encodeNil(forKey key: Key) throws {
        container[key] = encoder.boxNil()
    }
    mutating func encode(_ value: Bool, forKey key: Key) throws {
        container[key] = encoder.box(value)
    }
    mutating func encode(_ value: Int, forKey key: Key) throws {
        container[key] = encoder.box(value)
    }
    mutating func encode(_ value: Int8, forKey key: Key) throws {
        container[key] = encoder.box(value)
    }
    mutating func encode(_ value: Int16, forKey key: Key) throws {
        container[key] = encoder.box(value)
    }
    mutating func encode(_ value: Int32, forKey key: Key) throws {
        container[key] = encoder.box(value)
    }
    mutating func encode(_ value: Int64, forKey key: Key) throws {
        container[key] = encoder.box(value)
    }
    mutating func encode(_ value: UInt, forKey key: Key) throws {
        container[key] = encoder.box(value)
    }
    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        container[key] = encoder.box(value)
    }
    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        container[key] = encoder.box(value)
    }
    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        container[key] = encoder.box(value)
    }
    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        container[key] = encoder.box(value)
    }
    mutating func encode(_ value: Float, forKey key: Key) throws {
        container[key] = encoder.box(value)
    }
    mutating func encode(_ value: Double, forKey key: Key) throws {
        container[key] = encoder.box(value)
    }
    mutating func encode(_ value: String, forKey key: Key) throws {
        container[key] = encoder.box(value)
    }

    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { encoder.codingPath.removeLast() }
        
        container[key] = try encoder.box(value)
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type,
                                             forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let dictionary = _MessagePackDictionaryBox()
        container[key] = dictionary
        
        codingPath.append(key)
        defer { codingPath.removeLast() }
        
        let container = _MessagePackKeyedEncodingContainer<NestedKey>(referencing: encoder,
                                                                      codingPath: codingPath,
                                                                      wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let array = _MessagePackArrayBox()
        container[key] = array
        
        codingPath.append(key)
        defer { codingPath.removeLast() }
        
        return _MessagePackUnkeyedEncodingContainer(referencing: encoder,
                                                    codingPath: codingPath,
                                                    wrapping: array)
    }
    
    mutating func superEncoder() -> Encoder {
        return _MessagePackReferencingEncoder(referencing: encoder,
                                              at: _MessagePackKey.super,
                                              wrapping: container)
    }
    
    mutating func superEncoder(forKey key: Key) -> Encoder {
        return _MessagePackReferencingEncoder(referencing: encoder,
                                              at: key,
                                              wrapping: container)
    }
}

fileprivate struct _MessagePackUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    private let encoder: __MessagePackEncoder
    
    private let container: _MessagePackArrayBox
    
    private(set) var codingPath: [CodingKey]
    
    var count: Int {
        return container.count
    }
    
    fileprivate init(referencing encoder: __MessagePackEncoder,
                     codingPath: [CodingKey],
                     wrapping container: _MessagePackArrayBox) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    mutating func encodeNil() throws {
        container.append(encoder.boxNil())
    }
    mutating func encode(_ value: Bool) throws {
        container.append(encoder.box(value))
    }
    mutating func encode(_ value: Int) throws {
        container.append(encoder.box(value))
    }
    mutating func encode(_ value: Int8) throws {
        container.append(encoder.box(value))
    }
    mutating func encode(_ value: Int16) throws {
        container.append(encoder.box(value))
    }
    mutating func encode(_ value: Int32) throws {
        container.append(encoder.box(value))
    }
    mutating func encode(_ value: Int64) throws {
        container.append(encoder.box(value))
    }
    mutating func encode(_ value: UInt) throws {
        container.append(encoder.box(value))
    }
    mutating func encode(_ value: UInt8) throws {
        container.append(encoder.box(value))
    }
    mutating func encode(_ value: UInt16) throws {
        container.append(encoder.box(value))
    }
    mutating func encode(_ value: UInt32) throws {
        container.append(encoder.box(value))
    }
    mutating func encode(_ value: UInt64) throws {
        container.append(encoder.box(value))
    }
    mutating func encode(_ value: Float) throws {
        container.append(encoder.box(value))
    }
    mutating func encode(_ value: Double) throws {
        container.append(encoder.box(value))
    }
    mutating func encode(_ value: String) throws {
        container.append(encoder.box(value))
    }
    
    mutating func encode<T : Encodable>(_ value: T) throws {
        encoder.codingPath.append(_MessagePackKey(index: count))
        defer { encoder.codingPath.removeLast() }
        
        container.append(try encoder.box(value))
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        codingPath.append(_MessagePackKey(index: count))
        defer { codingPath.removeLast() }
        
        let dictionary = _MessagePackDictionaryBox()
        container.append(dictionary)
        
        let container = _MessagePackKeyedEncodingContainer<NestedKey>(referencing: encoder,
                                                                      codingPath: codingPath,
                                                                      wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        codingPath.append(_MessagePackKey(index: count))
        defer { codingPath.removeLast() }
        
        let array = _MessagePackArrayBox()
        container.append(array)
        return _MessagePackUnkeyedEncodingContainer(referencing: encoder,
                                                    codingPath: codingPath,
                                                    wrapping: array)
    }
    
    mutating func superEncoder() -> Encoder {
        return _MessagePackReferencingEncoder(referencing: encoder,
                                              at: container.array.count,
                                              wrapping: container)
    }
}

extension __MessagePackEncoder: SingleValueEncodingContainer {
    
    fileprivate func assertCanEncodeNewValue() {
        precondition(canEncodeNewValue,
                     "Attempt to encode value through single value container when previously value already encoded.")
    }
    
    func encodeNil() throws {
        assertCanEncodeNewValue()
        storage.push(container: boxNil())
    }
    
    func encode(_ value: Bool) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    func encode(_ value: Int) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    func encode(_ value: Int8) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    func encode(_ value: Int16) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    func encode(_ value: Int32) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    func encode(_ value: Int64) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    func encode(_ value: UInt) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    func encode(_ value: UInt8) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    func encode(_ value: UInt16) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    func encode(_ value: UInt32) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    func encode(_ value: UInt64) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    func encode(_ value: String) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    func encode(_ value: Float) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    func encode(_ value: Double) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }
    
    func encode<T: Encodable>(_ value: T) throws {
        assertCanEncodeNewValue()
        try storage.push(container: box(value))
    }
}

// MARK: Concrete Value Representations

extension __MessagePackEncoder {
    fileprivate func boxNil() -> _MessagePackBox {
        return _MessagePackValueBox(MessagePackValue())
    }
    fileprivate func box(_ value: Bool) -> _MessagePackBox {
        return _MessagePackValueBox(MessagePackValue(value))
    }
    fileprivate func box(_ value: Int) -> _MessagePackBox {
        return _MessagePackValueBox(MessagePackValue(value))
    }
    fileprivate func box(_ value: Int8) -> _MessagePackBox {
        return _MessagePackValueBox(MessagePackValue(value))
    }
    fileprivate func box(_ value: Int16) -> _MessagePackBox {
        return _MessagePackValueBox(MessagePackValue(value))
    }
    fileprivate func box(_ value: Int32) -> _MessagePackBox {
        return _MessagePackValueBox(MessagePackValue(value))
    }
    fileprivate func box(_ value: Int64) -> _MessagePackBox {
        return _MessagePackValueBox(MessagePackValue(value))
    }
    fileprivate func box(_ value: UInt) -> _MessagePackBox {
        return _MessagePackValueBox(MessagePackValue(value))
    }
    fileprivate func box(_ value: UInt8) -> _MessagePackBox {
        return _MessagePackValueBox(MessagePackValue(value))
    }
    fileprivate func box(_ value: UInt16) -> _MessagePackBox {
        return _MessagePackValueBox(MessagePackValue(value))
    }
    fileprivate func box(_ value: UInt32) -> _MessagePackBox {
        return _MessagePackValueBox(MessagePackValue(value))
    }
    fileprivate func box(_ value: UInt64) -> _MessagePackBox {
        return _MessagePackValueBox(MessagePackValue(value))
    }
    fileprivate func box(_ value: Float) -> _MessagePackBox {
        return _MessagePackValueBox(MessagePackValue(value))
    }
    fileprivate func box(_ value: Double) -> _MessagePackBox {
        return _MessagePackValueBox(MessagePackValue(value))
    }
    fileprivate func box(_ value: String) -> _MessagePackBox {
        return _MessagePackValueBox(MessagePackValue(value))
    }
    fileprivate func box(_ value: Data) -> _MessagePackBox {
        return _MessagePackValueBox(MessagePackValue(value))
    }
    
    fileprivate func box<T: Encodable>(_ value: T) throws -> _MessagePackBox {
        return try box_(value) ?? _MessagePackDictionaryBox()
    }
    
    fileprivate func box_<T: Encodable>(_ value: T) throws -> _MessagePackBox? {
        if T.self == Data.self || T.self == NSData.self {
            return box((value as! Data))
        }
        
        let depth = storage.count
        try value.encode(to: self)
        
        guard storage.count > depth else {
            return nil
        }
        
        return storage.popContainer()
    }
}

// MARK: _MessagePackReferencingEncoder

fileprivate class _MessagePackReferencingEncoder: __MessagePackEncoder {
    
    private enum Reference {
        case array(_MessagePackArrayBox, Int)
        case dictionary(_MessagePackDictionaryBox, String)
    }
    
    fileprivate let encoder: __MessagePackEncoder
    
    private let reference: Reference
    
    fileprivate init(referencing encoder: __MessagePackEncoder,
                     at index: Int,
                     wrapping array: _MessagePackArrayBox) {
        self.encoder = encoder
        self.reference = .array(array,
                                index)
        super.init(options: encoder.options,
                   codingPath: encoder.codingPath)
        
        codingPath.append(_MessagePackKey(index: index))
    }
    
    fileprivate init(referencing encoder: __MessagePackEncoder,
                     at key: CodingKey,
                     wrapping dictionary: _MessagePackDictionaryBox) {
        self.encoder = encoder
        self.reference = .dictionary(dictionary,
                                     key.stringValue)
        super.init(options: encoder.options,
                   codingPath: encoder.codingPath)
        
        codingPath.append(key)
    }
    
    fileprivate override var canEncodeNewValue: Bool {
        storage.count == codingPath.count - encoder.codingPath.count - 1
    }
    
    deinit {
        let value: _MessagePackBox
        switch storage.count {
        case 0:
            value = _MessagePackDictionaryBox()
        case 1:
            value = storage.popContainer()
        default:
            fatalError("Referencing encoder deallocated with multiple containers on stack.")
        }
        
        switch reference {
        case .array(let box,
                    let index):
            box.array.insert(value,
                             at: index)
            
        case .dictionary(let box,
                         let key):
            box[key] = value
        }
    }
}

// MARK: - Message Pack Decoder
open class MessagePackDecoder {
    public enum NumberDecodingStrategy {
        /// Follows type of model strictly
        case noTypeConversion
        
        /// Automatically convert between UInt64, Int64, Double, Float
        case automaticTypeConversion
    }
    
    open var numberDecodingStrategy: NumberDecodingStrategy = .noTypeConversion
    
    open var userInfo: [CodingUserInfoKey : Any] = [:]
    
    fileprivate struct _Options {
        let numberDecodingStrategy: NumberDecodingStrategy
        let userInfo: [CodingUserInfoKey : Any]
    }
    
    fileprivate var options: _Options {
        return _Options(numberDecodingStrategy: numberDecodingStrategy,
                        userInfo: userInfo)
    }
    
    public init() {}
    
    open func decode<T: Decodable>(_ type: T.Type,
                                   from data: Data) throws -> T {
        let messagePack = try self.messagePack(with: data)
        return try decode(type,
                          from: messagePack)
    }
    
    open func decode<T: Decodable>(_ type: T.Type,
                                   from messagePack: MessagePackValue) throws -> T {
        let decoder = _MessagePackDecoder(referencing: messagePack,
                                          options: options)
        
        guard let value = try decoder.unbox(messagePack,
                                            as: T.self) else {
            throw DecodingError.valueNotFound(T.self,
                                              DecodingError.Context(codingPath: [],
                                                                    debugDescription: "The given data did not contain a top-level value."))
        }
        
        return value
    }
    
    open func messagePack(with data: Data) throws -> MessagePackValue {
        let messagePack: MessagePackValue
        do {
            messagePack = try unpackFirst(data)
        } catch {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [],
                                                                    debugDescription: "The given data was not valid Message Pack.",
                                                                    underlyingError: error))
        }
        
        return messagePack
    }
}

// MARK: _MessagePackDecoder

fileprivate class _MessagePackDecoder : Decoder {
    
    fileprivate var storage: _MessagePackDecodingStorage
    
    fileprivate let options: MessagePackDecoder._Options
    
    fileprivate(set) var codingPath: [CodingKey]
    
    var userInfo: [CodingUserInfoKey : Any] {
        return options.userInfo
    }
    
    fileprivate init(referencing container: MessagePackValue,
                     at codingPath: [CodingKey] = [],
                     options: MessagePackDecoder._Options) {
        self.storage = _MessagePackDecodingStorage()
        self.storage.push(container: container)
        self.codingPath = codingPath
        self.options = options
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        let messagePackDictionary: [MessagePackValue : MessagePackValue]
        do {
            messagePackDictionary = try storage.topContainer.dictionaryValue()
        } catch {
            let description = "Expected to decode dictionary but found \(storage.topContainer)"
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: description)
            throw DecodingError.typeMismatch([MessagePackValue: MessagePackValue].self, context)
        }
        let dictionary = try messagePackDictionary.reduce(into: [String: MessagePackValue]()) {
            do {
                $0[try $1.key.stringValue()] = $1.value
            } catch {
                let description = "Expected to decode string but found \($1.key)"
                let context = DecodingError.Context(codingPath: codingPath,
                                                    debugDescription: description)
                throw DecodingError.typeMismatch(String.self,
                                                 context)
            }
        }

        let container = _MessagePackKeyedDecodingContainer<Key>(referencing: self,
                                                                wrapping: dictionary)
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let array: [MessagePackValue]
        do {
            array = try storage.topContainer.arrayValue()
        } catch {
            let description = "Expected to decode array but found \(storage.topContainer)"
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: description)
            throw DecodingError.typeMismatch([MessagePackValue].self,
                                             context)
        }
        
        return _MessagePackUnkeyedDecodingContainer(referencing: self,
                                                    wrapping: array)
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}

// MARK: Decoding Storage

fileprivate struct _MessagePackDecodingStorage {
    
    private(set) fileprivate var containers: [MessagePackValue] = []
    
    fileprivate init() {}
    
    fileprivate var count: Int {
        return containers.count
    }
    
    fileprivate var topContainer: MessagePackValue {
        precondition(containers.count > 0, "Empty container stack.")
        return containers.last!
    }
    
    fileprivate mutating func push(container: MessagePackValue) {
        containers.append(container)
    }
    
    fileprivate mutating func popContainer() {
        precondition(containers.count > 0, "Empty container stack.")
        containers.removeLast()
    }
}

// MARK: Decoding Containers

fileprivate struct _MessagePackKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K
    
    private let decoder: _MessagePackDecoder
    
    private let container: [String: MessagePackValue]
    
    private(set) var codingPath: [CodingKey]
    
    fileprivate init(referencing decoder: _MessagePackDecoder,
                     wrapping container: [String: MessagePackValue]) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
    }
    
    var allKeys: [Key] {
        return container.keys.compactMap { Key(stringValue: $0) }
    }
    
    func contains(_ key: Key) -> Bool {
        return container[key.stringValue] != nil
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: decoder.codingPath,
                                                                  debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        return entry.isNil
    }
    
    func decode(_ type: Bool.Type,
                forKey key: Key) throws -> Bool {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: decoder.codingPath,
                                                                  debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry, as: Bool.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    func decode(_ type: Int.Type,
                forKey key: Key) throws -> Int {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: decoder.codingPath,
                                                                debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry,
                                            as: Int.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    func decode(_ type: Int8.Type,
                forKey key: Key) throws -> Int8 {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: decoder.codingPath,
                                                                  debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry,
                                            as: Int8.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    func decode(_ type: Int16.Type,
                forKey key: Key) throws -> Int16 {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: decoder.codingPath,
                                                                  debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry,
                                            as: Int16.self) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    func decode(_ type: Int32.Type,
                       forKey key: Key) throws -> Int32 {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: decoder.codingPath,
                                                                  debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry,
                                            as: Int32.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    func decode(_ type: Int64.Type,
                forKey key: Key) throws -> Int64 {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: decoder.codingPath,
                                                                  debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry,
                                            as: Int64.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    func decode(_ type: UInt.Type,
                forKey key: Key) throws -> UInt {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: decoder.codingPath,
                                                                  debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry,
                                            as: UInt.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    func decode(_ type: UInt8.Type,
                forKey key: Key) throws -> UInt8 {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: decoder.codingPath,
                                                                  debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry,
                                            as: UInt8.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    func decode(_ type: UInt16.Type,
                forKey key: Key) throws -> UInt16 {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: decoder.codingPath,
                                                                  debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry,
                                            as: UInt16.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    func decode(_ type: UInt32.Type,
                forKey key: Key) throws -> UInt32 {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: decoder.codingPath,
                                                                  debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry,
                                            as: UInt32.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    func decode(_ type: UInt64.Type,
                forKey key: Key) throws -> UInt64 {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: decoder.codingPath,
                                                                  debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry,
                                            as: UInt64.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    func decode(_ type: Float.Type,
                forKey key: Key) throws -> Float {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: decoder.codingPath,
                                                                  debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry,
                                            as: Float.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    func decode(_ type: Double.Type,
                forKey key: Key) throws -> Double {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: decoder.codingPath,
                                                                  debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry,
                                            as: Double.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    func decode(_ type: String.Type,
                forKey key: Key) throws -> String {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: decoder.codingPath,
                                                                  debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry,
                                            as: String.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    func decode<T : Decodable>(_ type: T.Type,
                               forKey key: Key) throws -> T {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: decoder.codingPath,
                                                                  debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = try decoder.unbox(entry,
                                            as: T.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "Expected \(type) value but found null instead."))
        }
        
        return value
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type,
                                    forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: codingPath,
                                                                  debugDescription: "Cannot get \(KeyedDecodingContainer<NestedKey>.self) -- no value found for key \"\(key.stringValue)\""))
        }
        
        let messagePackDictionary: [MessagePackValue : MessagePackValue]
        do {
            messagePackDictionary = try value.dictionaryValue()
        } catch {
            let description = "Expected to decode dictionary but found \(value)"
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: description)
            throw DecodingError.typeMismatch([MessagePackValue: MessagePackValue].self, context)
        }
        
        let dictionary = try messagePackDictionary.reduce(into: [String: MessagePackValue]()) {
            do {
                $0[try $1.key.stringValue()] = $1.value
            } catch {
                let description = "Expected to decode string but found \(key)"
                let context = DecodingError.Context(codingPath: codingPath,
                                                    debugDescription: description)
                throw DecodingError.typeMismatch(String.self, context)
            }
        }
        
        let container = _MessagePackKeyedDecodingContainer<NestedKey>(referencing: decoder,
                                                                      wrapping: dictionary)
        return KeyedDecodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        guard let value = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key,
                                            DecodingError.Context(codingPath: codingPath,
                                                                  debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \"\(key.stringValue)\""))
        }
        
        do {
            return _MessagePackUnkeyedDecodingContainer(referencing: decoder,
                                                        wrapping: try value.arrayValue())
        } catch {
            let description = "Expected to decode array but found \(value)"
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: description)
            throw DecodingError.typeMismatch([MessagePackValue].self, context)
        }
    }
    
    private func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        
        let value: MessagePackValue = container[key.stringValue] ?? .nil
        return _MessagePackDecoder(referencing: value,
                                   at: decoder.codingPath,
                                   options: decoder.options)
    }
    
    func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: _MessagePackKey.super)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
}

fileprivate struct _MessagePackUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    
    private let decoder: _MessagePackDecoder
    
    private let container: [MessagePackValue]
    
    private(set) var codingPath: [CodingKey]
    
    private(set) var currentIndex: Int
    
    fileprivate init(referencing decoder: _MessagePackDecoder,
                     wrapping container: [MessagePackValue]) {
        self.decoder = decoder
        self.container = container
        self.codingPath = decoder.codingPath
        self.currentIndex = 0
    }
    
    var count: Int? {
        return container.count
    }
    
    var isAtEnd: Bool {
        return currentIndex >= count!
    }
    
    private func expectNotAtEnd(type: Any.Type) throws {
        guard !isAtEnd else {
            let path = decoder.codingPath + [_MessagePackKey(index: currentIndex)]
            let context = DecodingError.Context(codingPath: path,
                                                debugDescription: "Unkeyed container is at end.")
            throw DecodingError.valueNotFound(type,
                                              context)
        }
    }
    
    mutating func decodeNil() throws -> Bool {
        try expectNotAtEnd(type: Any?.self)
        
        if container[currentIndex].isNil {
            currentIndex += 1
            return true
        } else {
            return false
        }
    }
    
    mutating func decode(_ type: Bool.Type) throws -> Bool {
        try expectNotAtEnd(type: type)
        
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex], as: Bool.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath + [_MessagePackKey(index: currentIndex)],
                                                                    debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    mutating func decode(_ type: Int.Type) throws -> Int {
        try expectNotAtEnd(type: type)
        
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex],
                                              as: Int.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath + [_MessagePackKey(index: currentIndex)],
                                                                    debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        try expectNotAtEnd(type: type)
        
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex],
                                              as: Int8.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath + [_MessagePackKey(index: currentIndex)],
                                                                    debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        try expectNotAtEnd(type: type)
        
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex],
                                              as: Int16.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath + [_MessagePackKey(index: currentIndex)],
                                                                    debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        try expectNotAtEnd(type: type)
        
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex],
                                              as: Int32.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath + [_MessagePackKey(index: currentIndex)],
                                                                    debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        try expectNotAtEnd(type: type)
        
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex],
                                              as: Int64.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath + [_MessagePackKey(index: currentIndex)],
                                                                    debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    mutating func decode(_ type: UInt.Type) throws -> UInt {
        try expectNotAtEnd(type: type)
        
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex],
                                              as: UInt.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath + [_MessagePackKey(index: currentIndex)],
                                                                    debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        try expectNotAtEnd(type: type)
        
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex],
                                              as: UInt8.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath + [_MessagePackKey(index: currentIndex)],
                                                                    debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        try expectNotAtEnd(type: type)
        
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex],
                                              as: UInt16.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath + [_MessagePackKey(index: currentIndex)],
                                                                    debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        try expectNotAtEnd(type: type)
        
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex],
                                              as: UInt32.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath + [_MessagePackKey(index: currentIndex)],
                                                                    debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        try expectNotAtEnd(type: type)
        
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex],
                                              as: UInt64.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath + [_MessagePackKey(index: currentIndex)],
                                                                    debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    mutating func decode(_ type: Float.Type) throws -> Float {
        try expectNotAtEnd(type: type)
        
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex],
                                              as: Float.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath + [_MessagePackKey(index: currentIndex)],
                                                                    debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    mutating func decode(_ type: Double.Type) throws -> Double {
        try expectNotAtEnd(type: type)
        
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex],
                                              as: Double.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath + [_MessagePackKey(index: currentIndex)],
                                                                    debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    mutating func decode(_ type: String.Type) throws -> String {
        try expectNotAtEnd(type: type)
        
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex],
                                              as: String.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath + [_MessagePackKey(index: currentIndex)],
                                                                    debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try expectNotAtEnd(type: type)
        
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard let decoded = try decoder.unbox(container[currentIndex],
                                              as: T.self) else {
            throw DecodingError.valueNotFound(type,
                                              DecodingError.Context(codingPath: decoder.codingPath + [_MessagePackKey(index: currentIndex)],
                                                                    debugDescription: "Expected \(type) but found null instead."))
        }
        
        currentIndex += 1
        return decoded
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."))
        }
        
        let value = container[currentIndex]
        
        let messagePackDictionary: [MessagePackValue : MessagePackValue]
        do {
            messagePackDictionary = try value.dictionaryValue()
        } catch {
            let description = "Cannot get keyed decoding container -- found \(value) instead"
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: description)
            throw DecodingError.typeMismatch([MessagePackValue: MessagePackValue].self, context)
        }
        
        let dictionary = try messagePackDictionary.reduce(into: [String: MessagePackValue]()) {
            do {
                $0[try $1.key.stringValue()] = $1.value
            } catch {
                let description = "Expected to decode string but found \($1.key)"
                let context = DecodingError.Context(codingPath: codingPath,
                                                    debugDescription: description)
                throw DecodingError.typeMismatch(String.self,
                                                 context)
            }
        }
        
        currentIndex += 1
        let container = _MessagePackKeyedDecodingContainer<NestedKey>(referencing: decoder,
                                                                      wrapping: dictionary)
        return KeyedDecodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."))
        }
        
        let value = container[currentIndex]
        let array: [MessagePackValue]
        do {
            array = try value.arrayValue()
        } catch {
            let description = "Expected to decode array but found \(value)"
            let context = DecodingError.Context(codingPath: codingPath,
                                                debugDescription: description)
            throw DecodingError.typeMismatch([MessagePackValue].self,
                                             context)
        }
        
        currentIndex += 1
        return _MessagePackUnkeyedDecodingContainer(referencing: decoder, wrapping: array)
    }
    
    mutating func superDecoder() throws -> Decoder {
        decoder.codingPath.append(_MessagePackKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }
        
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Decoder.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get superDecoder() -- unkeyed container is at end."))
        }
        
        let value = container[currentIndex]
        currentIndex += 1
        return _MessagePackDecoder(referencing: value, at: decoder.codingPath, options: decoder.options)
    }
}

extension _MessagePackDecoder : SingleValueDecodingContainer {
    
    func decodeNil() -> Bool {
        storage.topContainer.isNil
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        try unbox(storage.topContainer, as: Bool.self)!
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        try unbox(storage.topContainer, as: Int.self)!
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        try unbox(storage.topContainer, as: Int8.self)!
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        try unbox(storage.topContainer, as: Int16.self)!
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        try unbox(storage.topContainer, as: Int32.self)!
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        try unbox(storage.topContainer, as: Int64.self)!
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        try unbox(storage.topContainer, as: UInt.self)!
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try unbox(storage.topContainer, as: UInt8.self)!
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try unbox(storage.topContainer, as: UInt16.self)!
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try unbox(storage.topContainer, as: UInt32.self)!
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try unbox(storage.topContainer, as: UInt64.self)!
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        try unbox(storage.topContainer, as: Float.self)!
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        try unbox(storage.topContainer, as: Double.self)!
    }
    
    func decode(_ type: String.Type) throws -> String {
        try unbox(storage.topContainer, as: String.self)!
    }
    
    func decode<T : Decodable>(_ type: T.Type) throws -> T {
        try unbox(storage.topContainer, as: T.self)!
    }
}

// MARK: Concrete Value Representations

extension _MessagePackDecoder {
    
    fileprivate func unbox(_ value: MessagePackValue,
                           as type: Bool.Type) throws -> Bool? {
        try value.boolValue()
    }
    
    fileprivate func unbox(_ value: MessagePackValue,
                           as type: Int.Type) throws -> Int? {
        switch options.numberDecodingStrategy {
        case .noTypeConversion:
            return Int(truncatingIfNeeded:try value.int64Value())
        case .automaticTypeConversion:
            return value.numberValue?.intValue
        }
    }
    
    fileprivate func unbox(_ value: MessagePackValue,
                           as type: Int8.Type) throws -> Int8? {
        switch options.numberDecodingStrategy {
        case .noTypeConversion:
            return Int8(truncatingIfNeeded: try value.int64Value())
        case .automaticTypeConversion:
            return value.numberValue?.int8Value
        }
    }
    
    fileprivate func unbox(_ value: MessagePackValue,
                           as type: Int16.Type) throws -> Int16? {
        switch options.numberDecodingStrategy {
        case .noTypeConversion:
            return Int16(truncatingIfNeeded: try value.int64Value())
        case .automaticTypeConversion:
            return value.numberValue?.int16Value
        }
    }
    
    fileprivate func unbox(_ value: MessagePackValue,
                           as type: Int32.Type) throws -> Int32? {
        switch options.numberDecodingStrategy {
        case .noTypeConversion:
            return Int32(truncatingIfNeeded: try value.int64Value())
        case .automaticTypeConversion:
            return value.numberValue?.int32Value
        }
    }
    
    fileprivate func unbox(_ value: MessagePackValue,
                           as type: Int64.Type) throws -> Int64? {
        switch options.numberDecodingStrategy {
        case .noTypeConversion:
            return Int64(truncatingIfNeeded: try value.int64Value())
        case .automaticTypeConversion:
            return value.numberValue?.int64Value
        }
    }
    
    fileprivate func unbox(_ value: MessagePackValue,
                           as type: UInt.Type) throws -> UInt? {
        switch options.numberDecodingStrategy {
        case .noTypeConversion:
            return UInt(truncatingIfNeeded: try value.uint64Value())
        case .automaticTypeConversion:
            return value.numberValue?.uintValue
        }
    }
    
    fileprivate func unbox(_ value: MessagePackValue,
                           as type: UInt8.Type) throws -> UInt8? {
        switch options.numberDecodingStrategy {
        case .noTypeConversion:
            return UInt8(truncatingIfNeeded: try value.uint64Value())
        case .automaticTypeConversion:
            return value.numberValue?.uint8Value
        }
    }
    
    fileprivate func unbox(_ value: MessagePackValue,
                           as type: UInt16.Type) throws -> UInt16? {
        switch options.numberDecodingStrategy {
        case .noTypeConversion:
            return UInt16(truncatingIfNeeded: try value.uint64Value())
        case .automaticTypeConversion:
            return value.numberValue?.uint16Value
        }
    }
    
    fileprivate func unbox(_ value: MessagePackValue,
                           as type: UInt32.Type) throws -> UInt32? {
        switch options.numberDecodingStrategy {
        case .noTypeConversion:
            return UInt32(truncatingIfNeeded: try value.uint64Value())
        case .automaticTypeConversion:
            return value.numberValue?.uint32Value
        }
    }
    
    fileprivate func unbox(_ value: MessagePackValue,
                           as type: UInt64.Type) throws -> UInt64? {
        switch options.numberDecodingStrategy {
        case .noTypeConversion:
            return UInt64(truncatingIfNeeded: try value.uint64Value())
        case .automaticTypeConversion:
            return value.numberValue?.uint64Value
        }
    }
    
    fileprivate func unbox(_ value: MessagePackValue,
                           as type: Float.Type) throws -> Float? {
        switch options.numberDecodingStrategy {
        case .noTypeConversion:
            return try value.floatValue()
        case .automaticTypeConversion:
            return value.numberValue?.floatValue
        }
    }
    
    fileprivate func unbox(_ value: MessagePackValue,
                           as type: Double.Type) throws -> Double? {
        switch options.numberDecodingStrategy {
        case .noTypeConversion:
            return try value.doubleValue()
        case .automaticTypeConversion:
            return value.numberValue?.doubleValue
        }
    }
    
    fileprivate func unbox(_ value: MessagePackValue,
                           as type: String.Type) throws -> String? {
        try value.stringValue()
    }
    
    fileprivate func unbox(_ value: MessagePackValue,
                           as type: Data.Type) throws -> Data? {
        try value.dataValue()
    }
    
    fileprivate func unbox<T : Decodable>(_ value: MessagePackValue,
                                          as type: T.Type) throws -> T? {
        let decoded: T
        if T.self == Data.self || T.self == NSData.self {
            guard let data = try unbox(value, as: Data.self) else { return nil }
            decoded = data as! T
        } else {
            storage.push(container: value)
            decoded = try T(from: self)
            storage.popContainer()
        }
        
        return decoded
    }
}

// MARK: - Shared Key Types

fileprivate struct _MessagePackKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
    
    fileprivate init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }
    
    fileprivate static let `super` = _MessagePackKey(stringValue: "super")!
}


// MARK: - Box

fileprivate protocol _MessagePackBox {
    var messagePackValue: MessagePackValue { get }
}

fileprivate final class _MessagePackValueBox: _MessagePackBox {
    var messagePackValue: MessagePackValue
    
    init(_ messagePackValue: MessagePackValue) {
        self.messagePackValue = messagePackValue
    }
}

fileprivate final class _MessagePackDictionaryBox: _MessagePackBox {
    private var dictionary = NSMutableDictionary()
    
    var messagePackValue: MessagePackValue {
        var map = [MessagePackValue: MessagePackValue]()
        map.reserveCapacity(self.dictionary.count)
        dictionary.enumerateKeysAndObjects { key, value, _ in
            map[.string(key as! String)] = (value as! _MessagePackBox).messagePackValue
        }
        return .map(map)
    }

    subscript(key: String) -> _MessagePackBox? {
        get {
            if let value = dictionary.object(forKey: key) {
                return (value as! _MessagePackBox)
            }
            return nil
        }
        set {
            if let newValue = newValue {
                dictionary.setObject(newValue, forKey: key as NSCopying)
            } else {
                dictionary.removeObject(forKey: key as NSCopying)
            }
        }
    }
    
    subscript<K: CodingKey>(key: K) -> _MessagePackBox? {
        get {
            if let value = dictionary.object(forKey: key.stringValue) {
                return (value as! _MessagePackBox)
            }
            return nil
        }
        set {
            if let newValue = newValue {
                dictionary.setObject(newValue, forKey: key.stringValue as NSCopying)
            } else {
                dictionary.removeObject(forKey: key.stringValue as NSCopying)
            }
        }
    }
}

fileprivate final class _MessagePackArrayBox: _MessagePackBox {
    var array: [_MessagePackBox] = []
    
    var messagePackValue: MessagePackValue {
        let valueArray = array.map { $0.messagePackValue }
        return .array(valueArray)
    }
    
    var count: Int {
        array.count
    }

    func append(_ newElement: _MessagePackBox) {
        array.append(newElement)
    }
}

// MARK: - MessagePackValue

fileprivate extension MessagePackValue {
    var numberValue: NSNumber? {
        switch self {
        case .int(let value):
            return value as NSNumber
        case .uint(let value):
            return value as NSNumber
        case .double(let value):
            return value as NSNumber
        case .float(let value):
            return value as NSNumber
        default:
            return nil
        }
    }
}
