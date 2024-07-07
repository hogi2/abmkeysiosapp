//
//  NotificationManager.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 7/1/24.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func scheduleOrderCompletionNotification(orderId: Int, orderTotal: String?) {
        let content = UNMutableNotificationContent()
        content.title = "طلب شراء ناجح"
        if let total = orderTotal {
            content.body = "💰 تهانينا طلب شراء ناجح بقيمة \(total) 💰"
        } else {
            content.body = "تهانينا طلب شراء ناجح"
        }
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "earning.mp3"))

        let request = UNNotificationRequest(identifier: "\(orderId)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
