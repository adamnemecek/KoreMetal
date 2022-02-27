import XCTest
@testable import KoreMetal

class MemAlignTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRoundUp() {

        XCTAssert(1.roundUp(to: 4096) == 4096)
        XCTAssert(4095.roundUp(to: 4096) == 4096)
        XCTAssert(4096.roundUp(to: 4096) == 4096)
        XCTAssert(4097.roundUp(to: 4096) == 2 * 4096)
        XCTAssert((2 * 4096 + 1).roundUp(to: 4096) == 3 * 4096)
    }

    func testMemAlign() throws {

        // 18 fields
        struct TestStruct {
            let a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r: UInt8
        }


        let memAlign = MemAlign<TestStruct>(capacity: 10)
        let elSize = MemAlign<TestStruct>.elementSize

        XCTAssert(elSize == 18)
        print(memAlign)

        XCTAssert(memAlign.capacity == 227)
        XCTAssert(memAlign.remainder == 10)
        XCTAssert(memAlign.byteSize == 4096)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
