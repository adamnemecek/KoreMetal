import Metal
import Ext
import Combine

//class Wrapper : ObservableObject {
//    var inner: GPUArray<Int>
//
//
//    public var objectWillChange: ObservableObjectPublisher {
//        print("objectwill change")
//
////        return self.inner.objectWillChange
//    }
//    init() {
//        fatalError()
//    }
//}

@_fixed_layout
public final class GPUArray<Element>: MutableCollection,
                                      Identifiable,
                                      ExpressibleByArrayLiteral
//                                      ObservableObject
{
    public typealias Index = Int

    public var id: Int {
        self._raw.id
    }

    // how many are actually in used
    @usableFromInline
    internal var _count: Int

    @usableFromInline
    internal var _raw: RawGPUArray<Element>

    @inline(__always) @inlinable
    public var isEmpty: Bool {
        self._count == 0
    }

    @inline(__always) @inlinable
    public var isSome: Bool {
        !self.isEmpty
    }

    @inline(__always) @inlinable
    public var count: Int {
        self._count
    }

//    @usableFromInline
    public private(set) var uptime: Uptime

    public init?(
        device: MTLDevice,
        capacity: Int,
        options: MTLResourceOptions = []
    ) {
        assert(Self.isElementStruct)

        guard let raw = RawGPUArray<Element>(
            device: device,
            capacity: capacity,
            options: options
        ) else { return nil }

        self._count = 0
        self._raw = raw
        self.uptime = Uptime()
    }

    public init() {
        assert(Self.isElementStruct)

        guard let raw = RawGPUArray<Element>(
            capacity: 16,
            options: []
        ) else {
            fatalError()
        }
        self._count = 0
        self._raw = raw
        self.uptime = Uptime()
    }

    public init<S>(_ elements: S) where S : Sequence, Element == S.Element {
        assert(Self.isElementStruct)

        guard let raw = RawGPUArray<Element>(
            capacity: elements.underestimatedCount,
            options: []
        ) else { fatalError() }

        self._count = 0
        self._raw = raw
        self.uptime = Uptime()

        self.append(contentsOf: elements)
    }

    public init<S>(device: MTLDevice, _ elements: S) where S : Sequence, Element == S.Element {
        fatalError()
//        assert(Self.isElementStruct)
//
//        guard let raw = RawGPUArray<Element>(
//            device:
//            capacity: elements.underestimatedCount,
//            options: []
//        ) else { fatalError() }
//
//        self._count = 0
//        self.raw = raw
//        self.append(contentsOf: elements)
    }

    public init(
        arrayLiteral elements: Element...
    ) {
        assert(Self.isElementStruct)

        guard let raw = RawGPUArray<Element>(
            capacity: elements.underestimatedCount,
            options: []
        ) else { fatalError() }

        self._count = 0
        self._raw = raw
        self.uptime = Uptime()

        self.append(contentsOf: elements)
    }

    public init(
        device: MTLDevice,
        repeating repeatedValue: Element,
        count: Int
    ) {
        assert(Self.isElementStruct)

        guard let raw = RawGPUArray<Element>(
            capacity: count,
            options: []
        ) else { fatalError() }

        self._count = 0
        self._raw = raw
        self.uptime = Uptime()

        self.append(contentsOf: repeatElement(repeatedValue, count: count))
    }

    ///
    /// takes the ownership of a buffer
    ///
//    public init(buffer: MTLBuffer) {
//        fatalError()
//    }

    public var resourceOptions: MTLResourceOptions {
        self._raw.resourceOptions
    }

    public func clone() -> Self {
        fatalError()
//        Self(
//            device: self.device,
//            capacity: self.capacity,
//            options: self.resourceOptions
//        )!
    }

    @inline(__always) @inlinable
    public var capacity: Int {
        self._raw.capacity
    }

    @inline(__always) @inlinable
    public var startIndex: Index {
        return 0
    }

    @inline(__always) @inlinable
    public var endIndex: Index {
        return self._count
    }

    @inline(__always) @inlinable
    public subscript(index: Index) -> Element {
        get {
            assert(index < self._count)
            return self._raw._ptr[index]
        }
        set {
            assert(index < self._count)
            self._raw._ptr[index] = newValue
        }
    }

    @inline(__always) @inlinable
    public func index(after i: Index) -> Index {
        return i + 1
    }

    @inline(__always) @inlinable
    public var device: MTLDevice {
        self._raw.device
    }

    public func reserveCapacity(_ minimumCapacity: Int) {
        if minimumCapacity <= self.capacity {
            return
        }
        guard var new = RawGPUArray<Element>(
            device: self.device,
            capacity: minimumCapacity,
            options: self._raw.resourceOptions
        ) else { fatalError() }

        new.label = self.label
        new.copyMemory(from: self._raw, count: self._count)
        let old = self._raw
        self._raw = new
        old.deinit()

        self.uptime = Uptime()

//        self.objectWillChange.send()
//        AllocationCounter.shared.increment()
    }

    public func shrink(factor: Int) {
        fatalError()
    }

    @inlinable @inline(__always)
    public func removeAll(keepingCapacity keepCapacity: Bool = false) {
        self._count = 0
    }

    @inlinable @inline(__always)
    public func removeAll() {
        self._count = 0
    }

    public func removeAll(
        where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {
        self._count = try self._raw.removeAll(
            count: self._count,
            where: shouldBeRemoved
        )
    }

    @inlinable @inline(__always)
    public var label: String? {
        get {
            self._raw.label
        }
        set {
            self._raw.label = newValue
        }
    }

    @inline(__always) @inlinable
    public func append(_ newElement: Element) {
        self.reserveCapacity(self._count + 1)
        self._raw[self._count] = newElement
        self._count += 1
    }

    @inline(__always) @inlinable
    public func append<S>(contentsOf newElements: S) where Element == S.Element, S: Sequence {
        self.reserveCapacity(self._count + newElements.underestimatedCount)

        for e in newElements {
            self.append(e)
        }
    }

    @inlinable @inline(__always)
    public var first: Element? {
        guard !self.isEmpty else { return nil }
        return self[0]
    }

    @inlinable @inline(__always)
    public var last: Element? {
        guard !self.isEmpty else { return nil }
        return self[endIndex - 1]
    }

    func validate() -> Bool {
        self._raw.validate()
    }

    //    public func replaceSubrange<C: Collection>(_ subrange: Range<Index>, with newElements: C) where C.Iterator.Element == Element {
    //        /// adapted from https://github.com/apple/swift/blob/ea2f64cad218bb64a79afee41b77fe7bfc96cfd2/stdlib/public/core/ArrayBufferProtocol.swift#L140
    //        let newCount = Int(newElements._count)
    //
    //        let oldCount = self._count
    //        let eraseCount = subrange._count
    //
    //        let growth = newCount - eraseCount
    //        self._count = oldCount + growth
    //
    //        var elements = ptr.baseAddress!
    //        let oldTailIndex = subrange.upperBound
    //        let oldTailStart = elements + oldTailIndex
    //        let newTailIndex = oldTailIndex + growth
    //        let newTailStart = oldTailStart + growth
    //        let tailCount = oldCount - subrange.upperBound
    //
    //        if growth > 0 {
    //            // Slide the tail part of the buffer forwards, in reverse order
    //            // so as not to self-clobber.
    //            newTailStart.moveInitialize(from: oldTailStart, count: tailCount)
    //
    //            // Assign over the original subrange
    //            var i = newElements.startIndex
    //            for j in subrange {
    //                elements[j] = newElements[i]
    //                newElements.formIndex(after: &i)
    //            }
    //            // Initialize the hole left by sliding the tail forward
    //            for j in oldTailIndex..<newTailIndex {
    //                (elements + j).initialize(to: newElements[i])
    //                newElements.formIndex(after: &i)
    //            }
    //
    //        }
    //        else { // We're not growing the buffer
    //            // Assign all the new elements into the start of the subrange
    //            var i = subrange.lowerBound
    //            var j = newElements.startIndex
    //            for _ in 0..<newCount {
    //                elements[i] = newElements[j]
    //                i += 1
    //                newElements.formIndex(after: &j)
    //            }
    //
    //            // If the size didn't change, we're done.
    //            if growth == 0 {
    //                return
    //            }
    //
    //            // Move the tail backward to cover the shrinkage.
    //            let shrinkage = -growth
    //            if tailCount > shrinkage {   // If the tail length exceeds the shrinkage
    //                // Assign over the rest of the replaced range with the first
    //                // part of the tail.
    //                newTailStart.moveAssign(from: oldTailStart, count: shrinkage)
    //
    //                // Slide the rest of the tail back
    //                oldTailStart.moveInitialize(
    //                    from: oldTailStart + shrinkage, count: tailCount - shrinkage)
    //            }
    //            else {                      // Tail fits within erased elements
    //                // Assign over the start of the replaced range with the tail
    //                newTailStart.moveAssign(from: oldTailStart, count: tailCount)
    //
    //                // Destroy elements remaining after the tail in subrange
    //                (newTailStart + tailCount).deinitialize(
    //                    count: shrinkage - tailCount)
    //            }
    //        }
    //    }

    deinit {
        self._raw.deinit()
    }

    @inline(__always) @inlinable
    public func withUnsafeMTLBuffer<R>(
        _ body: (MTLBuffer) -> R
    ) -> R {
        self._raw.withUnsafeMTLBuffer(body)
    }

    @inline(__always) @inlinable
    public func withUnsafeBufferPointer<R>(
        _ body: (UnsafeBufferPointer<Element>
    ) throws -> R) rethrows -> R {
        try self._raw.withUnsafeBufferPointer(body, count: self._count)
    }

    @inline(__always) @inlinable
    public func withUnsafeMutableBufferPointer<R>(
        _ body: (UnsafeMutableBufferPointer<Element>
    ) throws -> R) rethrows -> R {
        try self._raw.withUnsafeMutableBufferPointer(body, count: self._count)
    }
}

extension GPUArray: CustomStringConvertible where Element: CustomStringConvertible {
    public var description: String {
        let inner = self.map { $0.description }.joined(separator: ", ")
        return "GPUArray<\(Element.self)>(\(inner))"
    }
}

extension GPUArray: BidirectionalCollection {
    @inline(__always) @inlinable
    public func index(before i: Index) -> Index {
        return i - 1
    }
}

// extension GPUArray: Sequence {
////    public func makeIterator() -> AnyIterator<Element> {
////        var i = self.indices.makeIterator()
////
////        return AnyIterator {
////            i.next().map { self[$0] }
////        }
////    }
//
//    public var underestimatedCount: Int {
//        self._count
//    }
// }

extension GPUArray: RandomAccessCollection {

}

extension GPUArray: Equatable where Element: Equatable {
    public static func ==(
        lhs: GPUArray<Element>,
        rhs: GPUArray<Element>
    ) -> Bool {
        guard lhs.count == rhs.count else { return false }
        return lhs._raw.eq(rhs._raw, count: lhs.count)
//        for i in 0 ..< lhs.count where lhs[i] != rhs[i] {
//            return false
//        }
//        return true
    }

}

// let eraseCount = subrange._count
// let insertCount = newElements._count
// let growth = insertCount - eraseCount
//
// _reserveCapacityImpl(minimumCapacity: self._count + growth,
//                    growForAppend: true)
// _buffer.replaceSubrange(subrange, with: insertCount, elementsOf: newElements)

extension GPUArray: RangeReplaceableCollection {
    public func replaceSubrange<C>(
        _ subrange: Range<Int>,
        with newElements: C
    ) where C: Collection, Element == C.Element {
        let eraseCount = subrange.count
        let insertCount = newElements.count
        let growth1 = insertCount - eraseCount

        //        let newCount = Swift.min(self._count - subrange._count + newElements._count, self._count)
        self.reserveCapacity(self._count + growth1)
        //        _sanityCheck(startIndex == 0, "_SliceBuffer should override this function.")
        let newCount = newElements.count
        let oldCount = self._count
        //        let eraseCount = subrange._count

        let growth = newCount - eraseCount
        self._count = oldCount + growth

        let elements = self._raw._ptr
        let oldTailIndex = subrange.upperBound
        //        let oldTailStart = elements.advanc + oldTailIndex
        let oldTailStart = elements.baseAddress!.advanced(by: oldTailIndex)
        let newTailIndex = oldTailIndex + growth
        let newTailStart = oldTailStart + growth
        let tailCount = oldCount - subrange.upperBound

        if growth > 0 {
            // Slide the tail part of the buffer forwards, in reverse order
            // so as not to self-clobber.
            newTailStart.moveInitialize(from: oldTailStart, count: tailCount)

            // Assign over the original subrange
            var i = newElements.startIndex
            for j in subrange {
                elements[j] = newElements[i]
                newElements.formIndex(after: &i)
            }
            // Initialize the hole left by sliding the tail forward
            for j in oldTailIndex..<newTailIndex {
                elements.baseAddress!.advanced(by: j).initialize(to: newElements[i])
                //            (elements + j).
                newElements.formIndex(after: &i)
            }
            //          _expectEnd(of: newValues, is: i)
        } else { // We're not growing the buffer
            // Assign all the new elements into the start of the subrange
            var i = subrange.lowerBound
            var j = newElements.startIndex
            for _ in 0..<newCount {
                elements[i] = newElements[j]
                i += 1
                newElements.formIndex(after: &j)
            }
            //          _expectEnd(of: newValues, is: j)

            // If the size didn't change, we're done.
            if growth == 0 {
                return
            }

            // Move the tail backward to cover the shrinkage.
            let shrinkage = -growth
            if tailCount > shrinkage {   // If the tail length exceeds the shrinkage
                // Assign over the rest of the replaced range with the first
                // part of the tail.
                newTailStart.moveAssign(from: oldTailStart, count: shrinkage)

                // Slide the rest of the tail back
                oldTailStart.moveInitialize(
                    from: oldTailStart + shrinkage, count: tailCount - shrinkage)
            } else {                      // Tail fits within erased elements
                // Assign over the start of the replaced range with the tail
                newTailStart.moveAssign(from: oldTailStart, count: tailCount)

                // Destroy elements remaining after the tail in subrange
                (newTailStart + tailCount).deinitialize(
                    count: shrinkage - tailCount)
            }
        }
        //        }
    }
}

extension GPUArray where Element: ExpressibleByIntegerLiteral {
    public convenience init(device: MTLDevice, count: Int) {
        self.init(device: device, repeating: 0, count: count)
    }
}


//extension GPUArray where Element: ExpressibleByIntegerLiteral {
