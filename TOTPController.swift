//
//  TOTPController.swift
//  watchTOTP
//
//  Created by Kentaro on 2022/05/29.
//

import Foundation
import KeychainAccess
import SwiftOTP

class TOTPController: ObservableObject {
    @Published var credentials: [TOTPCredential] = []
    let keychain = Keychain.init(service: Bundle.main.bundleIdentifier ?? "")
    
    init() {
        credentials.append(TOTPCredential("HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ"))
        print(credentials[0].token)
    }
}

class TOTPCredential: Identifiable, ObservableObject{
    private var timer: Timer?
    private var secret = ""
    private var generator: TOTP?
    
    var timeoutSec = 0
    
    @Published var accountName = ""
    @Published var token = ""
    @Published var remainCount = 0
    
    init(_ secret: String) {
        self.secret = secret
        self.generator = TOTP(secret: self.secret.base32DecodedData!,
                              digits: 6,
                              timeInterval: 30,
                              algorithm: .sha1)
        generateToken()
        
        self.timer = .scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            if self.remainCount > 1{
                self.remainCount -= 1
                
                return
            }
            
            self.generateToken()
        })
    }
    
    private func generateToken() {
        self.token = self.generator?.generate(time: Date()) ?? ""
        self.remainCount = 30
    }
    
    deinit {
        timer?.invalidate()
    }
}
