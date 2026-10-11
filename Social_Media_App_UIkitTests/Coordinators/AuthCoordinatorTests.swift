//
//  AuthCoordinatorTests.swift
//  Social_Media_App_UIkitTests
//
//  Created by aplle on 4/27/26.
//

import Testing
import UIKit
@testable import Social_Media_App_UIkit


@MainActor
struct AuthCoordinatorTests {

    @Test func start_shows_welcome_when_not_seen() async throws {
       let mockNav = NavigationControllerSpy()
        let mockOnboarding = OnboardingServiceMock(hasSeenWelcome: false)
    
        let sut = AuthCoordinator(navigationController: mockNav, dependencies: .init(onboardingService: mockOnboarding, authService: LoginViewModelMockAuthService(), socialAuthService: LoginViewModelMockSocialAuthService()))
        
        sut.start(animated: false)
        
        #expect(mockNav.setViewControllersCalls.count == 1)
        #expect(mockNav.setViewControllersCalls.first?.first is WelcomeViewController)
        #expect(mockNav.viewControllers.first is WelcomeViewController)
        
    }
    @Test func start_shows_login_when_seen() async throws {
       let mockNav = NavigationControllerSpy()
        let mockOnboarding = OnboardingServiceMock(hasSeenWelcome: true)
    
        let sut = AuthCoordinator(navigationController: mockNav, dependencies: .init(onboardingService: mockOnboarding, authService: LoginViewModelMockAuthService(), socialAuthService: LoginViewModelMockSocialAuthService()))
        
        sut.start(animated: false)
        
        #expect(mockNav.setViewControllersCalls.count == 1)
        #expect(mockNav.setViewControllersCalls.first?.first is LoginViewController)
        #expect(mockNav.viewControllers.first is LoginViewController)
        
    }
    @Test func unlockingWelcomeMarksOnboarding_seenAndGoesToLogin() async throws {
       let mockNav = NavigationControllerSpy()
        let mockOnboarding = OnboardingServiceMock(hasSeenWelcome: false)
    
        let sut = AuthCoordinator(navigationController: mockNav, dependencies: .init(onboardingService: mockOnboarding, authService: LoginViewModelMockAuthService(), socialAuthService: LoginViewModelMockSocialAuthService()))
        
        sut.start(animated: false)
        
        let welcomeVC = mockNav.viewControllers.first as? WelcomeViewController
        welcomeVC?.onUnlock?()
        
        #expect(mockNav.setViewControllersCalls.count == 2)
        #expect(mockNav.setViewControllersCalls.last?.first is LoginViewController)
        #expect(mockNav.viewControllers.first is LoginViewController)
        #expect(mockOnboarding.hasSeenWelcome == true)
        
    }
    @Test func login_route_test_register() async throws {
       let mockNav = NavigationControllerSpy()
        let mockOnboarding = OnboardingServiceMock(hasSeenWelcome: true)
    
        let sut = AuthCoordinator(navigationController: mockNav, dependencies: .init(onboardingService: mockOnboarding, authService: LoginViewModelMockAuthService(), socialAuthService: LoginViewModelMockSocialAuthService()))
        
        sut.start(animated: false)
        
      let loginVC = mockNav.viewControllers.first as? LoginViewController
        
        #expect(loginVC != nil)
        loginVC?.viewModel.goToSignUP()
        
      try await  Task.sleep(for: .seconds(0.1))
        #expect(mockNav.pushedViewControllers.count == 1)
        #expect(mockNav.pushedViewControllers.last is RegisterViewController)
        
    }
    @Test func login_route_test_forgotPassword() async throws {
       let mockNav = NavigationControllerSpy()
        let mockOnboarding = OnboardingServiceMock(hasSeenWelcome: true)
    
        let sut = AuthCoordinator(navigationController: mockNav, dependencies: .init(onboardingService: mockOnboarding, authService: LoginViewModelMockAuthService(), socialAuthService: LoginViewModelMockSocialAuthService()))
        
        sut.start(animated: false)
        
      let loginVC = mockNav.viewControllers.first as? LoginViewController
        
        #expect(loginVC != nil)
        loginVC?.viewModel.forgotPassword()
        
      try await  Task.sleep(for: .seconds(0.1))
        #expect(mockNav.pushedViewControllers.count == 1)
        #expect(mockNav.pushedViewControllers.last is ForgetPasswordEmailViewController)
        
    }
    
    @Test func login_route_test_newPasswordScreen() async throws {
       let mockNav = NavigationControllerSpy()
        let mockOnboarding = OnboardingServiceMock(hasSeenWelcome: true)
    
        let sut = AuthCoordinator(navigationController: mockNav, dependencies: .init(onboardingService: mockOnboarding, authService: LoginViewModelMockAuthService(), socialAuthService: LoginViewModelMockSocialAuthService()))
        
        sut.start(animated: false)
    
        sut.showForgotPasswordSetNewPasswordScreen {
            
        }
        try await  Task.sleep(for: .seconds(0.1))
          #expect(mockNav.presentedViewControllerSpy is ForgotPasswordChangeVIew)
       
        
    }

}
