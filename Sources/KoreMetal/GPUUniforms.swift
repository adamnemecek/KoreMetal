import Metal

//@propertyWrapper
public class GPUUniforms<Element> {
    internal let buffer: MTLBuffer
    private let memAlign: MemAlign<Element>
    private var ptr: UnsafeMutablePointer<Element>

    public init?(device: MTLDevice,
                value: Element,
                options: MTLResourceOptions = []) {
        let memAlign = MemAlign<Element>(capacity: 1)
        guard let buffer = device.makeBuffer(memAlign: memAlign, options: options) else { return nil }

        self.buffer = buffer
        self.ptr = buffer.bindUniformMemory()
        self.memAlign = memAlign

//        self.wrappedValue = value
    }

    public var wrappedValue: Element {
        get {
            self.ptr.pointee
        }
        set {
            self.ptr.pointee = newValue
        }
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

    deinit {
        self.buffer.setPurgeableState(.empty)
    }

}

extension GPUUniforms where Element: Equatable {
    public static func ==(lhs: GPUUniforms, rhs: GPUUniforms) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}
