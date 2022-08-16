//
//  QRCodeReaderView.swift
//  watchTOTP
//
//  Created by 阿部 賢太郎 on 2022/08/16.
//

import UIKit
import AVFoundation

class QRCodeReaderView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var session: AVCaptureSession?
    
    var didDetected: (String) -> Void = { _ in }
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = self.bounds
    }
    
    func requestCameraAuthorization() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if cameraAuthorizationStatus != .authorized{
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted{
                    self.setupCamera()
                }
            }
        }
        
        if session == nil {
            setupCamera()
        }
    }
    
    func setupCamera() {
        let session = AVCaptureSession()
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                mediaType: .video,
                                                                position: .back)
        let devices = discoverySession.devices
        guard let device = devices.first else{
            fatalError()
        }
        
        do{
            let deviceInput = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(deviceInput){
                session.addInput(deviceInput)
            }else{
                throw NSError(domain: "failed to add input session", code: 1)
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            if session.canAddOutput(metadataOutput){
                session.addOutput(metadataOutput)
            }else{
                throw NSError(domain: "failed to add output session", code: 1)
            }
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.qr]
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            self.layer.addSublayer(previewLayer)
            self.previewLayer = previewLayer
            
            self.session = session
        }catch{
            fatalError()
        }
    }
    
    func startCapture(){
        self.session?.startRunning()
    }
    
    func stopCapture(){
        self.session?.stopRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let objects = metadataObjects as? [AVMetadataMachineReadableCodeObject] else{
            fatalError()
        }
        
        for object in objects {
            guard let value = object.stringValue else{
                continue
            }
            
            didDetected(value)
            self.stopCapture()
        }
    }
}
