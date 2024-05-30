//
//  SecondView.swift
//  kidomo
//
//  Created by qinqubo on 2024/5/30.
//

import SwiftUI

struct SecondView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ViewControllerRepresentable {
            dismiss()
        }.edgesIgnoringSafeArea(.all).navigationBarBackButtonHidden()
    }
}

struct ViewControllerRepresentable: UIViewControllerRepresentable {
    var onDismiss: () -> Void
    
    class Coordinator: NSObject {
        var parent: ViewControllerRepresentable
        
        init(parent: ViewControllerRepresentable) {
            self.parent = parent
        }
        
        @objc func dismiss() {
            parent.onDismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> WebViewController {
        let viewController = WebViewController()
        viewController.coordinator = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {
        // Update the view controller if needed
    }
}

#Preview {
    SecondView()
}
