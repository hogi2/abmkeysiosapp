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
                .padding(.horizontal)  // Add padding to the parent container
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
                OrderCard(order: order)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedOrder = order
                        showOrderDetail = true
                    }
            }
        }
    }

    private var latestProductsSection: some View {
        Section(header: Text("Latest Products").font(.title).padding(.horizontal).foregroundColor(Color.textColor)) {
            ForEach(latestProducts, id: \.id) { product in
                ProductCard(product: product)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        fetchProductDetails(productId: product.id)
                    }
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
