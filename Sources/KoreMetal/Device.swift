
import Foundation
import Metal

final class Device {
    let device: MTLDevice

    private init(device: MTLDevice) {
        fatalError()
    }

    static let `default` = Device(device: MTLCreateSystemDefaultDevice()!)

    public private(set) var counter: Int

    func makeBuffer() {

    }
}
