//
//  watchTOTPApp.swift
//  watchTOTP
//
//  Created by Kentaro on 2022/05/29.
//

import SwiftUI

@main
struct watchTOTPApp: App {
    @ObservedObject var controller = TOTPController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
