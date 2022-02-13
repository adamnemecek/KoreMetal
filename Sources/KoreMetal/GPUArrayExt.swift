
extension GPUArray where Element == Bool {
    public func iterSetBits() -> AnyIterator<Int> {
        self.raw.iterSetBits()
    }
}

extension RawGPUArray where Element == Bool {
    func iterSetBits() -> AnyIterator<Int> {
        let blockSize = MemoryLayout<UInt64>.size
        let byteSize = self.memAlign.byteSize
        let capacity = byteSize / blockSize
        assert(byteSize % blockSize == 0)
        let ptr = self.ptr.baseAddress!.withMemoryRebound(to: UInt64.self, capacity: capacity) { ptr in
            ptr
        }

        var i = 0
        var currentBlock: UInt64 = 0
        var leading = 0

        return AnyIterator {
            guard i < capacity else { return nil }
            while currentBlock == 0 {
                currentBlock = ptr.advanced(by: i).pointee
                i += 1
                leading += blockSize
            }
            return leading + currentBlock.leadingZeroBitCount

        }
    }
}
