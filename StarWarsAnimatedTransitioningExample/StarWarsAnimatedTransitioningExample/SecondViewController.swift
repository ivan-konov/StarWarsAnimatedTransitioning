//
//  SecondViewController.swift
//  StarWarsAnimatedTransitioningExample
//
//  Created by Ivan Konov on 12/21/14.
//  Copyright (c) 2014-2022 Ivan Konov. All rights reserved.
//

import UIKit

final class SecondViewController: UIViewController {
    override func loadView() {
        super.loadView()
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView(image: UIImage(named: "road-2"))
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
        label.text = "Photo of another road"
        containerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 40.0),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 40.0),
        ])

        self.view = containerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}
