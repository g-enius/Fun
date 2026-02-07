//
//  DefaultToastServiceTests.swift
//  Services
//
//  Unit tests for DefaultToastService
//

import Testing
import Foundation
import Combine
@testable import FunServices
@testable import FunModel

@Suite("DefaultToastService Tests")
@MainActor
struct DefaultToastServiceTests {

    // MARK: - Initialization Tests

    @Test("Service initializes with no pending events")
    func testInitialization() async {
        let service = DefaultToastService()
        var eventCount = 0
        var cancellables = Set<AnyCancellable>()

        service.toastPublisher
            .sink { _ in eventCount += 1 }
            .store(in: &cancellables)

        #expect(eventCount == 0)
    }

    // MARK: - Show Toast Tests

    @Test("showToast emits event via publisher")
    func testShowToastEmitsEvent() async {
        let service = DefaultToastService()
        var receivedEvent: ToastEvent?
        var cancellables = Set<AnyCancellable>()

        service.toastPublisher
            .sink { event in
                receivedEvent = event
            }
            .store(in: &cancellables)

        service.showToast(message: "Test message", type: .success)

        #expect(receivedEvent != nil)
        #expect(receivedEvent?.message == "Test message")
        #expect(receivedEvent?.type == .success)
    }

    @Test("showToast with error type")
    func testShowToastErrorType() async {
        let service = DefaultToastService()
        var receivedEvent: ToastEvent?
        var cancellables = Set<AnyCancellable>()

        service.toastPublisher
            .sink { event in
                receivedEvent = event
            }
            .store(in: &cancellables)

        service.showToast(message: "Error occurred", type: .error)

        #expect(receivedEvent?.type == .error)
        #expect(receivedEvent?.message == "Error occurred")
    }

    @Test("showToast with info type")
    func testShowToastInfoType() async {
        let service = DefaultToastService()
        var receivedEvent: ToastEvent?
        var cancellables = Set<AnyCancellable>()

        service.toastPublisher
            .sink { event in
                receivedEvent = event
            }
            .store(in: &cancellables)

        service.showToast(message: "Info message", type: .info)

        #expect(receivedEvent?.type == .info)
    }

    // MARK: - Multiple Toast Tests

    @Test("Multiple toasts all emit events")
    func testMultipleToastsEmitEvents() async {
        let service = DefaultToastService()
        var receivedEvents: [ToastEvent] = []
        var cancellables = Set<AnyCancellable>()

        service.toastPublisher
            .sink { event in
                receivedEvents.append(event)
            }
            .store(in: &cancellables)

        service.showToast(message: "First", type: .success)
        service.showToast(message: "Second", type: .error)
        service.showToast(message: "Third", type: .info)

        #expect(receivedEvents.count == 3)
        #expect(receivedEvents[0].message == "First")
        #expect(receivedEvents[1].message == "Second")
        #expect(receivedEvents[2].message == "Third")
    }

    // MARK: - Publisher Behavior Tests

    @Test("No events received before showToast is called")
    func testNoEventsBeforeShowToast() async {
        let service = DefaultToastService()
        var eventCount = 0
        var cancellables = Set<AnyCancellable>()

        service.toastPublisher
            .sink { _ in
                eventCount += 1
            }
            .store(in: &cancellables)

        #expect(eventCount == 0)
    }

    @Test("Late subscriber does not receive past events")
    func testLateSubscriberMissesPastEvents() async {
        let service = DefaultToastService()
        var cancellables = Set<AnyCancellable>()

        // Emit before subscribing
        service.showToast(message: "Before subscribe", type: .info)

        var receivedEvents: [ToastEvent] = []
        service.toastPublisher
            .sink { event in
                receivedEvents.append(event)
            }
            .store(in: &cancellables)

        // PassthroughSubject does not replay - should be empty
        #expect(receivedEvents.isEmpty)
    }
}
