//
//  RegistrationViewController.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 13/04/2022.
//

import UIKit

class RegistrationViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    public var completion: (() -> Void)?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private let imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.allowsEditing = true
        return imagePicker
    }()
    
    private let profileView: UIImageView = {
        let profileView = UIImageView()
        profileView.image = UIImage(systemName: "person.circle")
        profileView.tintColor = .link
        profileView.layer.borderWidth = 1.0
        profileView.layer.borderColor = UIColor.link.cgColor
        profileView.layer.masksToBounds = true
        return profileView
    }()
    
    private let usernameField: UITextField = {
        let usernameField = UITextField()
        usernameField.placeholder = "Enter Username..."
        usernameField.backgroundColor = .systemBackground
        usernameField.textColor = .label
        usernameField.returnKeyType = .next
        usernameField.autocorrectionType = .no
        usernameField.autocapitalizationType = .none
        usernameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        usernameField.leftViewMode = .always
        usernameField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        usernameField.rightViewMode = .always
        usernameField.layer.backgroundColor = UIColor.systemBackground.cgColor
        return usernameField
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
    
    private let firstNameField: UITextField = {
        let firstNameField = UITextField()
        firstNameField.placeholder = "Enter First Name..."
        firstNameField.backgroundColor = .systemBackground
        firstNameField.textColor = .label
        firstNameField.returnKeyType = .next
        firstNameField.autocorrectionType = .no
        firstNameField.autocapitalizationType = .none
        firstNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        firstNameField.leftViewMode = .always
        firstNameField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        firstNameField.rightViewMode = .always
        firstNameField.layer.backgroundColor = UIColor.systemBackground.cgColor
        return firstNameField
    }()
    
    private let lastNameField: UITextField = {
        let lastNameField = UITextField()
        lastNameField.placeholder = "Enter Last Name..."
        lastNameField.backgroundColor = .systemBackground
        lastNameField.textColor = .label
        lastNameField.returnKeyType = .next
        lastNameField.autocorrectionType = .no
        lastNameField.autocapitalizationType = .none
        lastNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        lastNameField.leftViewMode = .always
        lastNameField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        lastNameField.rightViewMode = .always
        lastNameField.layer.backgroundColor = UIColor.systemBackground.cgColor
        return lastNameField
    }()
    
    
    private let passwordField: UITextField = {
        let passwordField = UITextField()
        passwordField.placeholder = "Enter Password..."
        passwordField.backgroundColor = .systemBackground
        passwordField.textColor = .label
        passwordField.returnKeyType = .next
        passwordField.autocorrectionType = .no
        passwordField.autocapitalizationType = .none
        passwordField.isSecureTextEntry = true
        passwordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        passwordField.leftViewMode = .always
        passwordField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        passwordField.rightViewMode = .always
        passwordField.layer.backgroundColor = UIColor.systemBackground.cgColor
        return passwordField
    }()
    
    private let confirmPasswordField: UITextField = {
        let confirmPasswordField = UITextField()
        confirmPasswordField.placeholder = "Confirm Password..."
        confirmPasswordField.backgroundColor = .systemBackground
        confirmPasswordField.textColor = .label
        confirmPasswordField.returnKeyType = .done
        confirmPasswordField.autocorrectionType = .no
        confirmPasswordField.autocapitalizationType = .none
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        confirmPasswordField.leftViewMode = .always
        confirmPasswordField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        confirmPasswordField.rightViewMode = .always
        confirmPasswordField.layer.backgroundColor = UIColor.systemBackground.cgColor
        return confirmPasswordField
    }()
    
    private let registerButton: UIButton = {
        let registerButton = UIButton()
        registerButton.setTitle("Register", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        registerButton.layer.backgroundColor = UIColor.link.cgColor
        registerButton.layer.borderWidth = 1.0
        registerButton.layer.borderColor = UIColor.link.cgColor
        registerButton.layer.cornerRadius = 8.0
        return registerButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureSubviews()
        configureTargets()
        configureDelegates()
        configureProfileViewGesture()
        configureNavigationBar()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let profileSize = view.frame.size.width/2.5
        let fieldWidth = view.frame.size.width/1.25
        let fieldHeight: CGFloat = 50
        let registerWidth = view.frame.width/2.5
        
        scrollView.frame = view.bounds
        
        profileView.frame = CGRect(x: view.frame.midX - profileSize/2,
                                   y: view.safeAreaInsets.top,
                                   width: profileSize,
                                   height: profileSize)
        profileView.layer.cornerRadius =  profileSize/2

        usernameField.frame = CGRect(x: view.frame.midX - fieldWidth/2,
                                     y: profileView.frame.maxY + 40,
                                     width: fieldWidth,
                                     height: fieldHeight)
        
        
        emailField.frame = CGRect(x: view.frame.midX - fieldWidth/2,
                                  y: usernameField.frame.maxY + 10,
                                  width: fieldWidth,
                                  height: fieldHeight)
        
        firstNameField.frame = CGRect(x: view.frame.midX - fieldWidth/2,
                                      y: emailField.frame.maxY + 10,
                                      width: fieldWidth,
                                      height: fieldHeight)
        
        lastNameField.frame = CGRect(x: view.frame.midX - fieldWidth/2,
                                     y: firstNameField.frame.maxY + 10,
                                     width: fieldWidth,
                                     height: fieldHeight)
        
        
        
        passwordField.frame = CGRect(x: view.frame.midX - fieldWidth/2,
                                     y: lastNameField.frame.maxY + 10,
                                     width: fieldWidth,
                                     height: fieldHeight)
        
        
        confirmPasswordField.frame = CGRect(x: view.frame.midX - fieldWidth/2,
                                            y: passwordField.frame.maxY + 10,
                                            width: fieldWidth,
                                            height: fieldHeight)
        
        registerButton.frame = CGRect(x: view.frame.midX - registerWidth/2,
                                   y: confirmPasswordField.frame.maxY + 40,
                                   width: registerWidth,
                                   height: 40)
        configureCustomTextField()
    }
    
    
    
    //methods
    private func configureNavigationBar() {
        navigationItem.title = "Create an Account"
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
    }
    
    @objc private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    
    private func configureSubviews() {
        view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: view.frame.size.height*1.3)
        scrollView.addSubview(profileView)
        scrollView.addSubview(usernameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(confirmPasswordField)
        scrollView.addSubview(registerButton)
    }
    
    private func configureTargets() {
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
    }
    
    private func configureDelegates() {
        scrollView.delegate = self
        emailField.delegate = self
        usernameField.delegate = self
        firstNameField.delegate = self
        lastNameField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        imagePicker.delegate = self
    }
    
    private func configureCustomTextField() {
        usernameField.addUnderline()
        emailField.addUnderline()
        firstNameField.addUnderline()
        lastNameField.addUnderline()
        passwordField.addUnderline()
        confirmPasswordField.addUnderline()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            firstNameField.becomeFirstResponder()
        } else if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            confirmPasswordField.becomeFirstResponder()
        } else if textField == confirmPasswordField {
            didTapRegisterButton()
        }
        return true
    }
    
    private func configureProfileViewGesture() {
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapProfileView))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        profileView.addGestureRecognizer(gesture)
        profileView.isUserInteractionEnabled = true
    }
    
    
    private func getFieldValues() -> RegisterFieldsModel? {
        guard let username = usernameField.text?.replacingOccurrences(of: " ", with: ""), !username.isEmpty,
              let email = emailField.text?.replacingOccurrences(of: " ", with: ""), !email.isEmpty,
              let first_name = firstNameField.text?.replacingOccurrences(of: " ", with: ""), !first_name.isEmpty,
              let last_name = lastNameField.text?.replacingOccurrences(of: " ", with: ""), !last_name.isEmpty,
              let password = passwordField.text?.replacingOccurrences(of: " ", with: ""), !password.isEmpty,
              let confirmPassword = confirmPasswordField.text?.replacingOccurrences(of: " ", with: ""), !confirmPassword.isEmpty else {
                  AlertManager.shared.showErrorAlert(vc: self, title: "Could not Register User", message: "Please fill in all fields")
                  return nil
              }
        return RegisterFieldsModel(username: username, email: email, first_name: first_name, last_name: last_name, confirm_password: confirmPassword, password: password)
        
    }
    
    private func validatePasswords(user: RegisterFieldsModel) -> Bool {
        if user.password != user.confirm_password {
            AlertManager.shared.showErrorAlert(vc: self, title: "Could Not Register User", message: "Password Fields do not match")
            return false
        }
        return true
    }
    
    private func validateEmail(email: String) -> Bool {
        if email.contains("@") && email.contains(".") {return true}
        AlertManager.shared.showErrorAlert(vc: self, title: "Could Not Register User", message: "Please enter a valid email")
        return false
    }
    
    private func validateProfilePic() -> Bool{
        guard let personImage = UIImage(systemName: "person.circle") else {return false}
        if profileView.image != personImage {return true}
        AlertManager.shared.showErrorAlert(vc: self, title: "Could Not Register User", message: "Please choose a profile picture")
        return false
    }
    
    //@objc methods
    @objc private func didTapProfileView() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to choose your profile picture?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            self?.imagePicker.sourceType = .camera
            self?.present(strongSelf.imagePicker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose from library",
                                            style: .default,
                                            handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            strongSelf.imagePicker.sourceType = .photoLibrary
            strongSelf.present(strongSelf.imagePicker, animated: true, completion: nil)
        }))
        

        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
    
        
        actionSheet.popoverPresentationController?.sourceView = view
        actionSheet.popoverPresentationController?.sourceRect = view.bounds
