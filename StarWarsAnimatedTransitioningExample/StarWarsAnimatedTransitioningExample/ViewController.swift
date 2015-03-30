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
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "presentSecondController")
        view.addGestureRecognizer(tapRecognizer)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PresentSecondController" {
            let destinationController = segue.destinationViewController as! UIViewController
            destinationController.modalPresentationStyle = .Custom
            destinationController.transitioningDelegate = self
        }
    }

    func presentSecondController() {
        performSegueWithIdentifier("PresentSecondController", sender: self)
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = StarWarsAnimatedTransitioning()
        animator.operation = .Present
        animator.type = .LinearRight
        
        return animator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = StarWarsAnimatedTransitioning()
        animator.operation = .Dismiss
        animator.type = .CircularCounterclockwise
        
        return animator
    }
}

