//
//  SecondViewController.swift
//  StarWarsAnimatedTransitioningExample
//
//  Created by Ivan Konov on 12/21/14.
//  Copyright (c) 2014-2015 Ivan Konov. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "dismissSelf")
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func dismissSelf() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
