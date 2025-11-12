//
//  SmartAdvisorBridge.swift
//  QuattSmartAdvisor
//
//  Created by Josevin Johny on 12/11/2025.
//

import Foundation
import UIKit
import SwiftUI

@objc(SmartAdvisorModule)
class SmartAdvisorModule: NSObject {
    
    @objc
    func present() {
        DispatchQueue.main.async {
            guard let rootVC = self.getRootViewController() else {
                print("❌ Could not find root view controller")
                return
            }
            
            let advisorView = SmartAdvisorPlaceholder()
            let hostingController = UIHostingController(rootView: advisorView)
            hostingController.modalPresentationStyle = .fullScreen
            
            rootVC.present(hostingController, animated: true)
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        return topController
    }
    
    @objc
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
}

struct SmartAdvisorPlaceholder: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("🎉")
                    .font(.system(size: 80))
                
                Text("Bridge Works!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("React Native → Swift Bridge Connected!")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: { dismiss() }) {
                    Text("Close")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cyan)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 20)
            }
        }
    }
}
