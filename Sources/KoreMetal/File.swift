//
//import Foundation
//import Combine
//
//
public final class AllocationCounter  {
    public private(set) var counter: Int
    public static let shared = AllocationCounter()

    private init() {
        self.counter = 0
    }

     func increment() {
         self.counter += 1
    }
}
