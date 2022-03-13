import Metal

extension MTLRenderCommandEncoder {
    @inline(__always) @inlinable
    public func drawRectangles(instanceCount: Int) {
        self.drawPrimitives(
            type: .triangleStrip,
            vertexStart: 0,
            vertexCount: 4,
            instanceCount: instanceCount
        )
    }
}

extension MTLIndirectRenderCommand {
    @inline(__always) @inlinable
    public func drawRectangles(
        instanceCount: Int,
        baseInstance: Int
    ) {
        self.drawPrimitives(
            .triangleStrip,
            vertexStart: 0,
            vertexCount: 4,
            instanceCount: instanceCount,
            baseInstance: baseInstance
        )
    }
}

extension MTLRenderCommandEncoder {
    // todo: should these be stride as opposed to size?
    @inline(__always) @inlinable
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

    @inline(__always) @inlinable
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
    @inline(__always) @inlinable
    public func setVertexArray<Element>(
        _ array: GPUArray<Element>,
        offset: Int,
        index: Int
    ) {
        self.setVertexBuffer(
            array._raw._buffer,
            offset: MemoryLayout<Element>.size * offset,
            index: index
        )
    }

    @inline(__always) @inlinable
    public func setFragmentArray<Element>(
        _ array: GPUArray<Element>,
        offset: Int,
        index: Int
    ) {
        self.setFragmentBuffer(
            array._raw._buffer,
            offset: MemoryLayout<Element>.size * offset,
            index: index
        )
    }

    @inline(__always) @inlinable
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

    @inline(__always) @inlinable
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
    @inline(__always) @inlinable
    public func setArray<Element>(
        _ array: GPUArray<Element>,
        offset: Int,
        index: Int
    ) {
        self.setBuffer(
            array._raw._buffer,
            offset: MemoryLayout<Element>.size * offset,
            index: index
        )
    }

    @inline(__always) @inlinable
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

extension MTLIndirectRenderCommand {
//    @inline(__always) @inlinable
//    public func setVertexValue<T>(
//        _ value: T,
//        index: Int
//    ) {
//        var value = value
//        self.setVertexBytes(
//            &value,
//            length: MemoryLayout<T>.size,
//            index: index
//        )
//    }
//
//    @inline(__always) @inlinable
//    public func setFragmentValue<T>(
//        _ value: T,
//        index: Int
//    ) {
//        var value = value
//        self.setFragmentBytes(
//            &value,
//            length: MemoryLayout<T>.size,
//            index: index
//        )
//    }

    ///
    /// offset is in elements
    ///
    @inline(__always) @inlinable
    public func setVertexArray<Element>(
        _ array: GPUArray<Element>,
        offset: Int,
        at index: Int
    ) {
        self.setVertexBuffer(
            array._raw._buffer,
            offset: MemoryLayout<Element>.size * offset,
            at: index
        )
    }

    @inline(__always) @inlinable
    public func setFragmentArray<Element>(
        _ array: GPUArray<Element>,
        offset: Int,
        at index: Int
    ) {
        self.setFragmentBuffer(
            array._raw._buffer,
            offset: MemoryLayout<Element>.size * offset,
            at: index
        )
    }

    @inline(__always) @inlinable
    public func setVertexUniforms<Element>(
        _ uniforms: GPUUniforms<Element>,
        at index: Int
    ) {
        self.setVertexBuffer(
            uniforms.buffer,
            offset: 0,
            at: index
        )
    }

    @inline(__always) @inlinable
    public func setFragmentUniforms<Element>(
        _ uniforms: GPUUniforms<Element>,
        at index: Int
    ) {
        self.setFragmentBuffer(
            uniforms.buffer,
            offset: 0,
            at: index
        )
    }
}

///
/// internal
///

extension MTLDevice {
    @inline(__always) @inlinable
    func makeBuffer<T>(memAlign: MemAlign<T>, options: MTLResourceOptions = []) -> MTLBuffer? {
        self.makeBuffer(length: memAlign.byteSize, options: options)
    }
}

extension MTLBuffer {
    @inline(__always) @inlinable
    func bindMemory<Element>(capacity: Int) -> UnsafeMutableBufferPointer<Element> {
        let start = self.contents().bindMemory(to: Element.self, capacity: capacity)
        return .init(start: start, count: capacity)
    }

    @inline(__always) @inlinable
    func bindUniformMemory<Element>() -> UnsafeMutablePointer<Element> {
        let start = self.contents().bindMemory(to: Element.self, capacity: 1)
        return UnsafeMutablePointer(start)
    }
}
