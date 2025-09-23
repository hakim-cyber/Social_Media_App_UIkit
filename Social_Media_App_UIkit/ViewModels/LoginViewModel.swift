//
//  LoginViewModel.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 9/23/25.
//

import UIKit
import Combine
class LoginViewModel:ObservableObject{
    @Published var email:String = ""
    @Published var password:String = ""
    
    @Published var isLoading:Bool = false
    @Published var shpwPassword:Bool = false
    
    
}
