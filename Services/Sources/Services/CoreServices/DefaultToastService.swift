//
//  DefaultToastService.swift
//  Services
//
//  Default implementation of ToastServiceProtocol
//

import Foundation
import FunModel

@MainActor
public final class DefaultToastService: ToastServiceProtocol {

    public init() {}

    public func showToast(message: String, type: ToastType) {
        // Post notification for toast display
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowToast"),
            object: nil,
            userInfo: [
                "message": message,
                "type": type
            ]
        )
    }
}
