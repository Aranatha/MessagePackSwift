import Foundation
import XCTest
@testable import MessagePack

class ConveniencePropertiesTests: XCTestCase {
    static var allTests = {
        return [
            ("testCount", testCount),
            ("testIndexedSubscript", testIndexedSubscript),
            ("testKeyedSubscript", testKeyedSubscript),
            ("testIsNil", testIsNil),
            ("testIntValue", testIntValue),
            ("testInt8Value", testInt8Value),
            ("testInt16Value", testInt16Value),
            ("testIn32Value", testInt32Value),
            ("testInt64Value", testInt64Value),
            ("testUIntValue", testUIntValue),
            ("testUInt8Value", testUInt8Value),
            ("testUInt16Value", testUInt16Value),
            ("testUInt32Value", testUInt32Value),
            ("testUInt64Value", testUInt64Value),
            ("testArrayValue", testArrayValue),
            ("testBoolValue", testBoolValue),
            ("testFloatValue", testFloatValue),
            ("testDoubleValue", testDoubleValue),
            ("testStringValue", testStringValue),
            ("testStringValueWithCompatibility", testStringValueWithCompatibility),
            ("testDataValue", testDataValue),
            ("testExtendedValue", testExtendedValue),
            ("testExtendedType", testExtendedType),
            ("testMapValue    ", testMapValue    ),
        ]
    }()

    func testCount() {
        XCTAssertEqual(try MessagePackValue.array([0]).count(), 1)
        XCTAssertEqual(try MessagePackValue.map(["c": "cookie"]).count(), 1)
        XCTAssertThrowsError(try MessagePackValue.nil.count())
    }

    func testIndexedSubscript() {
        XCTAssertEqual(MessagePackValue.array([0])[0], .uint(0))
        XCTAssertNil(MessagePackValue.array([0])[1])
        XCTAssertNil(MessagePackValue.nil[0])
    }

    func testKeyedSubscript() {
        XCTAssertEqual(MessagePackValue.map(["c": "cookie"])["c"], "cookie")
        XCTAssertNil(MessagePackValue.nil["c"])
    }

    func testIsNil() {
        XCTAssertTrue(MessagePackValue.nil.isNil)
        XCTAssertFalse(MessagePackValue.bool(true).isNil)
    }

    func testIntValue() {
        XCTAssertEqual(try MessagePackValue.int(-1).intValue(), -1)
        XCTAssertEqual(try MessagePackValue.uint(1).intValue(), 1)
        XCTAssertThrowsError(try MessagePackValue.nil.intValue())
    }

    func testInt8Value() {
        XCTAssertEqual(try MessagePackValue.int(-1).int8Value(), -1)
        XCTAssertEqual(try MessagePackValue.int(1).int8Value(), 1)
        XCTAssertThrowsError(try MessagePackValue.int(Int64(Int8.min) - 1).int8Value())
        XCTAssertThrowsError(try MessagePackValue.int(Int64(Int8.max) + 1).int8Value())

        XCTAssertEqual(try MessagePackValue.uint(1).int8Value(), 1)
        XCTAssertThrowsError(try MessagePackValue.uint(UInt64(Int8.max) + 1).int8Value())
        XCTAssertThrowsError(try MessagePackValue.nil.int8Value())
    }

    func testInt16Value() {
        XCTAssertEqual(try MessagePackValue.int(-1).int16Value(), -1)
        XCTAssertEqual(try MessagePackValue.int(1).int16Value(), 1)
        XCTAssertThrowsError(try MessagePackValue.int(Int64(Int16.min) - 1).int16Value())
        XCTAssertThrowsError(try MessagePackValue.int(Int64(Int16.max) + 1).int16Value())

        XCTAssertEqual(try MessagePackValue.uint(1).int16Value(), 1)
        XCTAssertThrowsError(try MessagePackValue.uint(UInt64(Int16.max) + 1).int16Value())
        XCTAssertThrowsError(try MessagePackValue.nil.int16Value())
    }

    func testInt32Value() {
        XCTAssertEqual(try MessagePackValue.int(-1).int32Value(), -1)
        XCTAssertEqual(try MessagePackValue.int(1).int32Value(), 1)
        XCTAssertThrowsError(try MessagePackValue.int(Int64(Int32.min) - 1).int32Value())
        XCTAssertThrowsError(try MessagePackValue.int(Int64(Int32.max) + 1).int32Value())

        XCTAssertEqual(try MessagePackValue.uint(1).int32Value(), 1)
        XCTAssertThrowsError(try MessagePackValue.uint(UInt64(Int32.max) + 1).int32Value())
        XCTAssertThrowsError(try MessagePackValue.nil.int32Value())
    }

    func testInt64Value() {
        XCTAssertEqual(try MessagePackValue.int(-1).int64Value(), -1)
        XCTAssertEqual(try MessagePackValue.int(1).int64Value(), 1)

        XCTAssertEqual(try MessagePackValue.uint(1).int64Value(), 1)
        XCTAssertThrowsError(try MessagePackValue.uint(UInt64(Int64.max) + 1).int64Value())
        XCTAssertThrowsError(try MessagePackValue.nil.int64Value())
    }

    func testUIntValue() {
        XCTAssertEqual(try MessagePackValue.uint(1).uintValue(), 1)
        XCTAssertThrowsError(try MessagePackValue.int(-1).uintValue())
        XCTAssertEqual(try MessagePackValue.int(1).uintValue(), 1)
        XCTAssertThrowsError(try MessagePackValue.nil.uintValue())
    }

