import MetalKit
import Ext

//let BITSIZE = MemoryLayout<UInt64>.bitSize

public final class GPUBitArray<T: UnsignedInteger & FixedWidthInteger> {
    private var inner: GPUArray<T>


    init?(
        device: MTLDevice,
        capacity: Int
    ) {
        self.inner = GPUArray(device: device, capacity: capacity)!
    }

    subscript(index: Int) -> Bool {
        get {
//            self.inner.
            fatalError()
        }
        set {
            fatalError()
        }
    }


}
