import Metal

//
// not aware of count and such just capacity
//
struct RawGPUArray<Element> {
    typealias Index = Int

    internal private(set) var memAlign: MemAlign<Element>
    internal private(set) var buffer: MTLBuffer
    internal fileprivate(set) var ptr: UnsafeMutableBufferPointer<Element>

    //    init(buffer: MTLBuffer) {
    //        fatalError()
    //    }

    init?(device: MTLDevice,
          memAlign: MemAlign<Element>,
          options: MTLResourceOptions = []
    ) {
        guard let buffer = device.makeBuffer(memAlign: memAlign, options: options) else { return nil }

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

    @inline(__always)
    func copyMemory(from: RawGPUArray<Element>, count: Int) {
        self.ptr.copyMemory(from: from.ptr, count: count)
        // todo: do i need this?
        //        self.buffer.didModifyRange(0..<count)
    }
}
