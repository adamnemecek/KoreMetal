import XCTest
import MetalKit
@testable import KoreMetal

class GPUUniformsTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppend() throws {
//

//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//
        struct Uniforms : Equatable {
            let a: Int
            let b: Int
        }
        let device = MTLCreateSystemDefaultDevice()!
//
        let u1 = Uniforms(a: 10, b: 10)

        let g = GPUUniforms(device: device, value: u1)!

        XCTAssert(g.wrappedValue == u1)

        let u2 = Uniforms(a: 40, b: 100)

        g.wrappedValue = u2

        XCTAssert(g.wrappedValue == u2)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

