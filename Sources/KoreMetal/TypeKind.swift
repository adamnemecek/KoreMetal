

public enum TypeKind<Element>: Equatable, Comparable, Hashable {
    case `struct`
    case `class`
}

extension TypeKind {
    public init() {
        if Self.isClass {
            self = .`class`
        } else {
            self = .`struct`
        }
    }

    public static var isClass: Bool {
        Element.self is AnyObject.Type
    }

    public static var isStruct: Bool {
        !isClass
    }
}


