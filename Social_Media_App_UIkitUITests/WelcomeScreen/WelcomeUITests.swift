//
//  WelcomeUITests.swift
//  Social_Media_App_UIkitUITests
//
//  Created by aplle on 4/29/26.
//

import XCTest

final class WelcomeUITests: XCTestCase {
  var app: XCUIApplication!
    
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
      
    app = XCUIApplication()
    
    app.launchArguments.append(contentsOf: [LaunchArgument.resetOnboarding.rawValue,LaunchArgument.forceLoggedOut.rawValue])
      
    app.launch()
      
      
    }

    override func tearDown()  {
      app = nil
      super.tearDown()
    }

    func testAssertVisible(){
        XCTAssertTrue(app.otherElements[A11y.Welcome.screen].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts[A11y.Welcome.title].exists)
        XCTAssertTrue(app.staticTexts[A11y.Welcome.subtitle].exists)
        XCTAssertTrue(app.otherElements[A11y.Welcome.slideTrack].exists)
        XCTAssertTrue(app.otherElements[A11y.Welcome.sliderThumb].exists)
       
    }
    func testSlideToUnlock() {
        let sliderThumb = app.otherElements[A11y.Welcome.sliderThumb]
        let sliderTrack = app.otherElements[A11y.Welcome.slideTrack]
        
        XCTAssertTrue(sliderThumb.waitForExistence(timeout: 2))
        XCTAssertTrue(sliderTrack.exists)
        
        let start = sliderThumb.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let finish = sliderTrack.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))
        
        start.press(forDuration: 0.1, thenDragTo: finish)
        
        XCTAssertTrue(app.otherElements[A11y.Login.screen].waitForExistence(timeout: 2))
    }

}