    func testUInt8Value() {
        XCTAssertEqual(try MessagePackValue.uint(1).uint8Value(), 1)
        XCTAssertThrowsError(try MessagePackValue.uint(UInt64(UInt8.max) + 1).uint8Value())
        XCTAssertThrowsError(try MessagePackValue.int(-1).uint8Value())
        XCTAssertEqual(try MessagePackValue.int(1).uint8Value(), 1)
        XCTAssertThrowsError(try MessagePackValue.int(Int64(UInt8.max) + 1).uint8Value())
        XCTAssertThrowsError(try MessagePackValue.nil.uint8Value())
    }

    func testUInt16Value() {
        XCTAssertEqual(try MessagePackValue.uint(1).uint16Value(), 1)
        XCTAssertThrowsError(try MessagePackValue.uint(UInt64(UInt16.max) + 1).uint16Value())

        XCTAssertThrowsError(try MessagePackValue.int(-1).uint16Value())
        XCTAssertEqual(try MessagePackValue.int(1).uint16Value(), 1)
        XCTAssertThrowsError(try MessagePackValue.int(Int64(UInt16.max) + 1).uint16Value())
        XCTAssertThrowsError(try MessagePackValue.nil.uint16Value())
    }

    func testUInt32Value() {
        XCTAssertEqual(try MessagePackValue.uint(1).uint32Value(), 1)
        XCTAssertThrowsError(try MessagePackValue.uint(UInt64(UInt32.max) + 1).uint32Value())
        XCTAssertThrowsError(try MessagePackValue.int(-1).uint32Value())
        XCTAssertEqual(try MessagePackValue.int(1).uint32Value(), 1)
        XCTAssertThrowsError(try MessagePackValue.int(Int64(UInt32.max) + 1).uint32Value())
        XCTAssertThrowsError(try MessagePackValue.nil.uint32Value())
    }

    func testUInt64Value() {
        XCTAssertEqual(try MessagePackValue.uint(1).uint64Value(), 1)
        XCTAssertThrowsError(try MessagePackValue.int(-1).uint64Value())
        XCTAssertEqual(try MessagePackValue.int(1).uint64Value(), 1)
        XCTAssertThrowsError(try MessagePackValue.nil.uint64Value())
    }

    func testArrayValue() {
        XCTAssertEqual(try MessagePackValue.array([0]).arrayValue(), [0])
        XCTAssertThrowsError(try MessagePackValue.nil.arrayValue())
    }

    func testBoolValue() {
        XCTAssertEqual(try MessagePackValue.bool(true).boolValue(), true)
        XCTAssertEqual(try MessagePackValue.bool(false).boolValue(), false)
        XCTAssertThrowsError(try MessagePackValue.nil.boolValue())
    }

    func testFloatValue() {
        XCTAssertThrowsError(try MessagePackValue.nil.floatValue())
        XCTAssertEqual(try MessagePackValue.float(3.14).floatValue(), 3.14, accuracy: 0.0001)
        XCTAssertThrowsError(try MessagePackValue.double(3.14).floatValue())
    }

    func testDoubleValue() {
        XCTAssertThrowsError(try MessagePackValue.nil.doubleValue())
        XCTAssertEqual(try MessagePackValue.float(3.14).doubleValue(), 3.14, accuracy: 0.0001)
        XCTAssertEqual(try MessagePackValue.double(3.14).doubleValue(), 3.14, accuracy: 0.0001)
    }

    func testStringValue() {
        XCTAssertEqual(try MessagePackValue.string("Hello, world!").stringValue(), "Hello, world!")
        XCTAssertThrowsError(try MessagePackValue.nil.stringValue())
    }

    func testStringValueWithCompatibility() {
        XCTAssertEqual(try MessagePackValue.binary(Data([0x48, 0x65, 0x6c, 0x6c, 0x6f, 0x2c, 0x20, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x21])).stringValue(), "Hello, world!")
    }

    func testDataValue() {
        XCTAssertThrowsError(try MessagePackValue.nil.dataValue())

        let dataValue = Data([0x00, 0x01, 0x02, 0x03, 0x04])
        XCTAssertEqual(try MessagePackValue.binary(dataValue).dataValue(), dataValue)
        XCTAssertEqual(try MessagePackValue.extended(4, dataValue).dataValue(), Data([0x00, 0x01, 0x02, 0x03, 0x04]))
    }

    func testExtendedValue() {
        XCTAssertThrowsError(try MessagePackValue.nil.extendedValue())

        let expectedData = Data([0x00, 0x01, 0x02, 0x03, 0x04])
        do {
            let (type, data) = try MessagePackValue.extended(4, expectedData).extendedValue()
            XCTAssertEqual(type, 4)
            XCTAssertEqual(data, expectedData)
        } catch {
            XCTFail()
        }
    }

    func testExtendedType() {
        XCTAssertThrowsError(try MessagePackValue.nil.extendedType())

        let data = Data([0x00, 0x01, 0x02, 0x03, 0x04])
        XCTAssertEqual(try MessagePackValue.extended(4, data).extendedType(), 4)
    }

    func testMapValue() {
        XCTAssertEqual(try MessagePackValue.map(["c": "cookie"]).dictionaryValue(), ["c": "cookie"])
        XCTAssertThrowsError(try MessagePackValue.nil.dictionaryValue())
    }
}
