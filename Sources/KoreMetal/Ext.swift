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

    @inlinable @inline(__always)
    public func makeGPUArray<T>(capacity: Int, options: MTLResourceOptions = []) -> GPUArray<T>? {
        GPUArray(device: self, capacity: capacity, options: options)
    }

    @inlinable @inline(__always)
    public func makeGPUArray<T, S>(_ seq: S, options: MTLResourceOptions = []) -> GPUArray<T>? where S: Sequence, S.Element == T {
//        GPUArray(device: self, capacity: capacity, options: options)
        fatalError()    
    }

    @inlinable @inline(__always)
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

extension MTLSize {
    init(width: Int, height: Int, depth: Int) {
        fatalError()
    }
}

extension MTLTextureDescriptor {
    @inlinable @inline(__always)
    public class func texture2DDescriptor(
        pixelFormat: MTLPixelFormat,
        width: Int,
        height: Int,
        mipmapped: Bool,
        usage: MTLTextureUsage
    ) -> MTLTextureDescriptor {
        let desc = Self.texture2DDescriptor(
            pixelFormat: pixelFormat,
            width: width,
            height: height,
            mipmapped: mipmapped
        )
        desc.usage = usage
        return desc
    }
}

//
//extension MTLTexture {
//    @inlinable @inline(__always)
//    public func resize(width: Int, height: Int) {
////        let desc = MTLTextureDescriptor
//
//        self = self.device.makeTexture(descriptor: .texture2DDescriptor(
//            pixelFormat: self.pixelFormat,
//            width: width,
//            height: height,
//            mipmapped: self.mipmapLevelCount != 0
//        ))
//        fatalError()
//    }
//}
