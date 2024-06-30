//
//  SecondView.swift
//  kidomo
//
//  Created by qinqubo on 2024/5/30.
//

import SwiftUI

struct SecondView: View {
    @Environment(\.dismiss) private var dismiss
    var url: URL?

    init(url: URL?) {
        self.url = url
    }
    
    var body: some View {
        ViewControllerRepresentable(url: url) {
            dismiss()
        }.edgesIgnoringSafeArea(.all).navigationBarBackButtonHidden()
    }
}

struct ViewControllerRepresentable: UIViewControllerRepresentable {
    var url: URL?
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
        viewController.url = url
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {
        // Update the view controller if needed
    }
}

