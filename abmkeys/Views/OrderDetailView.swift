//
//  OrderDetailView.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 7/1/24.
//

import SwiftUI

struct OrderDetailView: View {
    let orderId: Int
    @State private var orderDetails: OrderDetails?
    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Order Details...")
            } else if let details = orderDetails {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Order Details")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.bottom, 16)
                            .padding(.horizontal)

                        SectionView(header: "Customer Info") {
                            DetailRow(label: "Customer Name", value: details.customerName)
                            DetailRow(label: "Email", value: details.email)
                            DetailRow(label: "Phone", value: details.phone)
                        }

                        SectionView(header: "Billing Info") {
                            DetailRow(label: "Total", value: Double(details.total)?.formattedAsCurrency() ?? details.total)
                            DetailRow(label: "Status", value: details.status.capitalized)
                        }

                        SectionView(header: "Order Items") {
                            ForEach(details.items) { item in
                                OrderItemView(item: item)
                            }
                        }

                        if !details.orderNotes.isEmpty {
                            SectionView(header: "Order Notes") {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(details.orderNotes) { note in
                                        Text(note.note)
                                            .padding()
                                            .background(Color.cardColor)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 16)
                }
            } else {
                Text("Failed to load order details.")
            }
        }
        .onAppear {
            Task {
                await fetchOrderDetails()
            }
        }
        .navigationTitle("Order #\(orderId.formatted())")
        .background(Color.backgroundColor.edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showError) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                primaryButton: .default(Text("Retry")) {
                    Task {
                        await fetchOrderDetails()
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }

    @MainActor
    private func fetchOrderDetails() async {
        do {
            orderDetails = try await WooCommerceService().getOrderDetails(orderId: orderId)
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

struct SectionView<Content: View>: View {
    let header: String
    let content: Content

    init(header: String, @ViewBuilder content: () -> Content) {
        self.header = header
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(header)
                .font(.headline)
                .padding(.horizontal)

            content
                .padding()
                .background(Color.cardColor)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text("\(label):")
                .fontWeight(.bold)
            Spacer()
            Text(value)
        }
        .padding()
        .background(Color.cardColor)
        .cornerRadius(10)
    }
}

struct OrderItemView: View {
    let item: OrderDetails.OrderItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.name)
                .font(.headline)

            DetailRow(label: "Quantity", value: String(item.quantity))
            DetailRow(label: "Total", value: Double(item.total)?.formattedAsCurrency() ?? item.total)
        }
        .padding()
        .background(Color.cardColor)
        .cornerRadius(10)
    }
}
