import MetalKit

public protocol MTLBufferRepresentable {
    func buffer() -> MTLBuffer
}

extension Identifiable {
    // didIdChange
    public func observeID( _ t: (Self) -> Void) -> Bool {
        let id = self.id
        t(self)
        return id != self.id
    }
}

extension MutableCollection {
    @inlinable
    public mutating func halfStablePartition(
        isSuffixElement: (Element) throws -> Bool
    ) rethrows -> Index {
        guard var i = try firstIndex(where: isSuffixElement)
        else { return endIndex }

        var j = index(after: i)
        while j != endIndex {
            if try !isSuffixElement(self[j]) {
                swapAt(i, j)
                formIndex(after: &i)
            }
            formIndex(after: &j)
        }
        return i
    }
//
//    @inlinable
//    public mutating func halfStablePartitionIndexed(
//        isSuffixElement: (Index, Element) throws -> Bool
//    ) rethrows -> Index {
//        guard var i = try firstIndex(where: isSuffixElement)
//        else { return endIndex }
//
//        var j = index(after: i)
//        while j != endIndex {
//            if try !isSuffixElement(self[j]) {
//                swapAt(i, j)
//                formIndex(after: &i)
//            }
//            formIndex(after: &j)
//        }
//        return i
//    }
}

// setFragmentBuffers
// setVertexBuffers

extension Array where Element == MTLBuffer {
    public init(_ array: [MTLBufferRepresentable]) {
        self.init()
        self.reserveCapacity(array.count)
        array.forEach {
            self.append($0.buffer())
        }
    }

    public mutating func append(_ buffer: MTLBufferRepresentable) {
        self.append(buffer.buffer())
    }
}
