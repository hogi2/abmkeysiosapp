//
//  CardComponents.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 7/10/24.
//
import SwiftUI

struct OrderCard: View {
    let order: Order

    var body: some View {
        ZStack {
            order.statusColor
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
            VStack {
                Text("Order ID: \(order.id)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Status: \(order.status.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text("Total Price: \(order.total)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.6))
            .cornerRadius(10)
        }
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct ProductCard: View {
    let product: Product

    var body: some View {
        ZStack {
            Color.cardColor
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 2)
                Text("Price: \(product.price)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.black.opacity(0.6))
            .cornerRadius(10)
        }
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
