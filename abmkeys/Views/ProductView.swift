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
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack {
                searchBar
                if products.isEmpty && !isLoading {
                    Text("No products found")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    productList
                }
            }
            .background(Color.backgroundColor.edgesIgnoringSafeArea(.all))
            .gesture(
                TapGesture()
                    .onEnded { hideKeyboard() }
            )
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private var searchBar: some View {
        SearchBar(text: $searchText)
            .padding(.horizontal)
            .onChange(of: searchText) { _ in
                resetProducts()
                Task {
                    await fetchProducts()
                }
            }
    }

    private var productList: some View {
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
                    Task {
                        await fetchProductDetails(productId: product.id)
                    }
                }
                .onAppear {
                    if product == products.last {
                        Task {
                            await loadMoreProducts()
                        }
                    }
                }
            }
            if isLoading {
                ProgressView()
                    .padding()
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

    private func resetProducts() {
        currentPage = 1
        products = []
    }

    @MainActor
    private func fetchProducts() async {
        isLoading = true
        do {
            let fetchedProducts = try await WooCommerceService().getProducts(page: currentPage, search: searchText)
            self.products += fetchedProducts
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    private func fetchProductDetails(productId: Int) async {
        do {
            selectedProduct = try await WooCommerceService().getProductDetails(productId: productId)
            showProductDetail = true
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func loadMoreProducts() async {
        currentPage += 1
        await fetchProducts()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
