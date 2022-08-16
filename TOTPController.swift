//
//  TOTPController.swift
//  watchTOTP
//
//  Created by Kentaro on 2022/05/29.
//

import Foundation
import KeychainAccess
import SwiftOTP
import RealmSwift

class TOTPController: ObservableObject {
    @Published var credentials: [TOTPCredential] = []
    let keychain = Keychain.init(service: Bundle.main.bundleIdentifier ?? "")
    private let db = try! Realm()
    
    @Published var readingQrCode = false
    
    init() {
        refresh()
    }
    
    func addCredential(_ code: String) throws {
        guard let url = URL(string: code) else{
            throw WTError.notOtpAuthURI
        }
        
        if url.scheme != "otpauth"{
            throw WTError.notOtpAuthURI
        }
        
        let lastPath = url.pathComponents.last ?? ""
        
        let secretAttributes = TOTPCredentialMetadata()
        secretAttributes.issuer = String(lastPath.split(separator: ":").first ?? "")
        secretAttributes.accountName = String(lastPath.split(separator: ":").last ?? "")
        
        guard let urlComponents = URLComponents(string: code) else{
            throw WTError.invalidOtpAuthURI
        }
        
        secretAttributes.algorithm = urlComponents.queryItems?.first(where: { i in
            return i.name == "algorithm"
        })?.value ?? ""
        
        secretAttributes.digits = Int(urlComponents.queryItems?.first(where: { i in
            return i.name == "digits"
        })?.value ?? "0") ?? 0
        
        
        secretAttributes.period = Int(urlComponents.queryItems?.first(where: { i in
            return i.name == "period"
        })?.value ?? "0") ?? 0
        
        try! db.write({
            db.add(secretAttributes)
        })
        
        
        let secret = urlComponents.queryItems?.first(where: { i in
            return i.name == "secret"
        })?.value ?? ""
        
        let key = "\(Bundle.main.bundleIdentifier ?? "")_\(secretAttributes.issuer):\(secretAttributes.accountName)"
        keychain[key] = secret
        
        self.readingQrCode = false
        self.refresh()
    }
    
    func refresh() {
        var newCredentials: [TOTPCredential] = []
        let secrets = db.objects(TOTPCredentialMetadata.self)
        
        secrets.forEach { s in
            let key = "\(Bundle.main.bundleIdentifier ?? "")_\(s.issuer):\(s.accountName)"
            
            newCredentials.append(.init(secret: keychain[key] ?? "",
                                        metadata: s))
        }
        
        self.credentials = newCredentials
    }
}

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
