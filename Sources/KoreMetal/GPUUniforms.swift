import Metal

@propertyWrapper
public class GPUUniform<Element> {
    let buffer: MTLBuffer
    let memAlign: MemAlign<Element>
    var ptr: UnsafePointer<Element>

    public init?(device: MTLDevice,
                value: Element,
                options: MTLResourceOptions = []) {
        let memAlign = MemAlign<Element>(capacity: 1)
        guard let buffer = device.makeBuffer(memAlign: memAlign, options: options) else { return nil }
        self.buffer = buffer
        self.ptr = buffer.bindUniformMemory()
        self.memAlign = memAlign
    }

    public var wrappedValue: Element {
        get {
            fatalError()
        }
        set {
            fatalError()
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

}

extension GPUUniform where Element : Equatable {
    public static func ==(lhs: GPUUniform, rhs: GPUUniform) -> Bool {
        fatalError()
    }
}
