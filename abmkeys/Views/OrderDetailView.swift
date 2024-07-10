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
    @State private var selectedStatus: String = ""
    @State private var showStatusActionSheet = false
    @State private var showConfirmationAlert = false

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

                        Button(action: {
                            showStatusActionSheet = true
                        }) {
                            Text("Change Status")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding()
                        .actionSheet(isPresented: $showStatusActionSheet) {
                            ActionSheet(
                                title: Text("Change Order Status"),
                                buttons: [
                                    .default(Text("Pending")) { selectedStatus = "pending"; showConfirmationAlert = true },
                                    .default(Text("Processing")) { selectedStatus = "processing"; showConfirmationAlert = true },
                                    .default(Text("On Hold")) { selectedStatus = "on-hold"; showConfirmationAlert = true },
                                    .default(Text("Completed")) { selectedStatus = "completed"; showConfirmationAlert = true },
                                    .default(Text("Cancelled")) { selectedStatus = "cancelled"; showConfirmationAlert = true },
                                    .default(Text("Refunded")) { selectedStatus = "refunded"; showConfirmationAlert = true },
                                    .default(Text("Failed")) { selectedStatus = "failed"; showConfirmationAlert = true },
                                    .cancel()
                                ]
                            )
                        }
                        .alert(isPresented: $showConfirmationAlert) {
                            Alert(
                                title: Text("Confirm Status Change"),
                                message: Text("Are you sure you want to change the status to \(selectedStatus.capitalized)?"),
                                primaryButton: .default(Text("Yes")) {
                                    Task {
                                        await updateOrderStatus()
                                    }
                                },
                                secondaryButton: .cancel()
                            )
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
            if let details = orderDetails {
                selectedStatus = details.status
            }
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    private func updateOrderStatus() async {
        do {
            guard var details = orderDetails else { return }
            try await WooCommerceService().updateOrderStatus(orderId: details.id, newStatus: selectedStatus)
            details.status = selectedStatus
            orderDetails = details
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
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
