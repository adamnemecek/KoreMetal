import XCTest
import MetalKit
@testable import KoreMetal

extension Sequence where Element == Int {
    func sum() -> Element {
        self.reduce(0, +)
    }
}

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
        
        XCTAssert(a.count == 3)
        XCTAssert(a.capacity == 1024)
        //        XCTAssert(MemoryLayout<Int>.size == 8)
        //        let z = a.byteLength()
        XCTAssert(a.validate())
        
        let z = Array(a)
        
        XCTAssert(z == [10, 20, 30])
    }
    
    func testAppendMultiple() {
        let device = MTLCreateSystemDefaultDevice()!
        //        let device = MTLCreateSystemDefaultDevice()!
        let v = Array(0..<4098)
        //
        guard var a = GPUArray<Int>(device: device, capacity: 1) else { fatalError() }
        a.append(contentsOf: v)
        print(a.count)
        XCTAssert(v.count == a.count)
        XCTAssertEqual(v.sum(),  a.sum())
        //
        
        
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

