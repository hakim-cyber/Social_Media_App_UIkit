//
//  MoreSheetConfigBuilder.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 4/18/26.
//


import UIKit

final class MoreSheetConfigBuilder {
    private var header: MoreSheetConfig.Header?
    private var title: String?
    private var message: String?
    private var actions: [MoreSheetConfig.Action] = []

    @discardableResult
    func setHeader(_ header: MoreSheetConfig.Header) -> Self {
        self.header = header
        return self
    }

    @discardableResult
    func setTitle(_ title: String?) -> Self {
        self.title = title
        return self
    }

    @discardableResult
    func setMessage(_ message: String?) -> Self {
        self.message = message
        return self
    }

    @discardableResult
    func addAction(
        id: String,
        title: String,
        subtitle: String? = nil,
        icon: UIImage? = nil,
        style: MoreSheetConfig.Action.Style = .normal,
        isEnabled: Bool = true,
        handler: @escaping () -> Void
    ) -> Self {
        actions.append(
            MoreSheetConfig.Action(
                id: id,
                title: title,
                subtitle: subtitle,
                icon: icon,
                style: style,
                isEnabled: isEnabled,
                handler: handler
            )
        )
        return self
    }

    func build() -> MoreSheetConfig {
        MoreSheetConfig(
            header: header,
            title: title,
            message: message,
            actions: actions
        )
    }
}
