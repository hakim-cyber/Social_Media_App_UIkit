//
//  UsernameValidatorTests.swift
//  Social_Media_App_UIkitTests
//
//  Created by aplle on 4/25/26.
//

import Testing
@testable import Social_Media_App_UIkit

struct UsernameValidatorTests {
    @Test("Validation fails when username is short")
    func validatorFailsForShortUsername()async{
        let sut = await UsernameValidator(api: MockUsernameAPI(result: .success(true)))
        
        let (success, error) = await sut.validate("a")
        
        #expect(!success)
        #expect(error == .usernameShort)
    }
    @Test("Validation fails when username is long")
    func validatorFailsForlongUsername()async{
        let sut = await UsernameValidator(api: MockUsernameAPI(result: .success(true)))
        
        let (success, error) = await sut.validate("123456789123456789123456789123")
        
        #expect(!success)
        #expect(error == .usernameTooLong)
    }
    @Test("Validation fails when username has invalid characters")
    func validatorFailsInvalidCharacters()async{
        let sut = await UsernameValidator(api: MockUsernameAPI(result: .success(true)))
        
        let (success, error) = await sut.validate("hakim#$$%#@@")
        
        #expect(!success)
        #expect(error == .usernameInvalidCharacter)
    }
    
    @Test
    func validate_succeeds_whenAvailable() async {
        
        let sut = await UsernameValidator(api: MockUsernameAPI(result: .success(true)))
        
        let result = await sut.validate("validUser")
        
        #expect(result.0 == true)
        
        #expect(result.1 == nil)
        
    }
    
    @Test
    func validate_fails_whenTaken() async {
        
        let sut = await UsernameValidator(api: MockUsernameAPI(result: .success(false)))
        
        let result = await sut.validate("validUser")
        
        #expect(result.0 == false)
        
        #expect(result.1 == .usernameTaken)
        
    }
    
    @Test
    func validate_fails_Api_Error() async {
        struct TestError: Error {}
        let sut = await UsernameValidator(api: MockUsernameAPI(result: .failure(TestError())))
        
        let result = await sut.validate("validUser")
        
        #expect(result.0 == false)
        
        #expect(result.1 == .usernameCheckErorr)
        
    }
    
}
