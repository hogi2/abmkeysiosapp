//
//  SettingsView.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 6/30/24.
//

import SwiftUI

struct SettingsView: View {
    @State private var enableNotifications = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $enableNotifications)
                    Button("Schedule Test Notification") {
                        NotificationManager.shared.scheduleOrderCompletionNotification(orderId: 123, orderTotal: "$99.99") { result in
                            switch result {
                            case .success:
                                print("Notification scheduled successfully")
                            case .failure(let error):
                                print("Failed to schedule notification: \(error.localizedDescription)")
                            }
                        }
                    }
                }
                Section(header: Text("Account")) {
                    Button("Logout") {
                        Task {
                            await logout()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    @MainActor
    private func logout() async {
        do {
            try KeychainHelper.deleteCredentials()
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = UIHostingController(rootView: LoginView())
                window.makeKeyAndVisible()
            }
        } catch {
            print("Failed to logout: \(error.localizedDescription)")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
