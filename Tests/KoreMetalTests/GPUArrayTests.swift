import XCTest
import MetalKit
@testable import KoreMetal

class GPUArrayTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppend() throws {

        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let device = MTLCreateSystemDefaultDevice()!

        guard let a = GPUArray<Int>(device: device, capacity: 10) else { fatalError() }
        a.append(10)
        a.append(20)
        a.append(30)
//        print(a[0])
        XCTAssert(a[0] == 10)
        XCTAssert(a[1] == 20)
        XCTAssert(a[2] == 30)

        a.reserveCapacity(1000)

        XCTAssert(a[0] == 10)
        XCTAssert(a[1] == 20)
        XCTAssert(a[2] == 30)

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

