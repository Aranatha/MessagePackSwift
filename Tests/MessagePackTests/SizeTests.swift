import Foundation
import XCTest
@testable import MessagePack

class SizeTests: XCTestCase {
    static var allTests = {
        return [
            ("testCodableSize", testCodableSize),
            ("testDictionarySize", testDictionarySize),
            ("testArraySize", testArraySize),
            ("testMixedDataSize", testMixedDataSize),
        ]
    }()

    struct TestCodable: Codable {
        let string: String = "hello"
        let int: Int = 1
    }

    func testCodableSize() {
        do {
            let msgPackData = try MessagePackEncoder().encode(TestCodable())
            let jsonData = try JSONEncoder().encode(TestCodable())
            let plistData = try PropertyListEncoder().encode(TestCodable())
            XCTAssertLessThan(msgPackData.count, jsonData.count)
            XCTAssertLessThan(msgPackData.count, plistData.count/2)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testDictionarySize() {
        do {
            let msgPackData = try MessagePackEncoder().encode(["key":"value"])
            let jsonData = try JSONEncoder().encode(["key":"value"])
            let plistData = try PropertyListEncoder().encode(["key":"value"])
            XCTAssertLessThan(msgPackData.count, jsonData.count)
            XCTAssertLessThan(msgPackData.count, plistData.count/2)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testArraySize() {
        do {
            let msgPackData = try MessagePackEncoder().encode(["1", "2", "3"])
            let jsonData = try JSONEncoder().encode(["1", "2", "3"])
            let plistData = try PropertyListEncoder().encode(["1", "2", "3"])
            XCTAssertLessThan(msgPackData.count, jsonData.count)
            XCTAssertLessThan(msgPackData.count, plistData.count/2)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testMixedDataSize() {
        do {
            let msgPackData = try MessagePackEncoder().encode([["1":TestCodable()], ["2":TestCodable()], ["3":TestCodable()]])
            let jsonData = try JSONEncoder().encode([["1":TestCodable()], ["2":TestCodable()], ["3":TestCodable()]])
            let plistData = try PropertyListEncoder().encode([["1":TestCodable()], ["2":TestCodable()], ["3":TestCodable()]])
            XCTAssertLessThan(msgPackData.count, jsonData.count)
            XCTAssertLessThan(msgPackData.count, plistData.count)
        } catch {
            XCTFail("\(error)")
        }
    }
}
