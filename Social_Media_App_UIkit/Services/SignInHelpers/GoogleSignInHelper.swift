//
//  GoogleSignInHelper.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/25/25.
//

import UIKit
import GoogleSignIn
final class GoogleSignInHelper:NSObject{
    static var shared: GoogleSignInHelper = .init()
    private override init() {}
    
    
    
    func startGoogleSignIn(viewController: UIViewController,completion: @escaping (Result<String, Error>)->Void) {
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) {signInResult, error in
            guard error == nil else {   completion(.failure(NSError(domain: "Google sign in", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error signing in with Google \(String(describing: error))"])));return }
           
            guard let user = signInResult?.user,let idToken = user.idToken else{
                completion(.failure(LoginError.defaultError))
                print("cant get user or id token")
                return
            }
            completion(.success(idToken.tokenString))
          }
    }
}
