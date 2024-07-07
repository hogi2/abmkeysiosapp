//
//  OrderCard.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 6/30/24.
//

import SwiftUI

struct OrderCard: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Order ID: \(order.id.formatted())")
                .font(.headline)
            Text("Status: \(order.status.capitalized)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.cardColor)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}
