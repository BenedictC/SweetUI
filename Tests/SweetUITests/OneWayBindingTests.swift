import XCTest
@testable import SweetUI
@preconcurrency import Combine


@MainActor
final class OneWayBindingTests: XCTestCase { }


// MARK: - Inits

extension OneWayBindingTests {

    func testInitWithPublisher() async throws {
        // Given
        let value1 = 1.0
        let object = ChildObject(double: value1, rootValue: nil)
        let publisher = object.$doublePublished
        let binding = OneWayBinding(publisher: publisher, get: { object.doublePublished })
        let collector = BindingCollector(binding: binding)

        // Then
        XCTAssertEqual(binding.value, value1)
        XCTAssertEqual(collector.collectedValues, [value1])

        // When
        let value2 = 200.0
        object.double = value2
        // Then
        XCTAssertEqual(binding.value, value2)
        XCTAssertEqual(collector.collectedValues, [value1, value2])
    }

    func testInitJust() async throws {
        // Given
        let value1 = -1.0
        let object = ChildObject(double: value1, rootValue: nil)
        let binding = OneWayBinding(wrappedValue: object.doubleBinding)
        let collector = BindingCollector(binding: binding)

        // Then
        XCTAssertEqual(binding.value, value1)
        XCTAssertEqual(collector.collectedValues, [value1])
    }

    func testInitCurrentValueSubject() async throws {
        // Given
        let value1 = 1.0
        let currentValueSubject = CurrentValueSubject<Double, Never>(value1)
        let binding = OneWayBinding(currentValueSubject: currentValueSubject)
        let collector = BindingCollector(binding: binding)

        // Then
        XCTAssertEqual(binding.value, value1)
        XCTAssertEqual(collector.collectedValues, [value1])

        // When
        let value2 = 200.0
        currentValueSubject.send(value2)
        // Then
        XCTAssertEqual(binding.value, value2)
        XCTAssertEqual(collector.collectedValues, [value1, value2])
    }
}


// MARK: - AnySubject extensions

extension OneWayBindingTests {

    func testPublisherMakeOneWayBindingWithPassthroughSubject() {
        // Given
        let subject = PassthroughSubject<Double, Never>()
        let value1 = 0.0
        let binding = subject.makeOneWayBinding(initialValue: value1)
        let collector = BindingCollector(binding: binding)

        // Then
        XCTAssertEqual(collector.collectedValues, []) // This is surprising but expected
        XCTAssertEqual(binding.value, value1)

        // When
        let value2 = 1.0
        subject.send(value2)
        // Then
        XCTAssertEqual(collector.collectedValues, [value2])
        XCTAssertEqual(binding.value, value2)
    }

    func testPublisherMakeOneWayBindingWithPublished() {
        // Given
        let value1 = 0.0
        let object = ChildObject(double: value1, rootValue: nil)
        let binding = object.$doublePublished.makeOneWayBinding(initialValue: value1)
        let collector = BindingCollector(binding: binding)

        // Then
        XCTAssertEqual(collector.collectedValues, [value1])
        XCTAssertEqual(binding.value, value1)

        // When
        let value2 = 1.0
        object.double = value2
        // Then
        XCTAssertEqual(collector.collectedValues, [value1, value2])
        XCTAssertEqual(binding.value, value2)
    }
}


// MARK: - Concurrency

extension OneWayBindingTests {

    func testValueSentFromBackgroundIsBouncedToMainThread() async throws {
        let value1 = 0.0
        let subject = CurrentValueSubject<Double, Never>(value1)
        let binding = subject.makeOneWayBinding()
        let collector = BindingCollector(binding: binding)

        // Then
        XCTAssertEqual(collector.collectedValues, [value1])
        XCTAssertEqual(binding.value, value1)

        // When
        let value2 = 1.0
        DispatchQueue.global().sync {
            subject.send(value2)
        }
        // Then
        XCTAssertEqual(binding.value, value2)
        XCTAssertEqual(collector.collected, [.make(value1, true), .make(value2, true)])
    }

