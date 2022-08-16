//
//  ContentView.swift
//  watchTOTP
//
//  Created by Kentaro on 2022/05/29.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var controller = TOTPController()
    var body: some View {
        NavigationView{
            VStack{
                ForEach(controller.credentials){ c in
                    OTPView(token: c)
                }
                .toolbar{
                    Button("hogehoge") {
                        controller.readingQrCode = true
                    }
                }
                .sheet(isPresented: $controller.readingQrCode) {
                    QRScannerView { result in
                        controller.addCredential(result)
                        controller.readingQrCode.toggle()
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
