//
//  ViewController.swift
//  StarWarsAnimatedTransitioningExample
//
//  Created by Ivan Konov on 12/21/14.
//  Copyright (c) 2014-2022 Ivan Konov. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    override func loadView() {
        super.loadView()
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView(image: UIImage(named: "road"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Photo of a road"
        containerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40.0),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 40.0),
        ])
        
        self.view = containerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentSecondController))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func presentSecondController() {
        let secondVC = SecondViewController()
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

