//
//  Tab4View.swift
//  UI
//
//  SwiftUI view for Tab4 screen
//

import SwiftUI
import FunViewModel

public struct Tab4View: View {
    @ObservedObject var viewModel: Tab4ViewModel

    public init(viewModel: Tab4ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            Text("Tab 4 Content")
                .font(.title2)
                .foregroundColor(.gray)
        }
        .accessibilityIdentifier(AccessibilityID.Tab4.featureTogglesList)
    }
}
