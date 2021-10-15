import Metal

public final class GPUArray<Element>: Collection {
    public typealias Index = Int

    // how many are actually in used
    public fileprivate(set) var count: Int
    fileprivate var raw: RawGPUArray<Element>

    public init?(device: MTLDevice,
                 capacity: Int,
                 options: MTLResourceOptions = []) {
        let memAlign = MemAlign<Element>(capacity: capacity)
        guard let raw = RawGPUArray<Element>(device: device,
                                             memAlign: memAlign,
                                             options: options) else { return nil }

        self.count = 0
        self.raw = raw
    }

    public var capacity: Int {
        self.raw.memAlign.capacity
    }

    public var startIndex: Index {
        return 0
    }

    public var endIndex: Index {
        return count
    }

    @inline(__always)
    public subscript(index: Index) -> Element {
        get {
            assert(index < self.count)
            return self.raw.ptr[index]
        }
        set {
            assert(index < self.count)
            self.raw.ptr[index] = newValue
        }
    }

    @inline(__always)
    public func index(before i: Index) -> Index {
        return i - 1
    }

    @inline(__always)
    public func index(after i: Index) -> Index {
        return i + 1
    }

    public var device: MTLDevice {
        self.raw.device
    }

    func reserveCapacity(_ minimumCapacity: Int) {
        if minimumCapacity < self.capacity {
            return
        }

        let memAlign = MemAlign<Element>(capacity: minimumCapacity)

        guard var new = RawGPUArray(device: self.device,
                                    memAlign: memAlign,
                                    options: self.raw.resourceOptions) else { fatalError() }
        new.label = self.label
        new.copyMemory(from: self.raw, count: self.count)

        self.raw = new
    }

    public func removeAll() {
        self.count = 0
    }

    public var label: String? {
        get {
            self.raw.label
        }
        set {
            self.raw.label = newValue
        }
    }

    public func append(_ newElement: Element) {
        reserveCapacity(self.count + 1)
        //        var a = [10]
        //        a.append(10)

        self.raw[self.count] = newElement
        count += 1

    }

    public func append<S>(contentsOf newElements: S) where Element == S.Element, S: Sequence {
        let underestimatedCount = newElements.underestimatedCount

        fatalError()
        //        a.append(contentsOf: [10])
    }

    func validate() -> Bool {
        self.raw.validate()
    }

    //    public func replaceSubrange<C: Collection>(_ subrange: Range<Index>, with newElements: C) where C.Iterator.Element == Element {
    //        /// adapted from https://github.com/apple/swift/blob/ea2f64cad218bb64a79afee41b77fe7bfc96cfd2/stdlib/public/core/ArrayBufferProtocol.swift#L140
    //        let newCount = Int(newElements.count)
    //
    //        let oldCount = self.count
    //        let eraseCount = subrange.count
    //
    //        let growth = newCount - eraseCount
    //        self.count = oldCount + growth
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
        self.raw.deinit()
    }
}

// extension GPUArray : Sequence {
//
//
//
//
//    public typealias Element = T
//
//    func makeIterator() -> some IteratorProtocol {
//        AnyIterator {
//
//        }
//    }
//
// }
//
// extension GPUArray : Collection {
//
// }

// not aware of count and such just capacity
struct RawGPUArray<Element> {
    typealias Index = Int

    fileprivate var memAlign: MemAlign<Element>
    fileprivate var buffer: MTLBuffer
    fileprivate var ptr: UnsafeMutableBufferPointer<Element>

    init?(device: MTLDevice,
          memAlign: MemAlign<Element>,
          options: MTLResourceOptions = []) {
        guard let buffer = device.makeBuffer(memAlign: memAlign, options: options) else { return nil }

        self.memAlign = memAlign
        self.buffer = buffer
        self.ptr = buffer.bindMemory(capacity: memAlign.capacity)
    }

    @inline(__always)
    subscript(index: Index) -> Element {
        get {
            return self.ptr[index]
        }
        set {
            self.ptr[index] = newValue
        }
    }

    func validate() -> Bool {
        self.buffer.length == self.memAlign.byteSize
    }

    //    private var id: Int {
    //        self.buffer.hash
    //    }

    func `deinit`() {
        self.buffer.setPurgeableState(.empty)
    }

    @inline(__always)
    var label: String? {
        get {
            self.buffer.label
        }
        set {
            self.buffer.label = newValue
        }
    }

    @inline(__always)
    var resourceOptions: MTLResourceOptions {
        self.buffer.resourceOptions
    }

    @inline(__always)
    var device: MTLDevice {
        self.buffer.device
    }

    @inline(__always)
    var capacity: Int {
        self.memAlign.capacity
    }

    @inline(__always)
    func copyMemory(from: RawGPUArray<Element>, count: Int) {
        self.ptr.copyMemory(from: from.ptr, count: count)
        // todo do i need this?
        self.buffer.didModifyRange(0..<count)
    }
}

extension UnsafeMutableBufferPointer {
    func copyMemory(from: Self, count: Int) {
        guard let to = self.baseAddress else { fatalError("to was nil") }
        guard let from = from.baseAddress else { fatalError("from was nil") }

        to.assign(from: from, count: count)
    }
}

extension MTLBuffer {
    func bindMemory<Element>(capacity: Int) -> UnsafeMutableBufferPointer<Element> {
        let start = self.contents().bindMemory(to: Element.self, capacity: capacity)
        return .init(start: start, count: capacity)
    }

    func bindUniformMemory<Element>() -> UnsafePointer<Element> {
        let start = self.contents().bindMemory(to: Element.self, capacity: 1)
        return UnsafePointer(start)
    }
}

extension MTLDevice {
    func makeBuffer<T>(memAlign: MemAlign<T>, options: MTLResourceOptions = []) -> MTLBuffer? {
        self.makeBuffer(length: memAlign.byteSize, options: options)
    }
}
