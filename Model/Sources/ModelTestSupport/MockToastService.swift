//
//  MockToastService.swift
//  Model
//
//  Mock implementation of ToastServiceProtocol for testing
//

import FunCore
import FunModel

@MainActor
public final class MockToastService: ToastServiceProtocol {

    private let toastBroadcaster = StreamBroadcaster<ToastEvent>()

    public var toastEvents: AsyncStream<ToastEvent> {
        toastBroadcaster.makeStream()
    }

    public var showToastCalled = false
    public var lastMessage: String?
    public var lastType: ToastType?
    public var toastHistory: [ToastEvent] = []

    public init() {}

    public func showToast(message: String, type: ToastType) {
        showToastCalled = true
        lastMessage = message
        lastType = type
        let event = ToastEvent(message: message, type: type)
        toastHistory.append(event)
        toastBroadcaster.yield(event)
    }
}
