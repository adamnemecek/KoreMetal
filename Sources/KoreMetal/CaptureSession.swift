import Metal

public struct CaptureSession {
    let manager: MTLCaptureManager

    public init(device: MTLDevice) {
        let manager = MTLCaptureManager.shared()
        let desc = MTLCaptureDescriptor()
        desc.captureObject = device
        try! manager.startCapture(with: desc)
        self.manager = manager
    }

    public func stop() {
        self.manager.stopCapture()
    }
}
