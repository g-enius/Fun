//
//  DefaultToastServiceTests.swift
//  Services
//
//  Unit tests for DefaultToastService
//

import Testing
import Foundation
@testable import FunServices
@testable import FunModel

@Suite("DefaultToastService Tests")
@MainActor
struct DefaultToastServiceTests {

    // MARK: - Show Toast Tests

    @Test("showToast emits event via stream")
    func testShowToastEmitsEvent() async {
        let service = DefaultToastService()
        var receivedEvent: ToastEvent?

        let task = Task {
            for await event in service.toastEvents {
                receivedEvent = event
                break
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        service.showToast(message: "Test message", type: .success)

        try? await Task.sleep(for: .milliseconds(50))
        task.cancel()

        #expect(receivedEvent != nil)
        #expect(receivedEvent?.message == "Test message")
        #expect(receivedEvent?.type == .success)
    }

    @Test("showToast with error type")
    func testShowToastErrorType() async {
        let service = DefaultToastService()
        var receivedEvent: ToastEvent?

        let task = Task {
            for await event in service.toastEvents {
                receivedEvent = event
                break
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        service.showToast(message: "Error occurred", type: .error)

        try? await Task.sleep(for: .milliseconds(50))
        task.cancel()

        #expect(receivedEvent?.type == .error)
        #expect(receivedEvent?.message == "Error occurred")
    }

    @Test("showToast with info type")
    func testShowToastInfoType() async {
        let service = DefaultToastService()
        var receivedEvent: ToastEvent?

        let task = Task {
            for await event in service.toastEvents {
                receivedEvent = event
                break
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        service.showToast(message: "Info message", type: .info)

        try? await Task.sleep(for: .milliseconds(50))
        task.cancel()

        #expect(receivedEvent?.type == .info)
    }

    // MARK: - Multiple Toast Tests

    @Test("Multiple toasts all emit events")
    func testMultipleToastsEmitEvents() async {
        let service = DefaultToastService()
        var receivedEvents: [ToastEvent] = []

        let task = Task {
            for await event in service.toastEvents {
                receivedEvents.append(event)
                if receivedEvents.count >= 3 { break }
            }
        }

        // Let the consumer task start and subscribe
        try? await Task.sleep(for: .milliseconds(50))

        service.showToast(message: "First", type: .success)
        service.showToast(message: "Second", type: .error)
        service.showToast(message: "Third", type: .info)

        try? await Task.sleep(for: .milliseconds(50))
        task.cancel()

        #expect(receivedEvents.count == 3)
        #expect(receivedEvents[0].message == "First")
        #expect(receivedEvents[1].message == "Second")
        #expect(receivedEvents[2].message == "Third")
    }

    // MARK: - Stream Behavior Tests

    @Test("Late subscriber does not receive past events")
    func testLateSubscriberMissesPastEvents() async {
        let service = DefaultToastService()

        // Emit before subscribing
        service.showToast(message: "Before subscribe", type: .info)

        var receivedEvents: [ToastEvent] = []
        let task = Task {
            for await event in service.toastEvents {
                receivedEvents.append(event)
                break
            }
        }

        try? await Task.sleep(for: .milliseconds(50))

        // AsyncStream (like PassthroughSubject) does not replay - should be empty
        #expect(receivedEvents.isEmpty)
        task.cancel()
    }
}
