//
//  LaunchArguments.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 4/29/26.
//

import Foundation

enum LaunchArgument: String {
    case resetOnboarding = "-uiTest_resetOnboarding"
    case skipWelcome = "-uiTest_skipWelcome"
    case forceLoggedOut = "-uiTest_forceLoggedOut"
    case forceLoggedIn = "-uiTest_forceLoggedIn"
}

struct LaunchArguments {
    private let arguments: [String]

    init(arguments: [String] = ProcessInfo.processInfo.arguments) {
        self.arguments = arguments
    }

    func contains(_ argument: LaunchArgument) -> Bool {
        arguments.contains(argument.rawValue)
    }
}
