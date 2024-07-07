//
//  LoadingView.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 7/1/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView("Loading...")
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .padding()
            Text("Please wait while we fetch the data")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
        .edgesIgnoringSafeArea(.all)
    }
}
