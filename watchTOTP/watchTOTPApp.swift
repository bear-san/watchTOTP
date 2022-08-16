//
//  watchTOTPApp.swift
//  watchTOTP
//
//  Created by Kentaro on 2022/05/29.
//

import SwiftUI
import WatchConnectivity

@main
struct watchTOTPApp: App {
    @ObservedObject var controller = TOTPController()
    @Environment(\.scenePhase) private var scenePhase
    var wcSession = WCSession.default
    var watchConnector = WatchConnector()
    
    var body: some Scene {
        WindowGroup {
            ContentView(controller: controller)
        }
        .onChange(of: scenePhase) { phase in
            switch phase{
            case .active:
                wcSession.delegate = watchConnector
                wcSession.activate()
            default: break
            }
        }
    }
}
