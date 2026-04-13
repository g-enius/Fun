//
//  DefaultToastService.swift
//  Services
//
//  Default implementation of ToastServiceProtocol
//

import Foundation

import FunCore
import FunModel

@MainActor
public final class DefaultToastService: ToastServiceProtocol {

    // MARK: - Stream

    private let toastBroadcaster = StreamBroadcaster<ToastEvent>()

    public var toastStream: AsyncStream<ToastEvent> {
        toastBroadcaster.makeStream()
    }

    // MARK: - Initialization

    public init() {}

    // MARK: - ToastServiceProtocol

    public func showToast(message: String, type: ToastType) {
        toastBroadcaster.yield(ToastEvent(message: message, type: type))
    }
}
