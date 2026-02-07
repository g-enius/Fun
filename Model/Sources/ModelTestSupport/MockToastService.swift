//
//  MockToastService.swift
//  Model
//
//  Mock implementation of ToastServiceProtocol for testing
//

import Foundation
import Combine
import FunModel

@MainActor
public final class MockToastService: ToastServiceProtocol {

    private let toastSubject = PassthroughSubject<ToastEvent, Never>()

    public var toastPublisher: AnyPublisher<ToastEvent, Never> {
        toastSubject.eraseToAnyPublisher()
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
        toastSubject.send(event)
    }
}
