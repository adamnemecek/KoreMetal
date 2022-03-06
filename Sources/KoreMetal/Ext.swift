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
