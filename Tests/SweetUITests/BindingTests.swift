import XCTest
@testable import SweetUI
import Combine


//@MainActor
//final class BindingTests: XCTestCase {
//
//    func testInitCore() async throws {
//        class Object {
//            @Published var value = 0
//        }
//        let object = Object()
//        var testIndex = 0
//        let subject = AnySubject(get: object.$value, set: { object.value = $0 })
//        let binding = Binding(subject: subject, cancellable: nil, getter: { object.value })
//        var sinkInvocationCount = 0
//        let sink0 = binding.sink { value in
//            sinkInvocationCount += 1
//            switch testIndex {
//            case 0:
//                XCTAssertEqual(value, 0)
//
//            case 1:
//                XCTAssertEqual(value, 1)
//
//            default:
//                XCTFail()
//            }
//        }
//
//        testIndex = 1
//        binding.wrappedValue = 1
//        XCTAssertEqual(binding.wrappedValue, 1)
//
//        sink0.cancel()
//        XCTAssertEqual(sinkInvocationCount, 2)
//    }
//
//    func testInitCurrentValueSubject() async throws {
//        var testIndex = 0
//        let currentValueSubject = CurrentValueSubject<Int, Never>(0)
//        let binding = Binding(currentValueSubject: currentValueSubject)
//        var sinkInvocationCount = 0
//        let sink0 = binding.sink { value in
//            sinkInvocationCount += 1
//            switch testIndex {
//            case 0:
//                XCTAssertEqual(value, 0)
//
//            case 1:
//                XCTAssertEqual(value, 1)
//
//            default:
//                XCTFail()
//            }
//        }
//
//        testIndex = 1
//        binding.wrappedValue = 1
//        XCTAssertEqual(binding.wrappedValue, 1)
//
//        sink0.cancel()
//        XCTAssertEqual(sinkInvocationCount, 2)
//    }
//
//    func testInitWrappedValue() async throws {
//        class Object {
//            @Published var value = 0
//        }
//        let object = Object()
//        var testIndex = 0
//        let binding = Binding(wrappedValue: object.value)
//        var sinkInvocationCount = 0
//        let sink0 = binding.sink { value in
//            sinkInvocationCount += 1
//            switch testIndex {
//            case 0:
//                XCTAssertEqual(value, 0)
//
//            case 1:
//                XCTAssertEqual(value, 1)
//
//            default:
//                XCTFail()
//            }
//        }
//
//        let expected0 = 1
//        testIndex = 1
//        binding.wrappedValue = expected0
//        XCTAssertEqual(binding.wrappedValue, expected0)
//
//        object.value = .max
//        XCTAssertEqual(binding.wrappedValue, expected0)
//
//        sink0.cancel()
//        XCTAssertEqual(sinkInvocationCount, 2)
//    }
//}
