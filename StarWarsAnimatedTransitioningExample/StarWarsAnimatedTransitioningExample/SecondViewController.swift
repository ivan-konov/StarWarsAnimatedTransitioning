//
//  SecondViewController.swift
//  StarWarsAnimatedTransitioningExample
//
//  Created by Ivan Konov on 12/21/14.
//  Copyright (c) 2014-2022 Ivan Konov. All rights reserved.
//

import UIKit

final class SecondViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
    }
}
