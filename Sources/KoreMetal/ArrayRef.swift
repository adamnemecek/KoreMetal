
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
