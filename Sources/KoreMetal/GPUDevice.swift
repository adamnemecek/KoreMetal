import Foundation
import Metal

public protocol GPUDevice {
    func makeBuffer<T>(
        memAlign: MemAlign<T>,
        options: MTLResourceOptions
    ) -> MTLBuffer?
}


final class MetalDevice : GPUDevice {
    let device: MTLDevice

    init(device: MTLDevice) {
        self.device = device
    }

    func makeBuffer<T>(
        memAlign: MemAlign<T>,
        options: MTLResourceOptions = []
    ) -> MTLBuffer? {
        self.device.makeBuffer(memAlign: memAlign, options: options)
    }
}
