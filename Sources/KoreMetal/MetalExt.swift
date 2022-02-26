import Metal

extension MTLRenderCommandEncoder {
    // todo: should these be stride as opposed to size?
    @inline(__always)
    public func setVertexValue<T>(
        _ value: T,
        index: Int
    ) {
        var value = value
        self.setVertexBytes(
            &value,
            length: MemoryLayout<T>.size,
            index: index
        )
    }

    @inline(__always)
    public func setFragmentValue<T>(
        _ value: T,
        index: Int
    ) {
        var value = value
        self.setFragmentBytes(
            &value,
            length: MemoryLayout<T>.size,
            index: index
        )
    }

    ///
    /// offset is in elements
    ///
    @inline(__always)
    public func setVertexArray<Element>(
        _ array: GPUArray<Element>,
        offset: Int,
        index: Int
    ) {
        self.setVertexBuffer(
            array.raw.buffer,
            offset: MemoryLayout<Element>.size * offset,
            index: index
        )
    }

    @inline(__always)
    public func setFragmentArray<Element>(
        _ array: GPUArray<Element>,
        offset: Int,
        index: Int
    ) {
        self.setFragmentBuffer(
            array.raw.buffer,
            offset: MemoryLayout<Element>.size * offset,
            index: index
        )
    }

    @inline(__always)
    public func setVertexUniforms<Element>(
        _ uniforms: GPUUniforms<Element>,
        index: Int
    ) {
        self.setVertexBuffer(
            uniforms.buffer,
            offset: 0,
            index: index
        )
    }

    @inline(__always)
    public func setFragmentUniforms<Element>(
        _ uniforms: GPUUniforms<Element>,
        index: Int
    ) {
        self.setFragmentBuffer(
            uniforms.buffer,
            offset: 0,
            index: index
        )
    }
}

extension MTLComputeCommandEncoder {
    @inline(__always)
    public func setArray<Element>(
        _ array: GPUArray<Element>,
        offset: Int,
        index: Int
    ) {
        self.setBuffer(
            array.raw.buffer,
            offset: MemoryLayout<Element>.size * offset,
            index: index
        )
    }

    @inline(__always)
    public func setUniforms<Element>(
        _ uniforms: GPUUniforms<Element>,
        index: Int
    ) {
        self.setBuffer(
            uniforms.buffer,
            offset: 0,
            index: index
        )
    }
}

///
/// internal
///

extension MTLDevice {
    @inline(__always)
    func makeBuffer<T>(memAlign: MemAlign<T>, options: MTLResourceOptions = []) -> MTLBuffer? {
        self.makeBuffer(length: memAlign.byteSize, options: options)
    }
}

extension MTLBuffer {
    @inline(__always)
    func bindMemory<Element>(capacity: Int) -> UnsafeMutableBufferPointer<Element> {
        let start = self.contents().bindMemory(to: Element.self, capacity: capacity)
        return .init(start: start, count: capacity)
    }

    @inline(__always)
    func bindUniformMemory<Element>() -> UnsafeMutablePointer<Element> {
        let start = self.contents().bindMemory(to: Element.self, capacity: 1)
        return UnsafeMutablePointer(start)
    }
}
