import Metal

extension UnsafeMutableBufferPointer: Identifiable {
    public var id: Int {
        Int(bitPattern: self.baseAddress)
    }
}



//
// not aware of count and such just capacity
//
@frozen
@usableFromInline
internal struct RawGPUArray<Element>: Identifiable {
    typealias Index = Int

    @usableFromInline
    var id: Int {
        self._ptr.id
    }

    internal var _memalign: MemAlign<Element>
    internal var _buffer: MTLBuffer
    // we cache the contents pointer since otherwise we'd have to call "contents()"
    // and invoke the cost of a obj-c dispatch
    internal fileprivate(set) var _ptr: UnsafeMutableBufferPointer<Element>

    init?(
        device: MTLDevice,
        capacity: Int,
        options: MTLResourceOptions = []
    ) {
        let memAlign = MemAlign<Element>(capacity: capacity)

        guard let buffer = device.makeBuffer(
            memAlign: memAlign,
            options: options
        ) else { return nil }

        self._memalign = memAlign
        self._buffer = buffer
        self._ptr = buffer.bindMemory(capacity: memAlign.capacity)
    }

    init?(
        capacity: Int,
        options: MTLResourceOptions = []
    ) {
        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
        self.init(device: device, capacity: capacity, options: options)
    }


//    init?<S>(
//        device: MTLDevice,
//        _ elements: S,
//        options: MTLResourceOptions = []
//    ) where S: Sequence, S.Element == Element {
//        self.init(device: device, capacity: elements.underestimatedCount, options: options)
//
////        self.
//    }


    @inline(__always)
    subscript(index: Index) -> Element {
        get {
            assert(index < self._memalign.capacity)
            return self._ptr[index]
        }
        set {
            assert(index < self._memalign.capacity)
            self._ptr[index] = newValue
        }
    }

    func validate() -> Bool {
        self._buffer.length == self._memalign.byteSize
    }

    //    private var id: Int {
    //        self.buffer.hash
    //    }

    func `deinit`() {
        self._buffer.setPurgeableState(.empty)
    }

    @inline(__always)
    var label: String? {
        get {
            self._buffer.label
        }
        set {
            self._buffer.label = newValue
        }
    }

    @inline(__always)
    var resourceOptions: MTLResourceOptions {
        self._buffer.resourceOptions
    }

    @inline(__always)
    var device: MTLDevice {
        self._buffer.device
    }

    @inline(__always)
    var capacity: Int {
        self._memalign.capacity
    }
//
//    /// returns the new count of things
//    /// [1,2,3,4,5]
    mutating func removeAll(
        count: Int,
        where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows -> Int {
        try self._ptr[0..<count].halfStablePartition(
            isSuffixElement: shouldBeRemoved
        )
    }

    @inline(__always)
    func copyMemory(from: RawGPUArray<Element>, count: Int) {
        self._ptr.copyMemory(from: from._ptr, count: count)
        // todo: do i need this?
        // self.buffer.didModifyRange(0..<count)
    }

//    @inline(__always)
//    func compareMemory(_ other: RawGPUArray<Element>, count: Int) {
//
//        self.ptr
//        fatalError()
//    }

    func withUnsafeMTLBuffer<R>(
        _ body: (MTLBuffer) -> R
    ) -> R {
        body(self._buffer)
    }

    ///
    /// this takes a count since the entirety of the pointer is not valid
    ///
    @inline(__always)
    func withUnsafeBufferPointer<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R,
        count: Int
    ) rethrows -> R {
        try body(UnsafeBufferPointer(start: self._ptr.baseAddress!, count: count))
    }

    @inline(__always)
    func withUnsafeMutableBufferPointer<R>(
        _ body: (UnsafeMutableBufferPointer<Element>) throws -> R,
        count: Int
    ) rethrows -> R {
        try body(UnsafeMutableBufferPointer(start: self._ptr.baseAddress!, count: count))
    }
}

// extension UnsafeBufferPointer {
//    func compareMemory(_ other: Self) -> Bool {
//        let z = self[0..<count]
//        return true
////        memcmp(self.baseAddress, other, MemoryLayout<Element>.size * count) == 0
//    }
//
//    func compareMemory(_ other: Self, count: Int) -> Bool {
//        self[0..<count].compareMemory(other[0..<count])
//    }
// }

extension UnsafeMutableBufferPointer {
    ///
    /// this is ok since `gpuarray` won't contain classes but only `structs`
    ///
    func copyMemory(from: Self, count: Int) {
        guard let to = self.baseAddress else { fatalError("to was nil") }
        guard let from = from.baseAddress else { fatalError("from was nil") }

        to.assign(from: from, count: count)
    }
}
