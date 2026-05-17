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
        XCTAssertTrue(A11y.Welcome.screen.element(in: app).waitForExistence(timeout: 2))
        XCTAssertTrue(A11y.Welcome.title.element(in: app).exists)
        XCTAssertTrue(A11y.Welcome.subtitle.element(in: app).exists)
        XCTAssertTrue(A11y.Welcome.slideTrack.element(in: app).exists)
        XCTAssertTrue(A11y.Welcome.sliderThumb.element(in: app).exists)
       
    }
    func testSlideToUnlock() {
        let sliderThumb = A11y.Welcome.sliderThumb.element(in: app)
        let sliderTrack = A11y.Welcome.slideTrack.element(in: app)
        
        XCTAssertTrue(sliderThumb.waitForExistence(timeout: 2))
        XCTAssertTrue(sliderTrack.exists)
        
        let start = sliderThumb.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let finish = sliderTrack.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5))
        
        start.press(forDuration: 0.1, thenDragTo: finish)
        
        XCTAssertTrue(A11y.Login.screen.element(in: app).waitForExistence(timeout: 2))
    }

}
