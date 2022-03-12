
/// this is for perf testing
public final class ArrayRef<Element> : Sequence, MutableCollection, RangeReplaceableCollection {
    var inner: ContiguousArray<Element>

    public init() {
        self.inner = []
    }

    public var startIndex: Int {
        self.inner.startIndex
    }

    public var endIndex: Int {
        self.inner.endIndex
    }

    public subscript(index: Int) -> Element {
        get {
            self.inner[index]
        }
        set {
            self.inner[index] = newValue
        }
    }

    public func index(after i: Int) -> Int {
        i + 1
    }

    public func append<S>(contentsOf newElements: S) where S : Sequence, Element == S.Element {
        self.inner.append(contentsOf: newElements)
    }

    public func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, Element == C.Element {
        self.inner.replaceSubrange(subrange, with: newElements)
    }
}


/// this is for perf comparisons
@_fixed_layout
public final class InlineArrayRef<Element> : Sequence, MutableCollection, RangeReplaceableCollection {
    @usableFromInline
    var inner: ContiguousArray<Element>


    @inline(__always) @inlinable
    public init() {
        self.inner = []
    }

    @inline(__always) @inlinable
    public var startIndex: Int {
        self.inner.startIndex
    }

    @inline(__always) @inlinable
    public var endIndex: Int {
        self.inner.endIndex
    }

    @inline(__always) @inlinable
    public subscript(index: Int) -> Element {
        get {
            self.inner[index]
        }
        set {
            self.inner[index] = newValue
        }
    }

    @inline(__always) @inlinable
    public func index(after i: Int) -> Int {
        i + 1
    }

    @inline(__always) @inlinable
    public func append<S>(contentsOf newElements: S) where S : Sequence, Element == S.Element {
        self.inner.append(contentsOf: newElements)
    }

    @inline(__always) @inlinable
    public func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, Element == C.Element {
        self.inner.replaceSubrange(subrange, with: newElements)
    }
}
