//
//  DataModel.swift
//  watchTOTP
//
//  Created by 阿部 賢太郎 on 2022/08/16.
//

import Foundation
import RealmSwift
import KeychainAccess
import SwiftOTP

class TOTPCredential: Identifiable, ObservableObject{
    private var timer: Timer?
    private var secret = ""
    private var generator: TOTP?
    
    var timeoutSec = 30
    
    @Published var displayName = ""
    @Published var token = ""
    @Published var remainCount = 0
    
    init(secret: String, metadata: TOTPCredentialMetadata) {
        self.displayName = "\(metadata.issuer)(\(metadata.accountName))"
        self.timeoutSec = metadata.period
        
        self.secret = secret
        self.generator = TOTP(secret: self.secret.base32DecodedData!,
                              digits: 6,
                              timeInterval: self.timeoutSec,
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
        self.remainCount = self.timeoutSec
    }
    
    deinit {
        timer?.invalidate()
    }
}

struct TOTPCredentialPayloadData {
    var metadata: TOTPCredentialMetadata
    var secret: String
}

enum WTError: LocalizedError{
    case notOtpAuthURI
    case invalidOtpAuthURI
    
    var errorDescription: String {
        switch self {
        case .notOtpAuthURI:
            return ""
        case .invalidOtpAuthURI:
            return ""
        }
    }
}

class TOTPCredentialMetadata: Object{
    @Persisted var issuer: String
    @Persisted var accountName: String
    @Persisted var algorithm: String
    @Persisted var digits: Int
    @Persisted var period: Int
}
