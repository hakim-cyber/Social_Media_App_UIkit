//
//  Extension+AccesibilityItem.swift
//  Social_Media_App_UIkitUITests
//
//  Created by aplle on 5/17/26.
//

import XCTest
extension AccessibilityItem{
    func element(in app: XCUIApplication) -> XCUIElement {
        switch type {
        case .button:
            return app.buttons[id]
            
        case .textField:
            return app.textFields[id]
            
        case .secureTextField:
            return app.secureTextFields[id]
            
        case .staticText:
            return app.staticTexts[id]
            
        case .otherElement:
            return app.otherElements[id]
            
        case .image:
            return app.images[id]
            
        case .collectionView:
            return app.collectionViews[id]
            
        case .table:
            return app.tables[id]
            
        case .cell:
            return app.cells[id]
            
        case .switchControl:
            return app.switches[id]
            
        case .slider:
            return app.sliders[id]
            
        case .scrollView:
            return app.scrollViews[id]
            
        case .navigationBar:
            return app.navigationBars[id]
            
        case .tabBar:
            return app.tabBars[id]
            
        case .webView:
            return app.webViews[id]
        }
    }
}
