//
//  ProfileViewController.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 15/04/2022.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    
    public var completion: (() -> Void)?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UserProfileTableViewCell.self, forCellReuseIdentifier: UserProfileTableViewCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private var sectionHeaderView = UIView()
    
    private let picker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.mediaTypes = ["public.image"]
        picker.allowsEditing = true
        return picker
    }()
    
    private var originalProfileImage: UIImage!
    
    private let header1Label: UILabel = {
        let header1Label = UILabel()
        header1Label.text = "Edit User Details"
        header1Label.font = .systemFont(ofSize: 15, weight: .bold)
        header1Label.textColor = .secondaryLabel
        return header1Label
    }()
    
    private let header1Icon: UIImageView = {
        let header1Icon = UIImageView()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .default)
        let iconImage = UIImage(systemName: "pencil.and.outline")?.withConfiguration(imageConfig).withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal)
        header1Icon.image = iconImage
        return header1Icon
    }()
    
    private let profileView: UIImageView = {
        let profileView = UIImageView()
        profileView.image = UIImage(systemName: "person.circle")
        profileView.image = UIImage(named: "real-person")
        profileView.tintColor = .link
        profileView.layer.borderWidth = 2.0
        profileView.layer.borderColor = UIColor.link.cgColor
        profileView.layer.masksToBounds = true
        return profileView
    }()
    
    private var user: UserProfile
    
    private var updatedUser: UpdateUserProfileModel?
    
    private var models = [UserProfileModel]()

    init(userData: UserProfile) {
        self.user = userData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureTableView()
        configureProfileGesture()
        loadData()
        downloadProfilePic()
        picker.delegate = self
        originalProfileImage = profileView.image
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        originalProfileImage = profileView.image
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        guard let tableHeaderView = tableView.tableHeaderView else {return}
        let profileSize = tableHeaderView.frame.size.width/2.2
        profileView.frame = CGRect(x: tableHeaderView.frame.midX - profileSize/2,
                                   y: tableHeaderView.frame.midY - profileSize/2,
                                   width: profileSize,
                                   height: profileSize)

        profileView.layer.cornerRadius = profileSize/2
        
        
        sectionHeaderView.frame = CGRect(x: 0,
                                         y: 0,
                                         width: view.frame.size.width,
                                         height: 40)

        
        let labelHeight = sectionHeaderView.frame.size.height/2
        header1Label.frame = CGRect(x: 10,
                                    y: sectionHeaderView.frame.midY - labelHeight/2,
                                    width: sectionHeaderView.frame.size.width/3,
                                    height: labelHeight)
        
        
        let iconSize = header1Label.frame.size.height/1.1
        header1Icon.frame = CGRect(x: header1Label.frame.maxX,
                                   y: sectionHeaderView.frame.midY - iconSize/2,
                                   width: iconSize,
                                   height: iconSize)
        
    }
    
    
    
    
    //methods

    private func configureNavigationBar() {
        navigationItem.title = "Profile"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSaveButton))
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = configureTableHeaderView()
    }
    

    private func configureTableHeaderView() -> UIView {
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height/4))
        tableHeaderView.addSubview(profileView)
        return tableHeaderView
    }
    
    private func configureSectionHeaderView() -> UIView {
        sectionHeaderView.backgroundColor = .systemBackground
        sectionHeaderView.addSubview(header1Label)
        sectionHeaderView.addSubview(header1Icon)
        return sectionHeaderView
    }
    
    private func loadData() {
        models.append(UserProfileModel(title: "Email", value: user.email, handler: nil))
        models.append(UserProfileModel(title: "Username", value: user.username, handler: nil))
        models.append(UserProfileModel(title: "First Name", value: user.first_name, handler: nil))
        models.append(UserProfileModel(title: "Last Name", value: user.last_name, handler: nil))
    }
    
    private func configureProfileGesture() {
        let gesture = UITapGestureRecognizer()
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        gesture.addTarget(self, action: #selector(didTapProfileView))
        profileView.addGestureRecognizer(gesture)
        profileView.isUserInteractionEnabled = true
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
            self?.picker.sourceType = .camera
            self?.present(strongSelf.picker, animated: true, completion: nil)

        }))
        actionSheet.addAction(UIAlertAction(title: "Choose from library",
                                            style: .default,
                                            handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            self?.picker.sourceType = .photoLibrary
            self?.present(strongSelf.picker, animated: true, completion: nil)
        }))
        

        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.popoverPresentationController?.sourceView = view
        actionSheet.popoverPresentationController?.sourceRect = view.bounds
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    private func uploadProfilePicture() {
        DispatchQueue.main.async {
            guard let profileImage = self.profileView.image else {
                print("image failed")
                return
            }
                
            StorageManager.shared.uploadProfilePicture(email: self.user.email, profile_image: profileImage) { result in
                switch result {
                case .success(let imageKey):
                    UserDefaults.standard.set(imageKey, forKey: "profile_pic_key")
                case .failure(_):
                    DispatchQueue.main.async {
                        AlertManager.shared.showErrorAlert(vc: self, title: "Something went wrong...", message: "Could not upload Profile Picture")
                    }
                }
            }
        }
        

    }
    
    
    
    
    private func downloadProfilePic() {
        let imageKey = user.profile_pic_key
        guard let imageUrl = UtilManager.shared.convertToAWSUrl(mediaKey: imageKey) else {
            return
        }
        DispatchQueue.main.async {
            self.profileView.sd_setImage(with: imageUrl, completed: nil)
        }
    }
    
    private func checkForUserDataAlteraion(_ new_data: UpdateUserProfileModel) -> Bool? {
        var hasChanged: Bool = false
        guard let uid = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let username = UserDefaults.standard.value(forKey: "username") as? String,
              let first_name = UserDefaults.standard.value(forKey: "first_name") as? String,
              let last_name = UserDefaults.standard.value(forKey: "last_name") as? String,
              let profilePicKey = UserDefaults.standard.value(forKey: "profile_pic_key") as? String  else {
                  print("no cache in check for user data alterations")
                  return nil
              }
        
        let old_data = UpdateUserProfileModel(id: uid, username: username, first_name: first_name, last_name: last_name, profile_pic_key: profilePicKey)
        if new_data != old_data {
            hasChanged = true
            return hasChanged
        }
        
        //check if profile pic has changed
        if originalProfileImage == profileView.image {
            hasChanged = true
            return hasChanged
        }
        return hasChanged
    }
    
    
    
    //@objc methods
    @objc private func didTapSaveButton() {
        guard let updatedUser = updatedUser else {
            print("failed to get updated data")
            return
        }
        
        //check if data has been chaanged
        guard let hasChanged = checkForUserDataAlteraion(updatedUser), hasChanged == true else {
            DispatchQueue.main.async {
                AlertManager.shared.showErrorAlert(vc: self, title: "Something went wrong...", message: "No changes have been made")
            }
            return
        }
        
        UserManager.shared.updateUserData(updatedUserModel: updatedUser) { [weak self] result in
            switch result {
            case .success(_):
                self?.uploadProfilePicture()
                DispatchQueue.main.async {
                    self?.downloadProfilePic()
                }
                self?.completion?()
            case .failure(let error):
                print(error)
                guard let strongSelf = self else {return}
                DispatchQueue.main.async {
                    AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Something went wrong...", message: "Could not update user details.")
                }
            }
        }
        
    }
    

    

}




extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let profileImage = info[.editedImage] as? UIImage else {return}
        DispatchQueue.main.async {self.profileView.image = profileImage}
    }
    
}












extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return configureSectionHeaderView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UserProfileTableViewCell.identifier,
                                                 for: indexPath) as! UserProfileTableViewCell
        cell.delegate = self
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}




extension ProfileViewController: UserProfileCellDelegate {
    func didUpdateField(_ cell: UserProfileTableViewCell, updatedModel: UserProfileModel) {
        
        if updatedModel.title == "Username" {
            self.user.username = updatedModel.value
        } else if updatedModel.title == "First Name" {
            self.user.first_name = updatedModel.value
        } else if updatedModel.title == "Last Name" {
            self.user.last_name = updatedModel.value
        }
        

        
        let updatedProfileModel = UpdateUserProfileModel(id: user.id, username: user.username, first_name: user.first_name, last_name: user.last_name, profile_pic_key: user.profile_pic_key)
        self.updatedUser = updatedProfileModel
    }
}
