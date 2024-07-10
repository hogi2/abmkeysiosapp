//
//  NotificationManager.swift
//  abmkeys
//
//  Created by Hogan Alkahlan on 7/1/24.
//

import UserNotifications
import os.log

class NotificationManager {
    static let shared = NotificationManager()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "NotificationManager")

    func scheduleOrderCompletionNotification(orderId: Int, orderTotal: String?, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "طلب شراء ناجح"
        if let total = orderTotal {
            content.body = "💰 تهانينا طلب شراء ناجح بقيمة \(total) 💰"
        } else {
            content.body = "تهانينا طلب شراء ناجح"
        }
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "cash_register.mp3"))

        let request = UNNotificationRequest(identifier: "\(orderId)", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                self?.logger.error("Error scheduling notification: \(error.localizedDescription)")
                completion?(.failure(error))
            } else {
                self?.logger.info("Notification scheduled for order \(orderId)")
                completion?(.success(()))
            }
        }
    }
}

//import UserNotifications
//import os.log
//
//class NotificationManager {
//    static let shared = NotificationManager()
//    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "NotificationManager")
//
//    func scheduleOrderCompletionNotification(orderId: Int, orderTotal: String?, completion: ((Result<Void, Error>) -> Void)? = nil) {
//        let content = UNMutableNotificationContent()
//        content.title = "Order Completed"
//        content.body = "Your order \(orderId) has been completed."
//        content.sound = UNNotificationSound.default
//
//        // Trigger the notification after 5 seconds for testing purposes
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//        let request = UNNotificationRequest(identifier: "\(orderId)", content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request) { [weak self] error in
//            if let error = error {
//                self?.logger.error("Error scheduling notification: \(error.localizedDescription)")
//                completion?(.failure(error))
//            } else {
//                self?.logger.info("Notification scheduled for order \(orderId)")
//                completion?(.success(()))
//            }
//        }
//    }
//}
