import Foundation
import SweetUI


final class RootObject: Equatable, CustomDebugStringConvertible {

    @Binding var childObject: ChildObject
    @Binding var optionalChildObject: ChildObject?

    @Binding private(set) var intBinding: Int?
    @Published private(set) var intPublished: Int?

    var int: Int? {
        get { intPublished }
        set { intBinding = newValue; intPublished = newValue }
    }

    init(childObject: ChildObject) {
        self.childObject = childObject
    }

    static func ==(lhs: RootObject, rhs: RootObject) -> Bool {
        return lhs === rhs
    }

    var debugDescription: String {
        """
        \(Self.self) - \(ObjectIdentifier(self)):
        - childObject: \(ObjectIdentifier(childObject))
        - optionalChildObject: \(optionalChildObject.flatMap { "\(ObjectIdentifier($0))" } ?? "<nil>")
        - int: \(int.flatMap { $0.description } ?? "<nil>")
        """
    }
}


final class ChildObject: Equatable {

    @Binding var rootValue: RootValue?
    @Binding var childValue: ChildValue?

    @Binding private(set) var doubleBinding: Double?
    @Published private(set) var doublePublished: Double?

    var double: Double? {
        get { doublePublished }
        set { doublePublished = newValue; doubleBinding = newValue }
    }

    init(double: Double, rootValue: RootValue?) {
        self.doubleBinding = double
        self.doublePublished = double
        self.rootValue = rootValue
    }

    static func ==(lhs: ChildObject, rhs: ChildObject) -> Bool {
        return lhs === rhs
    }

}


struct RootValue: Equatable {
    var text: String
    var optionalText: String?

    var childValue: ChildValue
    var optionalChildValue: ChildValue?
}


struct ChildValue: Equatable {
    var text: String
    var optionalText: String?

    var texts: [String]
    var optionalTexts: [String]?
}
