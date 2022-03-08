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

extension MTLDevice {
//    @inline(__always)
//    public static var `default`: MTLDevice? {
//        MTLCreateSystemDefaultDevice()
//    }

    @inline(__always)
    public func makeGPUArray<T>(capacity: Int, options: MTLResourceOptions = []) -> GPUArray<T>? {
        GPUArray(device: self, capacity: capacity, options: options)
    }

    @inline(__always)
    public func makeGPUUniforms<T>(value: T, options: MTLResourceOptions) -> GPUUniforms<T>? {
        GPUUniforms(device: self, value: value, options: options)
    }
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
