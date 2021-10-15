// based on ngrid14/gpuvec.rs
//// pub(crate)
//pub fn round_up(x: usize, to: usize) -> usize {
//    let m = x % to;
//    if m == 0 {
//        x
//    } else {
//        x - m + to
//    }
//}
//

func roundUp(x: Int, to: Int) -> Int {
    let m = x % to
    if m == 0 {
        return x
    } else {
        return x - m + to
    }
}

//// pub(crate)
//pub fn page_aligned(size: usize) -> usize {
//    round_up(size, 4096)
//}

func pageAligned(x: Int) -> Int {
    roundUp(x: x, to: 4096)
}

/////
///// `MemAlign` represents metadata for a page alligned allocation.
/////
//#[derive(PartialEq, Eq, Debug, Copy, Clone)]
//pub struct MemAlign<T> {
//    byte_size: usize,
//    capacity: usize,
//    remainder: usize,
//    phantom: std::marker::PhantomData<T>,
//}

public struct MemAlign<T> {
    let byteSize: Int
    let capacity: Int
    let remainder: Int
}

extension MemAlign {


    public static var elementSize: Int {
        MemoryLayout<T>.size
    }

    public static var elementString: Int {
        MemoryLayout<T>.stride
    }

    private func validate() -> Bool {
        Self.elementSize * self.capacity + self.remainder == self.byteSize
//        let pageAligned = self.byteSize % 4096 == 0
//        return sizeMatch && pageAligned
    }

//    private init(byteSize: Int, capacity: Int, remainder: Int) {
//        self.byteSize = byteSize
//        self.capacity = capacity
//        self.remainder = remainder
//    }

    public init(capacity: Int) {
        let elementSize = Self.elementSize
        let size = elementSize * capacity
        //
        let byteSize = pageAligned(x: size)
        let remainder = byteSize % elementSize

        assert((byteSize - remainder) % elementSize == 0)
        let capacity = (byteSize - remainder) / elementSize
        assert(byteSize != 0)

        self.byteSize = byteSize
        self.capacity = capacity
        self.remainder = remainder

        assert(validate())
    }
}
//
//impl<T> MemAlign<T> {
//    pub fn element_size() -> usize {
//        std::mem::size_of::<T>()
//    }
//
//    pub fn byte_size(&self) -> usize {
//        self.byte_size
//    }
//
//    /// Capacity in instances
//    pub fn capacity(&self) -> usize {
//        self.capacity
//    }
//
//    /// remainder in bytes
//    pub fn remainder(&self) -> usize {
//        self.remainder
//    }
//
//    pub fn is_valid(&self) -> bool {
//        (Self::element_size() * self.capacity) + self.remainder == self.byte_size
//    }
//
//    pub fn new(capacity: usize) -> Self {
//        let element_size = Self::element_size();
//        assert!(element_size != 0, "ZST are not supported");
//        let size = element_size * capacity;
//
//        let byte_size = page_aligned(size);
//        let remainder = byte_size % element_size;
//        assert!((byte_size - remainder) % element_size == 0);
//        let capacity = (byte_size - remainder) / element_size;
//        assert!(byte_size != 0);
//
//        Self {
//            byte_size,
//            capacity,
//            remainder,
//            phantom: Default::default(),
//        }
//    }
//}
//
//
//#[test]
//fn test_roundup() {
//    // assert!(round_up(0, 4096) == 4096);
//    // println!("{}", round_up(0, 4096));
//    assert!(round_up(1, 4096) == 4096);
//    assert!(round_up(4095, 4096) == 4096);
//    assert!(round_up(4096, 4096) == 4096);
//    assert!(round_up(4097, 4096) == 2 * 4096);
//    assert!(round_up(2 * 4096 + 1, 4096) == 3 * 4096);
//}


//
//#[test]
//fn test_paged_alloc() {
//    #[repr(C)]
//    struct TestStruct {
//        data: [u8; 18],
//    }
//
//    let element_size: usize = std::mem::size_of::<TestStruct>();
//    assert!(element_size == 18);
//    let count = 10;
//    // let page_size = 4096;
//    let alloc = MemAlign::<TestStruct>::new(count);
//    assert!(alloc.capacity() == 227);
//    assert!(alloc.remainder() == 10);
//    assert!(alloc.byte_size() == 4096);
//    // println!("{}", alloc.is_valid());
//
//    // dbg!("{}", alloc);
//}

