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
        view.backgroundColor = .systemBackground
        let slideButton = SlideToUnlockView()
        slideButton.translatesAutoresizingMaskIntoConstraints = false
        slideButton.onUnlock = {
            print("Unlocked!")
            let alert = UIAlertController(title: "Unlocked", message: "You slid to unlock!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }

        view.addSubview(slideButton)

        NSLayoutConstraint.activate([
            slideButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            slideButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            slideButton.widthAnchor.constraint(equalToConstant: 300),
          
        ])
    }


}
