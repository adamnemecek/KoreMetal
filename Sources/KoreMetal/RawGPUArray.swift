import Metal

extension UnsafeMutableBufferPointer : Identifiable {
    public var id: Int {
        Int(bitPattern: self.baseAddress)
    }
}
//
// not aware of count and such just capacity
//
struct RawGPUArray<Element> : Identifiable {
    typealias Index = Int

    var id: Int {
        self.ptr.id
    }

    internal private(set) var memAlign: MemAlign<Element>
    internal private(set) var buffer: MTLBuffer
    internal fileprivate(set) var ptr: UnsafeMutableBufferPointer<Element>

    init?(device: MTLDevice,
          memAlign: MemAlign<Element>,
          options: MTLResourceOptions = []
    ) {
        guard let buffer = device.makeBuffer(memAlign: memAlign, options: options) else { return nil }

        self.memAlign = memAlign
        self.buffer = buffer
        self.ptr = buffer.bindMemory(capacity: memAlign.capacity)
    }

    init?(
        device: MTLDevice,
        capacity: Int,
        options: MTLResourceOptions = []) {
        let memAlign = MemAlign<Element>(capacity: capacity)
        self.init(
            device: device,
            memAlign: memAlign,
            options: options
        )
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
}
