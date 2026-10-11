//
//  FeedScreen.swift
//  Social_Media_App_UIkitUITests
//
//  Created by aplle on 5/17/26.
//

import XCTest

final class FeedScreen: XCTestCase {
    var app: XCUIApplication!
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append(contentsOf: [
            LaunchArgument.skipWelcome.rawValue,
            LaunchArgument.forceLoggedOut.rawValue
        ])
        app.launch()
        
        
        loginWithRealBackendAccount()
        waitForFeedScreen()
    }
    override func tearDownWithError() throws {
     app = nil
    }
   private func loginWithRealBackendAccount() {


       let emailField = A11y.Login.emailField.element(in: app)

           let passwordField = A11y.Login.passwordField.element(in: app)

           let loginButton = A11y.Login.loginButton.element(in: app)

           XCTAssertTrue(emailField.waitForExistence(timeout: 2))

           XCTAssertTrue(passwordField.exists)

       XCTAssertTrue(loginButton.exists)

           emailField.tap()

           emailField.typeText("hakimeliyhev@icloud.com")

           passwordField.tap()

           passwordField.typeText("hliyev5359")

           app.tap()

           loginButton.tap()

       }
    func waitForFeedScreen() {

            XCTAssertTrue(
            A11y.Feed.screen.element(in: app).waitForExistence(timeout: 8),
                "Feed screen did not appear after login"
            )

        }
    

    func testFeedScreenRenders() throws {
        let feedScreen = A11y.Feed.screen.element(in: app)
        let feedTable = A11y.Feed.tableView.element(in: app)
        let firstPostCell = app.cells.matching(identifier: A11y.Feed.postCell.id).firstMatch

        XCTAssertTrue(feedScreen.waitForExistence(timeout: 5))
        XCTAssertTrue(feedTable.exists)
        XCTAssertTrue(firstPostCell.waitForExistence(timeout: 5))
    }
    func testTapAvatarOpensProfile() throws {
        let firstPostCell = app.cells.matching(identifier: A11y.Feed.postCell.id).firstMatch
        let firstAvatar = firstPostCell.images[A11y.Feed.avatarButton.id]
     
        XCTAssertTrue(firstPostCell.waitForExistence(timeout: 10))
        XCTAssertTrue(firstAvatar.exists)
        firstAvatar.tap()
        XCTAssertTrue(A11y.Profile.screen.element(in: app).waitForExistence(timeout: 2))
        
    }
    func testTapCommentsOpensComments() throws {
        let firstPostCell = app.cells.matching(identifier: A11y.Feed.postCell.id).firstMatch
        let commentButton = firstPostCell.buttons[A11y.Feed.commentButton.id]
     
        XCTAssertTrue(firstPostCell.waitForExistence(timeout: 10))
        XCTAssertTrue(commentButton.exists)
        commentButton.tap()
        XCTAssertTrue(A11y.Comments.screen.element(in: app).waitForExistence(timeout: 2))
        
    }
   
    func testTapMoreOpensMore() throws {
        let firstPostCell = app.cells.matching(identifier: A11y.Feed.postCell.id).firstMatch
        let moreButton = firstPostCell.buttons[A11y.Feed.moreButton.id]
     
        XCTAssertTrue(firstPostCell.waitForExistence(timeout: 10))
        XCTAssertTrue(moreButton.exists)
        moreButton.tap()
        XCTAssertTrue(A11y.MoreSheet.screen.element(in: app).waitForExistence(timeout: 2))
        
    }

}
