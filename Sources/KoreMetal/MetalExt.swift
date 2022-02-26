import Metal

extension MTLDevice {
    func makeBuffer<T>(memAlign: MemAlign<T>, options: MTLResourceOptions = []) -> MTLBuffer? {
        self.makeBuffer(length: memAlign.byteSize, options: options)
    }
}

extension MTLBuffer {
    func bindMemory<Element>(capacity: Int) -> UnsafeMutableBufferPointer<Element> {
        let start = self.contents().bindMemory(to: Element.self, capacity: capacity)
        return .init(start: start, count: capacity)
    }

    func bindUniformMemory<Element>() -> UnsafeMutablePointer<Element> {
        let start = self.contents().bindMemory(to: Element.self, capacity: 1)
        return UnsafeMutablePointer(start)
    }
}
