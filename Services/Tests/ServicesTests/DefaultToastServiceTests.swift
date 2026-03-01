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

        // Eager continuation: stream registered, values buffered before iteration
        let stream = service.toastStream
        service.showToast(message: "Test message", type: .success)

        var iterator = stream.makeAsyncIterator()
        let receivedEvent = await iterator.next()

        #expect(receivedEvent != nil)
        #expect(receivedEvent?.message == "Test message")
        #expect(receivedEvent?.type == .success)
    }

    @Test("showToast with error type")
    func testShowToastErrorType() async {
        let service = DefaultToastService()

        let stream = service.toastStream
        service.showToast(message: "Error occurred", type: .error)

        var iterator = stream.makeAsyncIterator()
        let receivedEvent = await iterator.next()

        #expect(receivedEvent?.type == .error)
        #expect(receivedEvent?.message == "Error occurred")
    }

    @Test("showToast with info type")
    func testShowToastInfoType() async {
        let service = DefaultToastService()

        let stream = service.toastStream
        service.showToast(message: "Info message", type: .info)

        var iterator = stream.makeAsyncIterator()
        let receivedEvent = await iterator.next()

        #expect(receivedEvent?.type == .info)
    }

    // MARK: - Multiple Toast Tests

    @Test("Multiple toasts all emit events")
    func testMultipleToastsEmitEvents() async {
        let service = DefaultToastService()

        let stream = service.toastStream
        service.showToast(message: "First", type: .success)
        service.showToast(message: "Second", type: .error)
        service.showToast(message: "Third", type: .info)

        var receivedEvents: [ToastEvent] = []
        var iterator = stream.makeAsyncIterator()
        for _ in 0..<3 {
            if let event = await iterator.next() {
                receivedEvents.append(event)
            }
        }

        #expect(receivedEvents.count == 3)
        #expect(receivedEvents[0].message == "First")
        #expect(receivedEvents[1].message == "Second")
        #expect(receivedEvents[2].message == "Third")
    }

    // MARK: - Stream Behavior Tests

    @Test("Late subscriber does not receive past events")
    func testLateSubscriberMissesPastEvents() async {
        let service = DefaultToastService()

        // Emit before subscribing — no continuation exists, value is lost
        service.showToast(message: "Before subscribe", type: .info)

        var receivedEvents: [ToastEvent] = []
        let stream = service.toastStream
        let task = Task {
            for await event in stream {
                receivedEvents.append(event)
                break
            }
        }

        // Verify absence: wait briefly then confirm nothing arrived
        try? await Task.sleep(for: .milliseconds(10))

        #expect(receivedEvents.isEmpty)
        task.cancel()
    }
}