    func testValueSentFromBackgroundIsNotBouncedToMainThread() throws {
        let value1 = 0.0
        let subject = CurrentValueSubject<Double, Never>(value1)
        let binding = subject.makeOneWayBinding(options: [])
        let collector = BindingCollector(binding: binding)

        // Then
        XCTAssertEqual(collector.collectedValues, [value1])
        XCTAssertEqual(binding.value, value1)

        // When
        let value2 = 1.0
        let expectation = expectation(description: "value sent off main thread")
        DispatchQueue.global(qos: .background).async {
            XCTAssert(!Thread.isMainThread)
            subject.send(value2)
            expectation.fulfill()
        }
        wait(for: [expectation])

        // Then
        XCTAssertEqual(binding.value, value2)
        XCTAssertEqual(collector.collected, [.make(value1, true), .make(value2, false)])
    }
}


// MARK: - Duplicate dropping

extension OneWayBindingTests {

    func testDoDropDuplicatesWithEquatableType() {
        // Given
        let value1 = 1.0
        let object = ChildObject(double: value1, rootValue: nil)
        let publisher = object.$doublePublished
        let binding = OneWayBinding(publisher: publisher, get: { object.doubleBinding }, options: [.dropDuplicates])
        let collector = BindingCollector(binding: binding)

        // Then
        XCTAssertEqual(binding.value, value1)
        XCTAssertEqual(collector.collectedValues, [value1])

        // When
        let value2 = value1
        object.double = value2
        // Then
        XCTAssertEqual(binding.value, value2)
        XCTAssertEqual(collector.collectedValues, [value1])
    }

    func testDoNotDropDuplicatesWithEquatableType() {
        // Given
        let value1 = 1.0
        let object = ChildObject(double: value1, rootValue: nil)
        let publisher = object.$doublePublished
        let binding = OneWayBinding(publisher: publisher, get: { object.doublePublished }, options: [])
        let collector = BindingCollector(binding: binding)

        // Then
        XCTAssertEqual(binding.value, value1)
        XCTAssertEqual(collector.collectedValues, [value1])

        // When
        let value2 = value1
        object.double = value2
        // Then
        XCTAssertEqual(binding.value, value2)
        XCTAssertEqual(collector.collectedValues, [value1, value2])
    }

    func testDoDropDuplicatesWithNonEquatableStruct() {
        // Given
        struct NonEquatableStruct {
            let id: String
        }
        let id1 = "one"
        let value1 = NonEquatableStruct(id: id1)
        let subject = CurrentValueSubject<NonEquatableStruct, Never>(value1)
        let binding = subject.makeOneWayBinding(options: [.dropDuplicates])
        let collector = BindingCollector(binding: binding)

        // Then
        XCTAssert(binding.value.id == value1.id)
        XCTAssert(collector.collectedValues.count == 1)
        XCTAssert(collector.collectedValues.first?.id == value1.id)

        // When
        subject.send(value1)
        // Then there will be 2 identical values
        XCTAssert(binding.value.id == value1.id)
        XCTAssert(collector.collectedValues.count == 2)
        XCTAssert(collector.collectedValues.first?.id == value1.id)
        XCTAssert(collector.collectedValues.last?.id == value1.id)
    }

    func testDoDropDuplicatesWithNonEquatableObject() {
        // Given
        class NonEquatableObject { }
        let value1 = NonEquatableObject()
        let subject = CurrentValueSubject<NonEquatableObject, Never>(value1)
        let binding = subject.makeOneWayBinding(options: [.dropDuplicates])
        let collector = BindingCollector(binding: binding)

        // Then
        XCTAssert(binding.value === value1)
        XCTAssert(collector.collectedValues.count == 1)
        XCTAssert(collector.collectedValues.first === value1)

        // When sending duplicate value
        subject.send(value1)
        // Then there will still only be one value because the objects are compared with ===
        XCTAssert(binding.value === value1)
        XCTAssert(collector.collectedValues.count == 1)
        XCTAssert(collector.collectedValues.first === value1)
    }

    func testDoNotDropDuplicatesWithNonEquatableObject() {
        /// Given
        class NonEquatable {  }
        let value1 = NonEquatable()
        let subject = CurrentValueSubject<NonEquatable, Never>(value1)
        let binding = subject.makeOneWayBinding(options: [])
        let collector = BindingCollector(binding: binding)

        // Then
        XCTAssert(binding.value === value1)
        XCTAssert(collector.collectedValues.count == 1)
        XCTAssert(collector.collectedValues.first === value1)

        // When
        subject.send(value1)
        // Then
        XCTAssert(binding.value === value1)
        XCTAssert(collector.collectedValues.count == 2)
        XCTAssert(collector.collectedValues.first === value1)
        XCTAssert(collector.collectedValues.last === value1)
    }
}


