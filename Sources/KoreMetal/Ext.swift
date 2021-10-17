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
}
