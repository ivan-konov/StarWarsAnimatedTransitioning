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
        containerView.backgroundColor = .white
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
        label.backgroundColor = .clear
        label.text = "Photo of a road"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.textColor = .white
        containerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40.0),
            label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 100.0),
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
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = StarWarsAnimatedTransitioning()
        animator.operation = .present
        animator.type = .linearRight
        
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = StarWarsAnimatedTransitioning()
        animator.operation = .dismiss
        animator.type = .circularCounterclockwise
        
        return animator
    }
}

