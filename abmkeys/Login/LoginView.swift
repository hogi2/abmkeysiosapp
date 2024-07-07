//
//  LoginView.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 7/8/24.
//

//import SwiftUI
//import Combine
//
//struct LoginView: View {
//    @State private var showQRScanner = false
//    @State private var loginError: String?
//    @State private var isQRCodeProcessed = false
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                Text("Login to Your Store")
//                    .font(.largeTitle)
//                    .padding()
//
//                Button("Scan QR Code") {
//                    showQRScanner = true
//                }
//                .padding()
//                .sheet(isPresented: $showQRScanner) {
//                    QRScannerView(onScanResult: handleQRScan)
//                }
//
//                if let loginError = loginError {
//                    Text(loginError)
//                        .foregroundColor(.red)
//                        .padding()
//                }
//            }
//            .padding()
//        }
//    }
//
//    func handleQRScan(result: String) {
//        if isQRCodeProcessed { return }
//
//        do {
//            let credentials = try parseCredentials(from: result)
//            try KeychainHelper.save(credentials: credentials)
//            WooCommerceService.credentials = credentials  // Set credentials in WooCommerceService
//            print("Credentials saved: \(credentials)")
//            isQRCodeProcessed = true
//            if let window = UIApplication.shared.windows.first {
//                window.rootViewController = UIHostingController(rootView: ContentView())
//                window.makeKeyAndVisible()
//            }
//        } catch {
//            print("Error parsing or saving credentials: \(error.localizedDescription)")
//            DispatchQueue.main.async {
//                loginError = "Invalid QR code or credentials."
//            }
//        }
//    }
//
//    func parseCredentials(from qrCodeResult: String) throws -> WooCommerceCredentials {
//        let components = qrCodeResult.split(separator: "|")
//        guard components.count == 2 else {
//            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid QR code format"])
//        }
//        let consumerKey = String(components[0])
//        let consumerSecret = String(components[1])
//        return WooCommerceCredentials(consumerKey: consumerKey, consumerSecret: consumerSecret)
//    }
//}

import SwiftUI
import Combine

struct LoginView: View {
    @State private var showQRScanner = false
    @State private var loginError: String?
    @State private var isQRCodeProcessed = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Login to Your Store")
                    .font(.largeTitle)
                    .padding()

                Button("Scan QR Code") {
                    showQRScanner = true
                }
                .padding()
                .sheet(isPresented: $showQRScanner) {
                    QRScannerView(onScanResult: handleQRScan)
                }

                if let loginError = loginError {
                    Text(loginError)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
        }
    }

    func handleQRScan(result: String) {
        if isQRCodeProcessed { return }

        do {
            let credentials = try parseCredentials(from: result)
            try KeychainHelper.save(credentials: credentials)
            WooCommerceService.credentials = credentials  // Set credentials in WooCommerceService
            print("Credentials saved: \(credentials)")
            isQRCodeProcessed = true
            if let window = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .filter({ $0.isKeyWindow }).first {
                window.rootViewController = UIHostingController(rootView: ContentView())
                window.makeKeyAndVisible()
            }
        } catch {
            print("Error parsing or saving credentials: \(error.localizedDescription)")
            DispatchQueue.main.async {
                loginError = "Invalid QR code or credentials."
            }
        }
    }

    func parseCredentials(from qrCodeResult: String) throws -> WooCommerceCredentials {
        let components = qrCodeResult.split(separator: "|")
        guard components.count == 2 else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid QR code format"])
        }
        let consumerKey = String(components[0])
        let consumerSecret = String(components[1])
        return WooCommerceCredentials(consumerKey: consumerKey, consumerSecret: consumerSecret)
    }
}
