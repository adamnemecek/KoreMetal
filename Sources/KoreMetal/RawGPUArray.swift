import Metal

extension UnsafeMutableBufferPointer: Identifiable {
    public var id: Int {
        Int(bitPattern: self.baseAddress)
    }
}

//
// not aware of count and such just capacity
//
struct RawGPUArray<Element>: Identifiable {
    typealias Index = Int

    var id: Int {
        self.ptr.id
    }

    /// checks if the element is a class
    @inline(__always)
    static var isClass: Bool {
        Element.self is AnyObject.Type
    }

    @inline(__always)
    static var isStruct: Bool {
        !isClass
    }

    internal private(set) var memAlign: MemAlign<Element>
    internal private(set) var buffer: MTLBuffer
    // we cache the contents pointer since otherwise we'd have to call "contents()"
    // and invoke the cost of a obj-c dispatch
    internal fileprivate(set) var ptr: UnsafeMutableBufferPointer<Element>

    init?(
        device: MTLDevice,
        capacity: Int,
        options: MTLResourceOptions = []
    ) {
        assert(Self.isStruct)

        let memAlign = MemAlign<Element>(capacity: capacity)

        guard let buffer = device.makeBuffer(
            memAlign: memAlign,
            options: options
        ) else { return nil }

        self.memAlign = memAlign
        self.buffer = buffer
        self.ptr = buffer.bindMemory(capacity: memAlign.capacity)
    }

    @inline(__always)
    subscript(index: Index) -> Element {
        get {
            assert(index < self.memAlign.capacity)
            return self.ptr[index]
        }
        set {
            assert(index < self.memAlign.capacity)
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
//
//    /// returns the new count of things
//    /// [1,2,3,4,5]
    public mutating func removeAll(
        count: Int,
        where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows -> Int {
        try self.ptr[0..<count].halfStablePartition(
            isSuffixElement: shouldBeRemoved
        )
    }

    @inline(__always)
    func copyMemory(from: RawGPUArray<Element>, count: Int) {
        self.ptr.copyMemory(from: from.ptr, count: count)
        // todo: do i need this?
        // self.buffer.didModifyRange(0..<count)
    }

    @inline(__always)
    public func withUnsafeBufferPointer<R>(
        _ body: (UnsafeBufferPointer<Element>
    ) throws -> R) rethrows -> R {
        try body(UnsafeBufferPointer(self.ptr))
    }

    @inline(__always)
    public func withUnsafeMutableBufferPointer<R>(
        _ body: (UnsafeMutableBufferPointer<Element>
    ) throws -> R) rethrows -> R {
        try body(self.ptr)
    }
}
