import MetalKit

extension MTLRenderCommandEncoder {
    // todo: should these be stride as opposed to size?
    public func setVertexValue<T>(_ value: T, index: Int) {
        var value = value
        self.setVertexBytes(&value, length: MemoryLayout<T>.size, index: index)
    }

    public func setFragmentValue<T>(_ value: T, index: Int) {
        var value = value
        self.setFragmentBytes(&value, length: MemoryLayout<T>.size, index: index)
    }

    public func setVertexArray<Element>(_ array: GPUArray<Element>, offset: Int, index: Int) {
        self.setVertexBuffer(array.raw.buffer, offset: offset, index: index)
    }

    public func setFragmentArray<Element>(_ array: GPUArray<Element>, offset: Int, index: Int) {
        self.setFragmentBuffer(array.raw.buffer, offset: offset, index: index)
    }
}

extension MTLComputeCommandEncoder {
    public func setArray<Element>(_ array: GPUArray<Element>, offset: Int, index: Int) {
        self.setBuffer(array.raw.buffer, offset: offset, index: index)
    }
}
