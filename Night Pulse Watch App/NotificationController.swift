//
//  NotificationController.swift
//  Night Pulse Watch App
//
//  Created by Mylo Kaye on 17/06/2023.
//

import Foundation
import WatchKit
import SwiftUI
import UserNotifications

class NotificationController: WKUserNotificationHostingController<NotificationView> {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}

struct NotificationView: View {
    var notification: UNNotification

    var body: some View {
        Text(notification.alertBody ?? "Unknown notification")
    }
}
