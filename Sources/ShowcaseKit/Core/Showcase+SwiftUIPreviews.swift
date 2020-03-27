//
//  Showcase+SwiftUIPreviews.swift
//  ShowcaseKit-iOS
//
//  Created by Jérôme Alves on 03/11/2019.
//  Copyright © 2019 Jérôme Alves. All rights reserved.
//

#if canImport(SwiftUI)

import Foundation
import UIKit
import SwiftUI

@available(iOS 13.0, *)
extension _ShowcaseIdentity where Self: PreviewProvider {

    public static func preview(on previewDevice: PreviewDevice? = nil) -> some View {
        ShowcaseView
            .init(showcase: self as! Showcase.Type)
            .edgesIgnoringSafeArea(.all)
            .previewDevice(previewDevice)
    }

}

@available(iOS 13, *)
struct ShowcaseView: UIViewControllerRepresentable {
    
    let showcase: Showcase.Type
    
    init(showcase: Showcase.Type) {
        self.showcase = showcase
    }
    
    class Coordinator {
        let showcase: Showcase
        init(showcase: Showcase) {
            self.showcase = showcase
        }
    }
    
    func makeCoordinator() -> ShowcaseView.Coordinator {
        Coordinator(showcase: self.showcase.init())
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShowcaseView>) -> UIViewController {

        let viewController = context.coordinator.showcase.makeViewController()
        
        viewController.title = showcase.title
        viewController.hidesBottomBarWhenPushed = true
        viewController.navigationItem.largeTitleDisplayMode = .never

        switch showcase.presentationMode {
        case .automatic where viewController is UINavigationController:
            return viewController
        case .automatic:
            return UINavigationController(rootViewController: viewController)
        case .modal:
            return viewController
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<ShowcaseView>) {
        
    }
}

#endif
