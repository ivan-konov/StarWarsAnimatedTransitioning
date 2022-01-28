//
//  FirstViewController.swift
//  StarWarsAnimatedTransitioningExample
//
//  Created by Ivan Konov on 12/21/14.
//  Copyright (c) 2014-2022 Ivan Konov. All rights reserved.
//

import UIKit

final class FirstViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentSecondController))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func presentSecondController() {
        guard let secondVC = self.storyboard?.instantiateViewController(withIdentifier: "2ndVC") else {
            return
        }
        
        secondVC.modalPresentationStyle = .custom
        secondVC.transitioningDelegate = self
        self.present(secondVC, animated: true)
    }
}

extension FirstViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        StarWarsAnimatedTransitioning(transitionType: .circular(isClockwise: true))
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        StarWarsAnimatedTransitioning(operation: .dismiss, transitionType: .circular(isClockwise: false))
    }
}

