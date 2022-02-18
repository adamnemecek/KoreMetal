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

        XCTAssert(a.first == 10)
        XCTAssert(a.last == 30)
        
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

    func testRangeReplace() {
        let device = MTLCreateSystemDefaultDevice()!

        guard let a = GPUArray<Int>(device: device, capacity: 10) else { fatalError() }
        a.append(10)
        a.append(20)
        a.append(30)

        a.replaceSubrange(0..<2, with: [1,2,3,4])

        XCTAssert(a.elementsEqual([1, 2, 3, 30]))
    }

    func testSort() {
        let device = MTLCreateSystemDefaultDevice()!

        guard var a = GPUArray<Int>(device: device, capacity: 10) else { fatalError() }
        a.append(contentsOf: [20, 10, 30, 5])
        a.sort()
        XCTAssert(a.elementsEqual([5, 10, 20, 30]))
    }

//    func testRemoveAll() {
//        let device = MTLCreateSystemDefaultDevice()!
//
//        guard var a = GPUArray<Int>(device: device, capacity: 10) else { fatalError() }
//        a.append(contentsOf: [1,2,3,4,5])
//
//        var b = [1,2,3,4,5]
//        let z = b.partition { $0 > 3}
//        print(b, z)
////        print()
//
////        a.removeAll { $0 < 3 }
////        print(a.count)
//
////        for e in a {
////            print("here ", e)
////        }
//    }

    func testBoolArray() {
        let device = MTLCreateSystemDefaultDevice()!

        guard var a = GPUArray<Bool>(device: device, capacity: 16) else { fatalError() }

        a.append(contentsOf: repeatElement(false, count: 16))

        a[5] = true
        a[10] = true
        a[15] = true

//        for e in a.enumerated() {
//            print(e)
//        }
        for e in a.iterSetBits() {
            print(e)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

