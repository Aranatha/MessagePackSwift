import Foundation

public struct Subdata: RandomAccessCollection {
	let slice: Slice<Data>

//	var base: Data { Data(slice) }
//	var baseStartIndex: Int { 0 }
//	var baseEndIndex: Int { slice.count }

    public init(data: Data,
                startIndex: Int = 0) {
        self.init(data: data,
				  startIndex: startIndex,
                  endIndex: data.count)
    }

    public init(data: Data,
                startIndex: Int,
                endIndex: Int) {
		self.slice = data[data.startIndex + startIndex ..< data.startIndex + endIndex]
    }

    public init(slice: Slice<Data>,
                startIndex: Int,
                endIndex: Int) {
		self.slice = slice[startIndex ..< endIndex]
    }

    public var startIndex: Int {
        0
    }

    public var endIndex: Int {
		slice.endIndex - slice.startIndex
    }

    public var count: Int {
        endIndex - startIndex
    }

    public var isEmpty: Bool {
		slice.startIndex == slice.endIndex
    }

    public subscript(index: Int) -> UInt8 {
		slice[slice.startIndex + index]
    }

    public func index(before i: Int) -> Int {
        i - 1
    }

    public func index(after i: Int) -> Int {
        i + 1
    }

    public subscript(bounds: Range<Int>) -> Subdata {
		precondition(slice.startIndex + bounds.upperBound <= slice.endIndex)
        return Subdata(slice: slice,
					   startIndex: slice.startIndex + bounds.lowerBound,
					   endIndex: slice.startIndex + bounds.upperBound)
    }

    public var data: Data {
        Data(slice)
    }
}
