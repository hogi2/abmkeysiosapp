//
//  ProductsView.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 6/30/24.
//

import SwiftUI

struct ProductView: View {
    @Binding var products: [Product]
    @State private var searchText: String = ""
    @State private var currentPage = 1
    @State private var isLoading = false
    @State private var selectedProduct: ProductDetail?
    @State private var showProductDetail = false

    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .onChange(of: searchText) { newValue in
                        currentPage = 1
                        products = []
                        fetchProducts()
                    }
                List {
                    ForEach(products, id: \.id) { product in
                        VStack(alignment: .leading) {
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
                        .onAppear {
                            if product == products.last {
                                loadMoreProducts()
                            }
                        }
                    }
                    if isLoading {
                        ProgressView()
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("All Products")
                .navigationDestination(isPresented: $showProductDetail) {
                    if let selectedProduct = selectedProduct {
                        ProductDetailView(productDetail: selectedProduct)
                    }
                }
            }
            .background(Color.backgroundColor.edgesIgnoringSafeArea(.all))
            .gesture(
                TapGesture()
                    .onEnded {
                        hideKeyboard()
                    }
            )
        }
    }

    func fetchProducts() {
        isLoading = true
        WooCommerceService().getProducts(page: currentPage, search: searchText) { fetchedProducts in
            isLoading = false
            if let fetchedProducts = fetchedProducts {
                DispatchQueue.main.async {
                    self.products += fetchedProducts
                }
            }
        }
    }

    func fetchProductDetails(productId: Int) {
        WooCommerceService().getProductDetails(productId: productId) { productDetail in
            if let productDetail = productDetail {
                DispatchQueue.main.async {
                    self.selectedProduct = productDetail
                    self.showProductDetail = true
                }
            }
        }
    }

    func loadMoreProducts() {
        currentPage += 1
        fetchProducts()
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