// MARK: - Dynamic member lookup (for reference types) and subscript (for value types)

extension OneWayBindingTests {

    func testSetRootObjectPropagatesToChainedBindings() {
        // Given
        let double1 = 1.0
        let text1 = "one"
        let childValue1 = ChildValue(text: text1, texts: [text1])
        let rootValue1 = RootValue(text: text1, childValue: childValue1)
        let child1 = ChildObject(double: double1, rootValue: rootValue1)
        let root1 = RootObject(childObject: child1)
        let rootObjectSubject = CurrentValueSubject<RootObject, Never>(root1)

        // Then the values of the bindings for each node in the graph should be their initial value
        let rootObjectBinding = rootObjectSubject.makeOneWayBinding()
        let rootObjectCollector = BindingCollector(binding: rootObjectBinding)
        XCTAssertEqual(rootObjectBinding.value, root1)
        XCTAssertEqual(rootObjectCollector.collectedValues, [root1])

        let childObjectBinding = rootObjectBinding.$childObject
        let childObjectCollector = BindingCollector(binding: childObjectBinding)
        XCTAssertEqual(childObjectBinding.value, root1.childObject)
        XCTAssertEqual(childObjectCollector.collectedValues, [child1])

        let rootValueBinding = rootObjectBinding.$childObject.$rootValue
        let rootValueCollector = BindingCollector(binding: rootValueBinding)
        XCTAssertEqual(rootValueBinding.value, rootValue1)
        XCTAssertEqual(rootValueCollector.collectedValues, [rootValue1])

        let childValueBinding = rootObjectBinding.$childObject.$rootValue[oneWay: \.childValue]
        let childValueCollector = BindingCollector(binding: childValueBinding)
        XCTAssertEqual(childValueBinding.value, childValue1)
        XCTAssertEqual(childValueCollector.collectedValues, [childValue1])

        let textBinding = rootObjectBinding.$childObject.$rootValue[oneWay: \.childValue.text]
        let textCollector = BindingCollector(binding: textBinding)
        XCTAssertEqual(textBinding.value, text1)
        XCTAssertEqual(textCollector.collectedValues, [text1])


        // When the root node is set ...
        let double2 = 2.0
        let text2 = "two"
        let childValue2 = ChildValue(text: text2, texts: [text2])
        let rootValue2 = RootValue(text: text2, childValue: childValue2)
        let child2 = ChildObject(double: double2, rootValue: rootValue2)
        let root2 = RootObject(childObject: child2)
        rootObjectSubject.send(root2)

        // Then all of the bindings in the graph should update to the new root node
        XCTAssertEqual(rootObjectBinding.value, root2)
        XCTAssertEqual(rootObjectCollector.collectedValues, [root1, root2])

        XCTAssertEqual(childObjectBinding.value, root2.childObject)
        XCTAssertEqual(childObjectCollector.collectedValues, [child1, child2])

        XCTAssertEqual(rootValueBinding.value, root2.childObject.rootValue)
        XCTAssertEqual(rootValueCollector.collectedValues, [rootValue1, rootValue2])

        XCTAssertEqual(childValueBinding.value, root2.childObject.rootValue?.childValue)
        XCTAssertEqual(childValueCollector.collectedValues, [childValue1, childValue2])

        XCTAssertEqual(textBinding.value, text2)
        XCTAssertEqual(textCollector.collectedValues, [text1, text2])


        // When we update a child of the root then only the updated bindings and those deeper than it should update
        let double3 = 3.0
        let text3 = "three"
        let childValue3 = ChildValue(text: text3, texts: [text3])
        let rootValue3 = RootValue(text: text2, childValue: childValue3)
        let child3 = ChildObject(double: double3, rootValue: rootValue3)
        rootObjectBinding.value.childObject = child3

        // Then all of the bindings in the graph should update to the new root node
        XCTAssertEqual(rootObjectBinding.value, root2)
        XCTAssertEqual(rootObjectCollector.collectedValues, [root1, root2])

        XCTAssertEqual(childObjectBinding.value, root2.childObject)
        XCTAssertEqual(childObjectCollector.collectedValues, [child1, child2, child3])

        XCTAssertEqual(rootValueBinding.value, root2.childObject.rootValue)
        XCTAssertEqual(rootValueCollector.collectedValues, [rootValue1, rootValue2, rootValue3])

        XCTAssertEqual(childValueBinding.value, root2.childObject.rootValue?.childValue)
        XCTAssertEqual(childValueCollector.collectedValues, [childValue1, childValue2, childValue3])

        XCTAssertEqual(textBinding.value, text3)
        XCTAssertEqual(textCollector.collectedValues, [text1, text2, text3])


        // When we update a value type then only the updated bindings and those deeper than it should update
        let text4 = "four"
        let childValue4 = ChildValue(text: text4, texts: [text4])
        child3.rootValue?.childValue = childValue4
        let rootValue4 = child3.rootValue

        // Then all of the bindings in the graph should update to the new root node
        XCTAssertEqual(rootObjectBinding.value, root2)
        XCTAssertEqual(rootObjectCollector.collectedValues, [root1, root2])

        XCTAssertEqual(childObjectBinding.value, root2.childObject)
        XCTAssertEqual(childObjectCollector.collectedValues, [child1, child2, child3])

        XCTAssertEqual(rootValueBinding.value, root2.childObject.rootValue)
        XCTAssertEqual(rootValueCollector.collectedValues, [rootValue1, rootValue2, rootValue3, rootValue4])

        XCTAssertEqual(childValueBinding.value, root2.childObject.rootValue?.childValue)
        XCTAssertEqual(childValueCollector.collectedValues, [childValue1, childValue2, childValue3, childValue4])

        XCTAssertEqual(textBinding.value, text4)
        XCTAssertEqual(textCollector.collectedValues, [text1, text2, text3, text4])
    }

