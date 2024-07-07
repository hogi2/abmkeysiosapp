//
//  ProductDetailView.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 7/1/24.
//

import SwiftUI

struct ProductDetailView: View {
    let productDetail: ProductDetail

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Product Image
                if let imageUrls = productDetail.imageUrl, let firstUrl = imageUrls.first?.src, let url = URL(string: firstUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 250)
                    .background(Color.cardColor)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Product Details
                VStack(alignment: .leading, spacing: 8) {
                    Text(productDetail.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryColor)
                        .padding(.horizontal)

                    HStack {
                        Text("Price:")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondaryColor)
                        Spacer()
                        Text(Double(productDetail.price)?.formattedAsCurrency() ?? productDetail.price)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryColor)
                    }
                    .padding(.horizontal)

                    HStack {
                        Text("Category:")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondaryColor)
                        Spacer()
                        Text(productDetail.categories.first?.name ?? "Unknown")
                            .font(.title3)
                            .foregroundColor(.primaryColor)
                    }
                    .padding(.horizontal)

                    Text("Description:")
                        .font(.headline)
                        .foregroundColor(.textColor)
                        .padding(.horizontal)

                    Text(productDetail.description)
                        .font(.body)
                        .foregroundColor(.secondaryColor)
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                }

                Spacer()
            }
            .padding(.vertical)
            .background(Color.backgroundColor.edgesIgnoringSafeArea(.all))
            .navigationBarTitle(Text(productDetail.name), displayMode: .inline)
        }
    }
}
