import Foundation

public struct Subdata: RandomAccessCollection {
    let base: Data
    let baseStartIndex: Int
    let baseEndIndex: Int

    public init(data: Data,
                startIndex: Int = 0) {
        self.init(data: data,
                  startIndex: startIndex,
                  endIndex: data.endIndex)
    }

    public init(data: Data,
                startIndex: Int,
                endIndex: Int) {
        self.base = data
        self.baseStartIndex = startIndex
        self.baseEndIndex = endIndex
    }

    public var startIndex: Int {
        0
    }

    public var endIndex: Int {
        baseEndIndex - baseStartIndex
    }

    public var count: Int {
        endIndex - startIndex
    }

    public var isEmpty: Bool {
        baseStartIndex == baseEndIndex
    }

    public subscript(index: Int) -> UInt8 {
        base[baseStartIndex + index]
    }

    public func index(before i: Int) -> Int {
        i - 1
    }

    public func index(after i: Int) -> Int {
        i + 1
    }

    public subscript(bounds: Range<Int>) -> Subdata {
        precondition(baseStartIndex + bounds.upperBound <= baseEndIndex)
        return Subdata(data: base,
                       startIndex: baseStartIndex + bounds.lowerBound,
                       endIndex: baseStartIndex + bounds.upperBound)
    }

    public var data: Data {
        base.subdata(in: baseStartIndex ..< baseEndIndex)
    }
}
