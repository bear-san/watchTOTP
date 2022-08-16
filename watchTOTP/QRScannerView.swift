//
//  QRScannerView.swift
//  watchTOTP
//
//  Created by 阿部 賢太郎 on 2022/08/16.
//

import SwiftUI

struct QRScannerView: UIViewRepresentable {
    var didDetected: (String) -> Void
    var view = QRCodeReaderView()
    
    func makeUIView(context: Context) -> QRCodeReaderView {
        startCapture()
        
        return self.view
    }
    
    func updateUIView(_ uiView: QRCodeReaderView, context: Context) {
    }
    
    func startCapture() {
        view.didDetected = didDetected
        
        view.requestCameraAuthorization()
        view.startCapture()
    }
    
    static func dismantleUIView(_ uiView: QRCodeReaderView, coordinator: ()) {
        uiView.stopCapture()
    }
    
    static func empty() -> QRScannerView {
        return .init(didDetected: { _ in })
    }
}
