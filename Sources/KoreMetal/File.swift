//
//import Foundation
//import Combine
//
//
public final class AllocationCounter  {
    public private(set) var counter: Int
    public static let shared = AllocationCounter()

    private init() {
        counter = 0
    }

     func increment() {
        counter += 1
    }
}
