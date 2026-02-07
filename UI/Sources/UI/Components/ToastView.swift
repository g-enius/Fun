//
//  ToastView.swift
//  UI
//
//  Toast notification view that slides down from top
//

import SwiftUI

import FunCore
import FunModel

public struct ToastView: View {
    let message: String
    let type: ToastType
    let onDismiss: () -> Void

    @State private var isVisible = false
    @State private var isDismissed = false

    public init(message: String, type: ToastType, onDismiss: @escaping () -> Void) {
        self.message = message
        self.type = type
        self.onDismiss = onDismiss
    }

    public var body: some View {
        VStack {
            if isVisible {
                HStack(spacing: 12) {
                    Image(systemName: iconName)
                        .font(.system(size: 18, weight: .semibold))

                    Text(message)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Button(action: dismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .accessibilityLabel(L10n.Common.close)
                    .accessibilityIdentifier(AccessibilityID.Toast.closeButton)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(backgroundColor)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .accessibilityIdentifier("toast_view")
            }

            Spacer()
        }
        .task {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isVisible = true
            }

            // Auto-dismiss after 3 seconds
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            dismiss()
        }
    }

    private func dismiss() {
        guard !isDismissed else { return }
        isDismissed = true

        withAnimation(.easeOut(duration: 0.25)) {
            isVisible = false
        }
        Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
            onDismiss()
        }
    }

    private var iconName: String {
        switch type {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        case .info:
            return "info.circle.fill"
        }
    }

    private var backgroundColor: Color {
        switch type {
        case .success:
            return .green
        case .error:
            return .red
        case .info:
            return .blue
        }
    }
}

// MARK: - Previews

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ToastView(
                message: "Something went wrong. Please try again.",
                type: .error,
                onDismiss: {}
            )
            .previewDisplayName("Error Toast")

            ToastView(
                message: "Item added to favorites!",
                type: .success,
                onDismiss: {}
            )
            .previewDisplayName("Success Toast")

            ToastView(
                message: "Pull down to refresh content.",
                type: .info,
                onDismiss: {}
            )
            .previewDisplayName("Info Toast")
        }
    }
}
