import XCTest
@testable import SweetUI
import Combine


final class BindingTests: XCTestCase {

    func testCoreInit() async throws {
        var testIndex = 0
        let currentValueSubject = CurrentValueSubject<Int, Never>(0)
        let binding = Binding(subject: currentValueSubject.eraseToAnySubject(), getter: { currentValueSubject.value }, setter: { currentValueSubject.send($0) })
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
        binding.value = 1
        XCTAssertEqual(binding.value, 1)

        sink0.cancel()
        XCTAssertEqual(sinkInvocationCount, 2)
    }

    func testCurrentValueSubjectInit() async throws {
        var testIndex = 0
        let currentValueSubject = CurrentValueSubject<Int, Never>(0)
        let binding = Binding(currentValueSubject: currentValueSubject)
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
        binding.value = 1
        XCTAssertEqual(binding.value, 1)

        sink0.cancel()
        XCTAssertEqual(sinkInvocationCount, 2)
    }

    func testPublisherInit() async throws {
        class Object {
            @Published var value = 0
        }
        // convenience init<P: Publisher>(publisher: P, get getter: @escaping () -> Output, set setter: @escaping (Output) -> Void) where P.Output == Output, P.Failure == Never
        let object = Object()
        var testIndex = 0
        let binding = Binding(publisher: object.$value, get: { object.value }, set: { object.value = $0 })
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
        binding.value = 1
        XCTAssertEqual(binding.value, 1)

        sink0.cancel()
        XCTAssertEqual(sinkInvocationCount, 2)
    }

    func testPublishedInit() async throws {
        // convenience init<T: AnyObject, P: Publisher>(publishedBy object: T, get getPublisher: KeyPath<T, P>, set setKeyPath: ReferenceWritableKeyPath<T, Output>)  where P.Output == Output, P.Failure == Never
        class Object {
            @Published var value = 0
        }
        // convenience init<P: Publisher>(publisher: P, get getter: @escaping () -> Output, set setter: @escaping (Output) -> Void) where P.Output == Output, P.Failure == Never
        let object = Object()
        var testIndex = 0
        let binding = Binding(publishedBy: object, get: \.$value, set: \.value)
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
        binding.value = 1
        XCTAssertEqual(binding.value, 1)

        sink0.cancel()
        XCTAssertEqual(sinkInvocationCount, 2)
    }

    func testInitialValue() async throws {
        // convenience init(initialValue: Output, set setter: @escaping (_ current: Output, _ proposed: Output) -> Output = { $1 }) {
        var testIndex = 0
        let binding = Binding(initialValue: 0)
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
        binding.value = 1
        XCTAssertEqual(binding.value, 1)

        sink0.cancel()
        XCTAssertEqual(sinkInvocationCount, 2)
    }

    func testInitialValueWithSetter() async throws {
        // convenience init(initialValue: Output, set setter: @escaping (_ current: Output, _ proposed: Output) -> Output = { $1 }) {
        var testIndex = 0
        let binding = Binding(initialValue: 0) { $1 * 10 }
        var sinkInvocationCount = 0
        let sink0 = binding.sink { value in
            sinkInvocationCount += 1
            switch testIndex {
            case 0:
                XCTAssertEqual(value, 0)

            case 1:
                XCTAssertEqual(value, 10)

            default:
                XCTFail()
            }
        }

        testIndex = 1
        binding.value = 1
        XCTAssertEqual(binding.value, 10)

        sink0.cancel()
        XCTAssertEqual(sinkInvocationCount, 2)
    }
}
