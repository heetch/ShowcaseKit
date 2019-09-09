//
//  ViewController.swift
//  ShowcaseExample
//
//  Created by Jérôme Alves on 09/09/2019.
//  Copyright © 2019 Jérôme Alves. All rights reserved.
//

import UIKit
import ShowcaseKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func openShowcases(_ sender: Any) {
        ShowcasesViewController.present(over: self)
    }
}

