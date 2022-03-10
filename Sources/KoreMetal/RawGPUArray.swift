import Metal

extension UnsafeMutableBufferPointer: Identifiable {
    @inlinable @inline(__always)
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
    @usableFromInline
    typealias Index = Int

    @usableFromInline
    var id: Int {
        self._ptr.id
    }

    @usableFromInline
    internal var _memalign: MemAlign<Element>

    @usableFromInline
    internal var _buffer: MTLBuffer

    @usableFromInline
    internal var _device: MTLDevice
    // we cache the contents pointer since otherwise we'd have to call "contents()"
    // and invoke the cost of a obj-c dispatch
    @usableFromInline
    internal var _ptr: UnsafeMutableBufferPointer<Element>

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

        self._device = device
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


    @inline(__always) @inlinable
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

//    @inline(__always) @inlinable
    @usableFromInline
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

//    @usableFromInline
    @inline(__always) @inlinable
    var device: MTLDevice {
        self._device
    }

    @inline(__always) @inlinable
    var capacity: Int {
        self._memalign.capacity
    }
//
//    /// returns the new count of things
//    /// [1,2,3,4,5]
    @inline(__always) @inlinable
    mutating func removeAll(
        count: Int,
        where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows -> Int {
        try self._ptr[0..<count].halfStablePartition(
            isSuffixElement: shouldBeRemoved
        )
    }

    @inline(__always) @inlinable
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
//
//    mutating func reserveCapacity(_ minimumCapacity: Int) {
//        // check
//        let memAlign = MemAlign<Element>(capacity: capacity)
//
//        guard let new = self.device.makeBuffer(
//            memAlign: memAlign,
//            options: self.resourceOptions
//        ) else { fatalError() }
//
//
//        new.label = self.label
//        let newPtr: UnsafeMutableBufferPointer<Element> = new.bindMemory(capacity: capacity)
//
//        newPtr.copyMemory(from: self._ptr, count: <#T##Int#>)
//        self._memalign = memAlign
//        self._buffer = buffer
//        self._ptr = buffer.bindMemory(capacity: memAlign.capacity)
//    }


    func withUnsafeMTLBuffer<R>(
        _ body: (MTLBuffer) -> R
    ) -> R {
        body(self._buffer)
    }

    ///
    /// this takes a count since the entirety of the pointer is not valid
    ///
    @inlinable @inline(__always)
    func withUnsafeBufferPointer<R>(
        _ body: (UnsafeBufferPointer<Element>) throws -> R,
        count: Int
    ) rethrows -> R {
        try body(UnsafeBufferPointer(start: self._ptr.baseAddress!, count: count))
    }

    @inlinable @inline(__always)
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

extension RawGPUArray where Element: Equatable {
    @inline(__always) @inlinable
    func eq(_ other: Self, count: Int) -> Bool {
        self._ptr.eq(other._ptr, count: count)
    }
}

extension UnsafeMutableBufferPointer {
    ///
    /// this is ok since `gpuarray` won't contain classes but only `structs`
    ///
    @inline(__always) @inlinable
    func copyMemory(from: Self, count: Int) {
        guard let to = self.baseAddress else { fatalError("to was nil") }
        guard let from = from.baseAddress else { fatalError("from was nil") }

        to.assign(from: from, count: count)
    }
}


extension UnsafeMutableBufferPointer where Element: Equatable {
    @inline(__always) @inlinable
    func eq(_ other: UnsafeMutableBufferPointer, count: Int) -> Bool {
        guard var i = self.baseAddress,
              var j = other.baseAddress else { fatalError() }

        for _ in 0 ..< count {
            if i.pointee != j.pointee {
                return false
            }
            i = i.successor()
            j = j.successor()
        }

        return true
    }
}
