//
//  watchTOTPApp.swift
//  watchTOTP WatchKit Extension
//
//  Created by Kentaro on 2022/05/29.
//

import SwiftUI

@main
struct watchTOTPApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