    func testPublisherBackedBinding() {
        let double1 = 1.0
        let child1 = ChildObject(double: double1, rootValue: nil)
        let root1 = RootObject(childObject: child1)
        let int1 = 1
        root1.int = int1
        let rootSubject = CurrentValueSubject<RootObject, Never>(root1)
        let rootBinding = rootSubject.makeOneWayBinding()

        let publisherBackedBinding = rootBinding.$intPublished
        let publisherBackedCollector = BindingCollector(binding: publisherBackedBinding)
        XCTAssertEqual(publisherBackedBinding.value, int1)
        XCTAssertEqual(publisherBackedCollector.collectedValues, [int1])

        let int2 = 2
        root1.int = int2
        XCTAssertEqual(publisherBackedBinding.value, int2)
        XCTAssertEqual(publisherBackedCollector.collectedValues, [int1, int2])

        let int3 = 3
        let root2 = RootObject(childObject: child1)
        root2.int = int3
        rootSubject.send(root2)
        XCTAssertEqual(publisherBackedBinding.value, int3)
        XCTAssertEqual(publisherBackedCollector.collectedValues, [int1, int2, int3])
    }
}


// MARK: - Optional subscripts

extension OneWayBindingTests {

    func testOptionalSubscripts() {
        class Root {
            @Binding var child: ChildObject?
        }
        let rootObject = Root()
        let rootBinding = Just(rootObject).makeOneWayBinding()
        let childBinding = rootBinding.$child
        let childValue = ChildValue(text: "text", texts: ["text"])
        let otherChildValue = ChildValue(text: "other", texts: ["other"])

        // ChildObject.childValue is optional
        let binding1: OneWayBinding<ChildValue?> = childBinding[oneWay: \.?.childValue]
        // The type remains optional because we're not shortcutting the root object
        let binding2: OneWayBinding<ChildValue?> = childBinding[oneWay: \.?.childValue, default: otherChildValue]

        // The root is being shortcut but the property is still optional
        let binding3: OneWayBinding<ChildValue?> = childBinding[oneWay: \.childValue]
        // The root is being shortcut and the property is having a default applied
        let binding4: OneWayBinding<ChildValue> = childBinding[oneWay: \.childValue, default: otherChildValue]

        XCTAssertEqual(binding1.value, nil)
        XCTAssertEqual(binding2.value, otherChildValue)
        XCTAssertEqual(binding3.value, nil)
        XCTAssertEqual(binding4.value, otherChildValue)

        rootObject.child = ChildObject(double: 0, rootValue: nil)
        rootObject.child?.childValue = childValue
        XCTAssertEqual(binding1.value, childValue)
        XCTAssertEqual(binding2.value, childValue)
        XCTAssertEqual(binding3.value, childValue)
        XCTAssertEqual(binding4.value, childValue)
    }
}
