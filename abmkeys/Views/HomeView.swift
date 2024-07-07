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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Section(header: Text("Latest Orders").font(.title).padding(.horizontal).foregroundColor(Color.textColor)) {
                        ForEach(orders.prefix(4), id: \.id) { order in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Order ID: \(order.id.formatted())")
                                    .font(.headline)
                                Text("Status: \(order.status.capitalized)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedOrder = order
                                showOrderDetail = true
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.cardColor)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding(.horizontal)
                        }
                    }

                    Section(header: Text("Latest Products").font(.title).padding(.horizontal).foregroundColor(Color.textColor)) {
                        ForEach(latestProducts, id: \.id) { product in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Name: \(product.name)")
                                    .font(.headline)
                                Text("Price: \(product.price)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                fetchProductDetails(productId: product.id)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.cardColor)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding(.horizontal)
                        }
                    }
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
                print("Error fetching product details: \(error.localizedDescription)")
            }
        }
    }
}
