//
//  SettingsView.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 6/30/24.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: .constant(true))
                }
                Section(header: Text("Account")) {
                    Text("Account Details")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
