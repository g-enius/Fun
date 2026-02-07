//
//  LoginView.swift
//  UI
//
//  SwiftUI view for Login screen
//

import SwiftUI

import FunCore
import FunViewModel

public struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

    public init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 40) {
            Spacer()

            // App icon/logo
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .accessibilityHidden(true)

            // Welcome text
            VStack(spacing: 12) {
                Text(L10n.Login.welcome)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(L10n.Login.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            // Login button
            Button(action: { viewModel.login() }) {
                HStack(spacing: 12) {
                    if viewModel.isLoggingIn {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text(viewModel.isLoggingIn ? L10n.Login.loggingIn : L10n.Login.loginButton)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.isLoggingIn)
            .padding(.horizontal, 24)
            .accessibilityIdentifier(AccessibilityID.Login.loginButton)

            // Demo note
            Text(L10n.Login.demoNote)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
        }
        .accessibilityIdentifier(AccessibilityID.Login.loginView)
    }
}

// MARK: - Previews

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: PreviewHelper.makeLoginViewModel())
    }
}
