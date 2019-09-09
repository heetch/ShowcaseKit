//
//  LabelShowcase.swift
//  ShowcaseExample
//
//  Created by Jérôme Alves on 09/09/2019.
//  Copyright © 2019 Jérôme Alves. All rights reserved.
//

import Foundation
import UIKit
import ShowcaseKit

final class LabelShowcase: Showcase {

    func makeViewController() -> UIViewController {

        let viewController = UIViewController()

        let label = UILabel()
        label.text = "This is a Showcase"

        viewController.view.backgroundColor = .white
        viewController.view.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor).isActive = true

        return viewController
    }
}
