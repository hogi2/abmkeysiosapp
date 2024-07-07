//
//  CardView.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 6/30/24.
//

import SwiftUI

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(Color.cardColor)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
            .padding(.horizontal)
            .frame(maxWidth: .infinity) // Ensure it takes full width
    }
}
