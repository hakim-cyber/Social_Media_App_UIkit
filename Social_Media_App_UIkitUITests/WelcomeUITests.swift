//
//  WelcomeUITests.swift
//  Social_Media_App_UIkitUITests
//
//  Created by aplle on 4/29/26.
//

import XCTest

final class WelcomeUITests: XCTestCase {

    override func setUpWithError() throws {

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
      
    }

    func testExample() throws {
    
        let app = XCUIApplication()
      
        app.launchArguments.append(contentsOf: [LaunchArgument.resetOnboarding.rawValue,LaunchArgument.forceLoggedOut.rawValue])
        
        app.launch()
        
        XCTAssertTrue(app.staticTexts[A11y.Welcome.title].exists)
    }

}
