//
//  AppAlertPresenter.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 4/17/26.
//

import UIKit


enum AppAlertPresenter{
  static func showAlert(
        title: String?,
        message: String?,
        okTitle: String = "OK",
        presenter: UIViewController,
        animated: Bool = true,
        onOk: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: okTitle, style: .default) { _ in
            onOk?()
        })

        (presenter).present(alert, animated: animated)
    }
}
