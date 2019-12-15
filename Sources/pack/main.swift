import Foundation
import MessagePack

extension String {
    init(random length: Int) {
        let letters: [Unicode.Scalar] = (Array(65..<90) + Array(97..<122) + Array(48..<57)).map { Unicode.Scalar($0) }
        let mod = UInt32(letters.count)
        let characters = (0..<length).map { _ in Character(letters[Int(arc4random_uniform(mod))]) }
        self = String(characters)
    }
}

struct TestCodable: Codable {
    let string = String(random: 10)
    let int = Int(arc4random())
}

let mixedData = (0..<4000).map { ["\($0)":TestCodable()] }

sleep(1)

_ = try MessagePackEncoder().encode(mixedData)

sleep(1)

_ = try JSONEncoder().encode(mixedData)
