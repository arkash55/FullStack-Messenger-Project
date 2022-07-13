//
//  LoginViewController.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 13/04/2022.
//

import UIKit
import SafariServices

class LoginViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    

    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private let logoView: UIImageView = {
        let logoView = UIImageView()
        logoView.image = UIImage(named: "logo2")
        logoView.layer.masksToBounds = true
        return logoView
    }()
    
    private let emailField: UITextField = {
        let emailField = UITextField()
        emailField.placeholder = "Enter Email Address..."
        emailField.backgroundColor = .systemBackground
        emailField.textColor = .label
        emailField.returnKeyType = .next
        emailField.autocorrectionType = .no
        emailField.autocapitalizationType = .none
        emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        emailField.leftViewMode = .always
        emailField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        emailField.rightViewMode = .always
        emailField.layer.backgroundColor = UIColor.systemBackground.cgColor
        return emailField
    }()
    
    private let passwordField: UITextField = {
        let passwordField = UITextField()
        passwordField.placeholder = "Enter Password..."
        passwordField.backgroundColor = .systemBackground
        passwordField.textColor = .label
        passwordField.returnKeyType = .done
        passwordField.isSecureTextEntry = true
        passwordField.autocorrectionType = .no
        passwordField.autocapitalizationType = .none
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        passwordField.leftViewMode = .always
        passwordField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        passwordField.rightViewMode = .always
        passwordField.layer.backgroundColor = UIColor.systemBackground.cgColor
        return passwordField
    }()
    
    private let loginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        loginButton.layer.backgroundColor = UIColor.link.cgColor
        loginButton.layer.borderWidth = 1.0
        loginButton.layer.borderColor = UIColor.link.cgColor
        loginButton.layer.cornerRadius = 8.0
        return loginButton
    }()
    
    private let createAccountButton: UIButton = {
        let createAccountButton = UIButton()
        createAccountButton.setTitle("New User? Click here to sign up!", for: .normal)
        createAccountButton.setTitleColor(.label, for: .normal)
        createAccountButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        return createAccountButton
    }()
    
    private let termsButton: UIButton = {
        let termsButton = UIButton()
        termsButton.setTitle("Terms Of Service", for: .normal)
        termsButton.setTitleColor(.label, for: .normal)
        termsButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        termsButton.layer.masksToBounds = true
        return termsButton
    }()
    
    private let privacyButton: UIButton = {
        let privacyButton = UIButton()
        privacyButton.setTitle("Privacy Policies", for: .normal)
        privacyButton.setTitleColor(.label, for: .normal)
        privacyButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        return privacyButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureSubviews()
        configureDelegates()
        configureTargets()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let logoSize = view.frame.size.width/2.5
        let fieldWidth = view.frame.size.width/1.25
        let fieldHeight: CGFloat = 50
        let loginWidth = view.frame.width/2.5
        let basicButtonWidth = view.frame.size.width
        
        scrollView.frame = view.bounds
        
        logoView.frame = CGRect(x: view.frame.midX - logoSize/2,
                                y: view.safeAreaInsets.top + 35,
                                width: logoSize,
                                height: logoSize)
        
        emailField.frame = CGRect(x: view.frame.midX - fieldWidth/2,
                                  y: logoView.frame.maxY + 50,
                                  width: fieldWidth,
                                  height: fieldHeight)
        emailField.addUnderline()
        
        passwordField.frame = CGRect(x: view.frame.midX - fieldWidth/2,
                                     y: emailField.frame.maxY + 10,
                                     width: fieldWidth,
                                     height: fieldHeight)
        passwordField.addUnderline()
        
        

        loginButton.frame = CGRect(x: view.frame.midX - loginWidth/2,
                                   y: passwordField.frame.maxY + 30,
                                   width: loginWidth,
                                   height: 40)
        

        createAccountButton.frame = CGRect(x: view.frame.midX - basicButtonWidth/2,
                                           y: loginButton.frame.maxY + 10,
                                           width: basicButtonWidth,
                                           height: 30)
        
        termsButton.frame = CGRect(x: view.frame.midX - basicButtonWidth/2,
                                   y: createAccountButton.frame.maxY + 145,
                                   width: basicButtonWidth,
                                   height: 30)

        
        privacyButton.frame = CGRect(x: view.frame.midX - basicButtonWidth/2,
                                     y: termsButton.frame.maxY + 10,
                                     width: basicButtonWidth,
                                     height: 30)
        
        
    }
    
    
    
    //methods
    private func configureSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(logoView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(createAccountButton)
        scrollView.addSubview(termsButton)
        scrollView.addSubview(privacyButton)
    }
    
    private func configureDelegates() {
        scrollView.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    private func openLink(urlType: LoginButtonOptions) {
        var urlString = ""
        switch urlType {
        case .term:
            urlString = "https://en-gb.facebook.com/legal/terms"
        case .privacy:
            urlString = "https://en-gb.facebook.com/policy.php"
        case .help:
            break
        }
        guard let url = URL(string: urlString) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    private func configureTargets() {
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccountButton), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTermsButton), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapPrivacyButton), for: .touchUpInside)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            didTapLoginButton()
        }
        return true
    }
    
    private func resignKeyboards() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    private func getFieldValues() -> LoginModel? {
        guard let email = emailField.text?.replacingOccurrences(of: " ", with: ""), !email.isEmpty,
              let password = passwordField.text?.replacingOccurrences(of: " ", with: ""), !password.isEmpty else {
                  AlertManager.shared.showErrorAlert(vc: self, title: "Could not Login User", message: "Please fill in all fields")
                  return nil
              }
        return LoginModel(email: email, password: password)
    }

    
    
    //@objc methods
    @objc private func didTapTermsButton() {
        self.openLink(urlType: .term)
    }
    
    @objc private func didTapPrivacyButton() {
        self.openLink(urlType: .privacy)
    }
    
    @objc private func didTapCreateAccountButton() {
        let vc = RegistrationViewController()
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .popover
        vc.completion = { [weak self] in
            print("completion")
            self?.dismiss(animated: true, completion: nil)
        }
        present(navVc, animated: true, completion: nil)
    }
    
    
    
    @objc private func didTapLoginButton() {
        resignKeyboards()
        guard let loginModel = getFieldValues() else {return}
        
        AuthManager.shared.loginUser(user: loginModel) { [weak self] result in
            guard let strongSelf = self else {return}
            switch result {
            case .success(_):
                let name = Notification.Name(NotificationKeyNameString.signIn)
                NotificationCenter.default.post(name: name, object: nil)
                DispatchQueue.main.async {
                    self?.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                switch error {
                case AuthError.user_not_verified:
                    DispatchQueue.main.async {
                        AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Could not Login User", message: "User email has not been verified")
                    }
                case AuthError.incorrect_password:
                    DispatchQueue.main.async {
                        AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Could not Login User", message: "Incorrect Password")
                    }
                case AuthError.user_does_not_exist:
                    DispatchQueue.main.async {
                        AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Could not Login User", message: "Email address is not associated to an account")
                    }
                default:
                    DispatchQueue.main.async {
                        AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Something went wrong", message: "Could not Login User")
                    }
                }
            }
        }
        
    }
    
    
    


}


