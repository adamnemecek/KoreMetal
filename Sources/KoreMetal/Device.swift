
import Foundation
import Metal

public final class Device {
    public let device: MTLDevice
    public private(set) var count: Int

    private init(device: MTLDevice) {
//        self.d
        fatalError()
    }

    static let `default` = Device(device: MTLCreateSystemDefaultDevice()!)

//    static var current =


    func makeBuffer() {

    }
}
