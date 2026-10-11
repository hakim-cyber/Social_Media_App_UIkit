import Testing
import UIKit
@testable import Social_Media_App_UIkit

@MainActor
struct OnboardingSetupTests {
    @Test func nextWithUntouchedOptionalNameSubmitsNormalizedUsername() async throws {
        let service = MainStartResolverMockProfileService()
        let model = OnboardingSetupViewModel(
            profileService: service,
            userNameValidator: UsernameValidator(api: MockUsernameAPI(result: .success(true)))
        )
        let screen = ProfileInfoSetupView(viewModel: model)
        screen.loadViewIfNeeded()
        screen.userNameTextField.textField.text = " @New_User "
        screen.handleNext()
        for _ in 0..<100 where service.createdUsername == nil {
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(service.createdUsername == "new_user")
        #expect(service.createdFullName == "")
    }

    @Test func nextWithInvalidNameShowsErrorWithoutCreatingProfile() {
        let service = MainStartResolverMockProfileService()
        let model = OnboardingSetupViewModel(
            profileService: service,
            userNameValidator: UsernameValidator(api: MockUsernameAPI(result: .success(true)))
        )
        let screen = ProfileInfoSetupView(viewModel: model)
        screen.loadViewIfNeeded()
        screen.userNameTextField.textField.text = "new_user"
        screen.nameTextField.textField.text = "123"
        screen.handleNext()
        #expect(model.error == "Name must be 2–40 letters, only letters/spaces.")
        #expect(service.createdUsername == nil)
    }

    @Test func cancelledUsernameCheckDoesNotReplaceCurrentError() async {
        let model = OnboardingSetupViewModel(
            profileService: MainStartResolverMockProfileService(),
            userNameValidator: UsernameValidator(api: MockUsernameAPI(result: .success(true)))
        )
        model.error = "Current error"
        let check = Task { await model.checkUsername(userName: "new_user") }
        check.cancel()
        #expect(await check.value == false)
        #expect(model.error == "Current error")
    }
}
