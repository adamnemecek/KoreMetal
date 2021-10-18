import MetalKit

extension MTLRenderCommandEncoder {
    // todo: should these be stride as opposed to size?
    public func setVertexValue<T>(value: T, index: Int) {
        var value = value
        self.setVertexBytes(&value, length: MemoryLayout<T>.size, index: index)
    }

    public func setFragmentValue<T>(value: T, index: Int) {
        var value = value
        self.setFragmentBytes(&value, length: MemoryLayout<T>.size, index: index)
    }

    public func setVertexArray<Element>(array: GPUArray<Element>, offset: Int, index: Int) {
        self.setVertexBuffer(array.raw.buffer, offset: offset, index: index)
    }

    public func setFragmentArray<Element>(array: GPUArray<Element>, offset: Int, index: Int) {
        self.setFragmentBuffer(array.raw.buffer, offset: offset, index: index)
    }
}
