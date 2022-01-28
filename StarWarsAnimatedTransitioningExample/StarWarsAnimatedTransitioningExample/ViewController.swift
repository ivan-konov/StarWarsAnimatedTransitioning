//
//  ViewController.swift
//  StarWarsAnimatedTransitioningExample
//
//  Created by Ivan Konov on 12/21/14.
//  Copyright (c) 2014-2015 Ivan Konov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentSecondController))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func presentSecondController() {
        guard let secondVC = storyboard?.instantiateViewController(withIdentifier: "2ndVC") else { return }
        secondVC.modalPresentationStyle = .custom
        secondVC.transitioningDelegate = self
        self.show(secondVC, sender: nil)
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = StarWarsAnimatedTransitioning()
        animator.operation = .present
        animator.type = .linearRight
        
        return animator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = StarWarsAnimatedTransitioning()
        animator.operation = .dismiss
        animator.type = .circularCounterclockwise
        
        return animator
    }
}