//        actionSheet.view.tintColor = .label
//        actionSheet.view.backgroundColor = .white
//        actionSheet.view.layer.cornerRadius = 15
    
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func resignFields() {
        usernameField.resignFirstResponder()
        emailField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        confirmPasswordField.resignFirstResponder()
        
    }
    
    
    @objc private func didTapRegisterButton() {
        print("did tap register")
        resignFields()
        guard let newUser = getFieldValues() else {return}

        
        if validatePasswords(user: newUser) == false {return}
        if validateEmail(email: newUser.email) == false {return}
        if validateProfilePic() == false {return}
 
        //upload data
        guard let profileImage = profileView.image else {return}
        AuthManager.shared.completeNewUserRegistration(username: newUser.username, email: newUser.email, first_name: newUser.first_name, last_name: newUser.last_name, password: newUser.password, profileImage: profileImage) {[weak self] result in
            guard let strongSelf = self else {return}
            switch result {
            case .success(_):
                let name = Notification.Name(NotificationKeyNameString.signIn)
                NotificationCenter.default.post(name: name, object: nil)
                DispatchQueue.main.async {
                    self?.dismiss(animated: true, completion: { [weak self] in
                        guard let strongSelf = self else {return}
                        strongSelf.completion?()
                    })
                }
            case .failure(let error):
                switch error {
                case RegistrationError.emailTaken:
                    print("email taken")
                    DispatchQueue.main.async {
                        AlertManager.shared.showErrorAlert(vc: self!, title: "Could not Register User", message: "Email is already associated to an account")
                    }
                case RegistrationError.usernameTaken:
                    print("username taken")
                    DispatchQueue.main.async {
                        AlertManager.shared.showErrorAlert(vc: self!, title: "Could not Register User", message: "Username is taken. Please choose another")
                    }
                default:
                    AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Something went wrong...", message: "Could Not Register User")
                }
            }
        }
        
        
    }
    


}

extension RegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let profileImage = info[.editedImage] as? UIImage else {
            return
        }
        DispatchQueue.main.async {
            self.profileView.image = profileImage
        }
    }

}
