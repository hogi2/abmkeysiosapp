//
//  ProductCard.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 6/30/24.
//

import SwiftUI

struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading) {
            Text(product.name)
                .font(.headline)
                .padding(.bottom, 2)
            Text("Price: \(product.price)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.cardColor)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}
