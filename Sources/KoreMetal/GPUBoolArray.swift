import MetalKit
import Ext

let BITSIZE = MemoryLayout<UInt64>.bitSize

public final class GPUBitArray {
    private var inner: GPUArray<UInt64>


    init?(device: MTLDevice, capacity: Int) {
        self.inner = GPUArray(device: device, capacity: capacity)!
    }

    subscript(index: Int) -> Bool {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
}
