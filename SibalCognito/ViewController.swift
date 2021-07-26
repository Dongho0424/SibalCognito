//
//  ViewController.swift
//  SibalCognito
//
//  Created by 최동호 on 2021/07/25.
//

import UIKit
import Amplify
import AWSCognitoAuthPlugin

class ViewController: UIViewController {

    let id$ = "dongho"
    let password$ = "HwlnA5>p"
    
    let userName$ = "test5username"
    let newPassWord$ = "asd123!@#"
    
    let idTextField = UITextField()
    let pwTextField = UITextField()
    let loginButton = UIButton(type: .roundedRect)
    
    let verificationCodeTextField = UITextField()
    let getCodeButton = UIButton(type: .roundedRect)
    let verificationButton = UIButton(type: .roundedRect)
    
    let signOut = UIButton(type: .system)
    let attributes = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(signOut)
        signOut.frame = CGRect(x: view.center.x, y: 50, width: 100, height: 100)
        signOut.center.x = view.center.x
        signOut.setTitle("signOut", for: .normal)
        signOut.setTitleColor(.label, for: .normal)
        signOut.addTarget(self, action: #selector(signOut(_:)), for: .touchUpInside)
        
        view.addSubview(attributes)
        attributes.frame = CGRect(x: 0, y: 50, width: 100, height: 100)
        attributes.setTitle("getAttributes", for: .normal)
        attributes.setTitleColor(.label, for: .normal)
        attributes.addTarget(self, action: #selector(getAttributes(_:)), for: .touchUpInside)
        
        view.addSubview(idTextField)
        idTextField.frame = CGRect(x: 0, y: 200, width: 100, height: 50)
        idTextField.center.x = view.center.x
        idTextField.borderStyle = .line
        idTextField.placeholder = "id"
        idTextField.autocapitalizationType = .none
        
        view.addSubview(pwTextField)
        pwTextField.frame = CGRect(x: view.center.x, y: 300, width: 100, height: 50)
        pwTextField.center.x = view.center.x
        pwTextField.borderStyle = .line
        pwTextField.placeholder = "pw"
        pwTextField.autocapitalizationType = .none
        
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: view.center.x, y: 400, width: 100, height: 100)
        loginButton.center.x = view.center.x
        loginButton.setTitle("login", for: .normal)
        loginButton.setTitleColor(.label, for: .normal)
        loginButton.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
        
        view.addSubview(verificationCodeTextField)
        verificationCodeTextField.frame = CGRect(x: view.center.x, y: 500, width: 300, height: 50)
        verificationCodeTextField.center.x = view.center.x
        verificationCodeTextField.borderStyle = .line
        verificationCodeTextField.placeholder = "verificationCodeTextField"
        verificationCodeTextField.autocapitalizationType = .none
        
        view.addSubview(getCodeButton)
        getCodeButton.frame = CGRect(x: view.center.x, y: 600, width: 200, height: 100)
        getCodeButton.center.x = view.center.x
        getCodeButton.setTitle("getCodeButton", for: .normal)
        getCodeButton.setTitleColor(.label, for: .normal)
        getCodeButton.addTarget(self, action: #selector(getCode(_:)), for: .touchUpInside)
        
        view.addSubview(verificationButton)
        verificationButton.frame = CGRect(x: view.center.x, y: 700, width: 200, height: 100)
        verificationButton.center.x = view.center.x
        verificationButton.setTitle("verificationButton", for: .normal)
        verificationButton.setTitleColor(.label, for: .normal)
        verificationButton.addTarget(self, action: #selector(confirmResetPW(_:)), for: .touchUpInside)
    }
    
    @objc func login(_ sender: Any) {
        // 3. signIn
        signIn(username: userName$, password: newPassWord$)
    }
    
    @objc func getCode(_ sender: Any) {
        // 1. reset Password
        resetPassword(username: userName$)
    }
    
    @objc func confirmResetPW(_ sender: Any) {
        // 2. confirmResetPassword
        confirmResetPassword(username: userName$, newPassword: newPassWord$, confirmationCode: verificationCodeTextField.text ?? "")
    }
    
    @objc func signOut(_ sender: Any) {
        // signOut
        signOutLocally()
    }
    
    @objc func getAttributes(_ sender: Any) {
        // getAttributes
        fetchAttributes()
    }
    
    func signUp(username: String, password: String, name: String) {
        let userAttributes = [AuthUserAttribute(.name, value: name)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        Amplify.Auth.signUp(username: username, password: password, options: options) { result in
            switch result {
            case .success(let signUpResult):
                if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                    print("Delivery details \(String(describing: deliveryDetails))")
                } else {
                    print("SignUp Complete")
                }
            case .failure(let error):
                print("An error occurred while registering a user \(error)")
            }
        }
    }
    
    func fetchCurrentAuthSession() {
        _ = Amplify.Auth.fetchAuthSession { result in
            
//            do {
//                let res = try result.get()
//
//                print(res)
//                print(res.isSignedIn)
//            } catch let error {
//                print(error)
//            }
            
            switch result {
            case .success(let session):
                print("Is user signed in - \(session.isSignedIn)")
            case .failure(let error):
                print("Fetch session failed with error \(error)")
            }
        }
    }
    
    func signIn(username: String, password: String) {
        Amplify.Auth.signIn(username: username, password: password) { result in
            switch result {
            case .success:
                print("Sign in succeeded")
            case .failure(let error):
                print("Sign in failed \(error)")
            }
            
            
            self.fetchCurrentAuthSession()
            
            print(); print()
            
            do {
                let a = try result.get()
                
                print("result:get(): \(a)")
            } catch let error {
                print("error: \(error)")
            }
        }
    }
    
    func resetPassword(username: String) {
        Amplify.Auth.resetPassword(for: username) { result in
            do {
                let resetResult = try result.get()
                switch resetResult.nextStep {
                case .confirmResetPasswordWithCode(let deliveryDetails, let info):
                    print("Confirm reset password with code send to - \(deliveryDetails) \(info)")
                    
                    
                case .done:
                    print("Reset completed")
                }
            } catch {
                print("Reset password failed with error \(error)")
            }
        }
    }
    
    func confirmResetPassword(
        username: String,
        newPassword: String,
        confirmationCode: String
    ) {
        Amplify.Auth.confirmResetPassword(
            for: username,
            with: newPassword,
            confirmationCode: confirmationCode
        ) { result in
            switch result {
            case .success:
                print("Password reset confirmed")
            case .failure(let error):
                print("Reset password failed with error \(error)")
            }
        }
    }
    
    func signOutLocally() {
        Amplify.Auth.signOut() { result in
            switch result {
            case .success:
                print("Successfully signed out")
            case .failure(let error):
                print("Sign out failed with error \(error)")
            }
        }
    }
    
    func fetchAttributes() {
        Amplify.Auth.fetchUserAttributes() { result in
            switch result {
            case .success(let attributes):
                print("User attributes - \(attributes)")
            case .failure(let error):
                print("Fetching user attributes failed with error \(error)")
            }
        }
    }

}

