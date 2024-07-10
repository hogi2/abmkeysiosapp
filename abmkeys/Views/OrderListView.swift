//
//  OrderListView.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 6/30/24.
//

import SwiftUI

struct OrderListView: View {
    @Binding var orders: [Order]
    @State private var searchText: String = ""
    @State private var currentPage = 1
    @State private var isLoading = false
    @State private var selectedOrder: Order?
    @State private var showOrderDetail = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var selectedFilter: String = "all"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    searchBar
                    orderSummary
                    if orders.isEmpty && !isLoading {
                        Text("No orders found")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ordersList
                    }
                }
                .background(Color.backgroundColor.edgesIgnoringSafeArea(.all))
            }
            .navigationDestination(isPresented: $showOrderDetail) {
                if let selectedOrder = selectedOrder {
                    OrderDetailView(orderId: selectedOrder.id)
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    primaryButton: .default(Text("Retry")) {
                        Task {
                            await fetchOrders()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private var searchBar: some View {
        SearchBar(text: $searchText)
            .padding(.horizontal)
            .onChange(of: searchText) { newValue in
                resetOrders()
                Task {
                    await fetchOrders()
                }
            }
    }

    private var orderSummary: some View {
        HStack {
            Text("Total Orders: \(orders.count)")
                .font(.headline)
            Spacer()
            Picker("Filter", selection: $selectedFilter) {
                Text("All").tag("all")
                Text("Pending").tag("pending")
                Text("Completed").tag("completed")
                Text("Canceled").tag("canceled")
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedFilter) { newValue in
                resetOrders()
                Task {
                    await fetchOrders()
                }
            }
        }
        .padding(.horizontal)
    }

    private var ordersList: some View {
        Section(header: Text("Orders").font(.title).padding(.horizontal).foregroundColor(Color.textColor)) {
            ForEach(orders, id: \.id) { order in
                OrderRow(order: order)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedOrder = order
                        showOrderDetail = true
                    }
                    .padding(.horizontal)
                    .onAppear {
                        if order == orders.last {
                            loadMoreOrders()
                        }
                    }
            }
            if isLoading {
                ProgressView()
                    .padding()
            }
        }
    }

    private func resetOrders() {
        currentPage = 1
        orders = []
    }

    @MainActor
    private func fetchOrders() async {
        isLoading = true
        do {
            let statusFilter = selectedFilter == "all" ? nil : selectedFilter
            let fetchedOrders = try await WooCommerceService().getOrders(page: currentPage, search: searchText, status: statusFilter)
            self.orders += fetchedOrders
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func loadMoreOrders() {
        currentPage += 1
        Task {
            await fetchOrders()
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
