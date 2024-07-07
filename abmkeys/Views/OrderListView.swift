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

    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .onChange(of: searchText) { newValue in
                        currentPage = 1
                        orders = []
                        fetchOrders()
                    }
                List {
                    ForEach(orders, id: \.id) { order in
                        OrderCard(order: order)
                            .onTapGesture {
                                selectedOrder = order
                                showOrderDetail = true
                            }
                            .onAppear {
                                if order == orders.last {
                                    loadMoreOrders()
                                }
                            }
                    }
                    if isLoading {
                        ProgressView()
                    }
                }
                .listStyle(PlainListStyle())
                .navigationTitle("All Orders")
                .navigationDestination(isPresented: $showOrderDetail) {
                    OrderDetailView(orderId: selectedOrder?.id ?? 0)
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

    func fetchOrders() {
        isLoading = true
        WooCommerceService().getOrders(page: currentPage, search: searchText) { fetchedOrders in
            isLoading = false
            if let fetchedOrders = fetchedOrders {
                DispatchQueue.main.async {
                    self.orders += fetchedOrders
                }
            }
        }
    }

    func loadMoreOrders() {
        currentPage += 1
        fetchOrders()
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
