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

    func testObserver() {
        let device = MTLCreateSystemDefaultDevice()!
        guard let a = GPUArray<Int>(device: device, capacity: 10) else { fatalError() }

        guard let b = GPUArray<Int>(device: device, capacity: 10) else { fatalError() }

//        let z = a.objectWillChange.sink { v in
//            print("realloc")
//        }

        a.append(contentsOf: 0..<1000)
        print(a.capacity)
    }
    
    func testAppendMultiple() {
        let device = MTLCreateSystemDefaultDevice()!
        //        let device = MTLCreateSystemDefaultDevice()!
        let v = Array(0..<10000)
        //
        guard var a = GPUArray<Int>(device: device, capacity: 1) else { fatalError() }
//        print(a.id)
        let idChanged = a.observeID {
            $0.append(contentsOf: v)
        }

//        print(a.id)
        print(idChanged)
//        print(a.count)
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

    func testRemoveAll() {
        let device = MTLCreateSystemDefaultDevice()!

        guard var a = GPUArray<Int>(device: device, capacity: 10) else { fatalError() }
        a.removeAll { $0 > 3 }
        XCTAssert(a.count == 0)
        a.append(contentsOf: [2, 1, 3, 6, 5, 4])

        a.removeAll { $0 > 3 }
        XCTAssert(a.count == 3)
        XCTAssert(a.elementsEqual([2, 1, 3]))
    }

    func testBoolArray() {
//        let device = MTLCreateSystemDefaultDevice()!
//
//        guard var a = GPUArray<Bool>(device: device, capacity: 16) else { fatalError() }
//
//        a.append(contentsOf: repeatElement(false, count: 16))
//
//        a[5] = true
//        a[10] = true
//        a[15] = true
//
////        for e in a.enumerated() {
////            print(e)
////        }
////        for e in a.iterSetBits() {
////            print(e)
////        }
    }

    func testEq() {
        let a = GPUArray([1,2,3,4])
        let b = GPUArray([1,2,3,4])
        let c = GPUArray([1,2,4])


        XCTAssert(a == b)
        XCTAssert(a != c)
//        XCTAssert(1 != 10)
    }


    func testAddArrays() {
        let a = GPUArray<Int>(0..<10)
        let b = GPUArray<Int>(0..<10)
    }


    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

