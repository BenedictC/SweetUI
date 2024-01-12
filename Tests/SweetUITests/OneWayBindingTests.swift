import XCTest
@testable import SweetUI
import Combine


final class OneWayBindingTests: XCTestCase {

    class Object {
        @Published var number = 0
    }

    func testInitCore() async throws {
        var testIndex = 0
        let object = Object()
        let publisher = object.$number
        let binding = OneWayBinding(publisher: publisher, cancellable: nil, get: { object.number })
        var sinkInvocationCount = 0
        let sink0 = binding.sink { value in
            sinkInvocationCount += 1
            switch testIndex {
            case 0:
                XCTAssertEqual(value, 0)

            case 1:
                XCTAssertEqual(value, 1)

            default:
                XCTFail()
            }
        }

        testIndex = 1
        object.number = 1
        XCTAssertEqual(binding.wrappedValue, 1)

        sink0.cancel()
        XCTAssertEqual(sinkInvocationCount, 2)
    }

    func testInitCurrentValueSubject() async throws {
        var testIndex = 0
        let currentValueSubject = CurrentValueSubject<Int, Never>(0)
        let binding = OneWayBinding(currentValueSubject: currentValueSubject)
        var sinkInvocationCount = 0
        let sink0 = binding.sink { value in
            sinkInvocationCount += 1
            switch testIndex {
            case 0:
                XCTAssertEqual(value, 0)

            case 1:
                XCTAssertEqual(value, 1)

            default:
                XCTFail()
            }
        }

        testIndex = 1
        currentValueSubject.send(1)
        XCTAssertEqual(binding.wrappedValue, 1)

        sink0.cancel()
        XCTAssertEqual(sinkInvocationCount, 2)
    }

    func testInitWrappedValue() async throws {
        class Object {
            @Published var value = -1
        }
        let object = Object()
        let binding = OneWayBinding(wrappedValue: object.value)

        var sinkInvocationCount = 0
        let sink0 = binding.sink { value in
            switch sinkInvocationCount {
            case 0:
                XCTAssertEqual(value, -1)
            default:
                XCTFail()
            }
            sinkInvocationCount += 1
        }
        XCTAssertEqual(binding.wrappedValue, -1)
        object.value += 1
        XCTAssertEqual(binding.wrappedValue, -1)

        sink0.cancel()
        XCTAssertEqual(sinkInvocationCount, 1)
    }
}


// MARK: - Dynamic member lookup

extension OneWayBindingTests {

    func testDynamicMemberLookup() {
        struct Outer {
            var foo = 0
            var inner = Inner()
        }
        struct Inner {
            var value = 0
        }

        let subject = CurrentValueSubject<Outer, Never>(Outer())
        let outerBinding = OneWayBinding(currentValueSubject: subject)
        let innerBinding = outerBinding.inner
        let expected = 3

        subject.value.inner.value = expected
        let actual = innerBinding.value.wrappedValue

        XCTAssertEqual(expected, actual)
    }
}


// MARK: - Factory

extension OneWayBindingTests {

    func testMake() {
        let subject = PassthroughSubject<Int, Never>()
        let expected0 = 0
        let binding = subject.makeOneWayBinding(initialValue: expected0)
        XCTAssertEqual(expected0, binding.wrappedValue)

        let expected1 = 1
        subject.send(expected1)
        XCTAssertEqual(expected1, binding.wrappedValue)
    }
}
