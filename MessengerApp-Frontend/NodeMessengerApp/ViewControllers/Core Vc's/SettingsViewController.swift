//
//  ProfileViewController.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 13/04/2022.
//

import UIKit
import SafariServices



class SettingsViewController: UIViewController {

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView.register(BasicTableViewCell.self, forCellReuseIdentifier: BasicTableViewCell.identifier)
        return tableView
    }()
    
    private var models = [[SettingsModel]]()
    
    private var hasFetched = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureTableView()
        createObservers()
        if hasFetched == false {fetchData()}
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hasFetched == false {fetchData()}
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Settings"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func createObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didLogOut),
                                               name: NSNotification.Name(NotificationKeyNameString.logOut),
                                               object: nil)
        
    }
        
    
    private func getUserData() -> UserProfile? {
        guard let user_id = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let username = UserDefaults.standard.value(forKey: "username") as? String,
              let email = UserDefaults.standard.value(forKey: "email") as? String,
              let first_name = UserDefaults.standard.value(forKey: "first_name") as? String,
              let last_name = UserDefaults.standard.value(forKey: "last_name") as? String,
              let profile_pic_key = UserDefaults.standard.value(forKey: "profile_pic_key") as? String else {
                  return nil
              }
        return UserProfile(id: user_id, username: username, first_name: first_name, last_name: last_name, email: email, profile_pic_key: profile_pic_key)
    }
    
    
    private func fetchData() {
        models.removeAll()
        guard let userProfileData = getUserData() else {return}
        
        models.append([SettingsModel(type: SettingCellType.profile(data: userProfileData),
                                     handler: { [weak self] in
            guard let userData = self?.getUserData() else {return}
            let vc = ProfileViewController(userData: userData)
            vc.modalPresentationStyle = .fullScreen
            self?.navigationController?.pushViewController(vc, animated: true)
            vc.completion = { [weak self] in
                self?.hasFetched = false
            }
        })])
        
        models.append([
            SettingsModel(type: .basic(data: BasicSettingsModel(iconImage: UIImage(systemName: "person.crop.circle")!,
                                                                title: "My Account")),
                          handler: { [weak self] in
                              let vc = MyAccountViewController()
                              vc.modalPresentationStyle = .fullScreen
                              self?.navigationController?.pushViewController(vc, animated: true)
                          }),
            
            
            SettingsModel(type: .basic(data: BasicSettingsModel(iconImage: UIImage(systemName: "bell")!,
                                                                title: "Notifications")),
                          handler: nil)
            
        ])
        
        
        
        models.append([
            SettingsModel(type: .basic(data: BasicSettingsModel(iconImage: UIImage(systemName: "suit.heart")!,
                                                                title: "Help")),
                          handler: { [weak self] in
                              self?.openUrl(urlType: .help)
                          }),
            SettingsModel(type: .basic(data: BasicSettingsModel(iconImage: UIImage(systemName: "highlighter")!,
                                                                title: "Terms Of Service")),
                          handler: { [weak self] in
                              self?.openUrl(urlType: .term)
                          }),
            SettingsModel(type: .basic(data: BasicSettingsModel(iconImage: UIImage(systemName: "hand.raised")!,
                                                                title: "Privacy Policies")),
                          handler: { [weak self] in
                              self?.openUrl(urlType: .privacy)
                          })
        ])
        hasFetched = true
        tableView.reloadData()
        
    }
    
    
    private func openUrl(urlType: LoginButtonOptions) {
        var urlString = ""
        switch urlType {
        case .term:
            urlString = "https://en-gb.facebook.com/legal/terms"
        case .privacy:
            urlString = "https://en-gb.facebook.com/policy.php"
        case .help:
            urlString = "https://www.facebook.com/help/1126628984024935"
        }
        guard let url = URL(string: urlString) else {
            return
        }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
    
    //@objc methods
    @objc private func didLogOut() {
        self.hasFetched = false
    }
    



}



extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.section][indexPath.row]
        model.handler?()
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = models[indexPath.section][indexPath.row]
        switch model.type {
        case .profile(_):
            return 100
        case .basic(_):
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section][indexPath.row]
        switch model.type {
        case .profile(_):
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
            cell.accessoryType = .detailButton
            cell.configure(with: model)
            cell.selectionStyle = .gray
            return cell
        case .basic(_):
            let cell = tableView.dequeueReusableCell(withIdentifier: BasicTableViewCell.identifier, for: indexPath) as! BasicTableViewCell
            cell.configure(with: model)
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
            return cell
        }
    }
    
}
