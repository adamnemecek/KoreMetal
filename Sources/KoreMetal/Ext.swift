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

extension MutableCollection {
    @inlinable
    public mutating func halfStablePartition(
        isSuffixElement: (Element) throws -> Bool
    ) rethrows -> Index {
        guard var i = try firstIndex(where: isSuffixElement)
        else { return endIndex }

        var j = index(after: i)
        while j != endIndex {
            if try !isSuffixElement(self[j]) {
                swapAt(i, j)
                formIndex(after: &i)
            }
            formIndex(after: &j)
        }
        return i
    }
}

//setFragmentBuffers
//setVertexBuffers

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

extension MTLRenderCommandEncoder {
    // todo: should these be stride as opposed to size?
    public func setVertexValue<T>(
        _ value: T,
        index: Int
    ) {
        var value = value
        self.setVertexBytes(&value, length: MemoryLayout<T>.size, index: index)
    }

    public func setFragmentValue<T>(
        _ value: T,
        index: Int
    ) {
        var value = value
        self.setFragmentBytes(&value, length: MemoryLayout<T>.size, index: index)
    }

    public func setVertexArray<Element>(
        _ array: GPUArray<Element>,
        offset: Int,
        index: Int
    ) {
        self.setVertexBuffer(array.raw.buffer, offset: offset, index: index)
    }

    public func setFragmentArray<Element>(
        _ array: GPUArray<Element>,
        offset: Int,
        index: Int
    ) {
        self.setFragmentBuffer(array.raw.buffer, offset: offset, index: index)
    }

    public func setVertexUniforms<Element>(
        _ uniforms: GPUUniforms<Element>,
        index: Int
    ) {
        self.setVertexBuffer(uniforms.buffer, offset: 0, index: index)
    }

    public func setFragmentUniforms<Element>(
        _ uniforms: GPUUniforms<Element>,
        index: Int
    ) {
        self.setFragmentBuffer(uniforms.buffer, offset: 0, index: index)
    }
}

extension MTLComputeCommandEncoder {
    public func setArray<Element>(
        _ array: GPUArray<Element>,
        offset: Int,
        index: Int
    ) {
        self.setBuffer(array.raw.buffer, offset: offset, index: index)
    }

    public func setUniforms<Element>(
        _ uniforms: GPUUniforms<Element>,
        index: Int
    ) {
        self.setBuffer(uniforms.buffer, offset: 0, index: index)
    }
}
