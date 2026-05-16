//
//  LoginScreen.swift
//  Social_Media_App_UIkitUITests
//
//  Created by aplle on 5/16/26.
//

import XCTest

final class LoginScreen: XCTestCase {
    var app: XCUIApplication!
    override func setUpWithError() throws {
      
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(contentsOf: [LaunchArgument.resetOnboarding.rawValue,LaunchArgument.forceLoggedOut.rawValue])
          
        app.launch()

    }

    override func tearDownWithError() throws {
    
    }

    func testExample() throws {
    
        
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
