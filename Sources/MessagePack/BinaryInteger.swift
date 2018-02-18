import Foundation

extension BinaryInteger {
    init<T>(msgpk_exactly source: T) throws where T: BinaryInteger {
        guard let int = Self(exactly: source) else {
            throw MessagePackError.inexact
        }
        self = int
    }
}
