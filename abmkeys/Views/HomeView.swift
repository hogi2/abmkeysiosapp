//
//  HomeView.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 6/30/24.
//

import SwiftUI

struct HomeView: View {
    @Binding var orders: [Order]
    @Binding var latestProducts: [Product]
    @State private var selectedOrder: Order?
    @State private var selectedProduct: ProductDetail?
    @State private var showOrderDetail = false
    @State private var showProductDetail = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    latestOrdersSection
                    latestProductsSection
                }
                .background(Color.backgroundColor.edgesIgnoringSafeArea(.all))
            }
            .navigationDestination(isPresented: $showOrderDetail) {
                if let selectedOrder = selectedOrder {
                    OrderDetailView(orderId: selectedOrder.id)
                }
            }
            .navigationDestination(isPresented: $showProductDetail) {
                if let selectedProduct = selectedProduct {
                    ProductDetailView(productDetail: selectedProduct)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private var latestOrdersSection: some View {
        Section(header: Text("Latest Orders").font(.title).padding(.horizontal).foregroundColor(Color.textColor)) {
            ForEach(orders.prefix(4), id: \.id) { order in
                OrderRow(order: order)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedOrder = order
                        showOrderDetail = true
                    }
                    .padding(.horizontal)
            }
        }
    }

    private var latestProductsSection: some View {
        Section(header: Text("Latest Products").font(.title).padding(.horizontal).foregroundColor(Color.textColor)) {
            ForEach(latestProducts, id: \.id) { product in
                ProductRow(product: product)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        fetchProductDetails(productId: product.id)
                    }
                    .padding(.horizontal)
            }
        }
    }

    func fetchProductDetails(productId: Int) {
        Task {
            do {
                let productDetail = try await WooCommerceService().getProductDetails(productId: productId)
                DispatchQueue.main.async {
                    self.selectedProduct = productDetail
                    self.showProductDetail = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertMessage = "Error fetching product details: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }
    }
}

struct OrderRow: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Order ID: \(order.id.formatted())")
                .font(.headline)
            Text("Status: \(order.status.capitalized)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.cardColor)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct ProductRow: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Name: \(product.name)")
                .font(.headline)
            Text("Price: \(product.price)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.cardColor)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
