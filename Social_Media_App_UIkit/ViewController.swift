//
//  ViewController.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/20/25.
//

import UIKit

class ViewController: UIViewController {

    let label: UILabel = {
        let label = UILabel()
        label.text = "Hello, World!"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        label.startShimmering()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // on a label or cell content view
     
        self.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }


}

