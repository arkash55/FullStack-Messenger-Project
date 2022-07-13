//
//  MyAccountViewController.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 13/06/2022.
//

import UIKit

class MyAccountViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SignOutTableViewCell.self, forCellReuseIdentifier: SignOutTableViewCell.identifier)
        return tableView
    }()
    
    private var models = [[MyAccountModel]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureTableView()
        configureModels()
        configureNavigationBar()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
    }
    
    
    private func configureModels() {
        models.append([
            MyAccountModel(type: .standard(data: StandardCell(title: "Clear Cache")),
                           handler: nil),
            MyAccountModel(type: .standard(data: StandardCell(title: "Clear History")),
                           handler: nil),
            MyAccountModel(type: .standard(data: StandardCell(title: "Report a bug")),
                           handler: nil)
        ])
        
        
        models.append([MyAccountModel(type: .sign_out(data: SignOutModel(title: "Log Out")),
                                      handler: { [weak self] in
            print("did tap log out")
            let actionSheet = UIAlertController(title: "Sign Out",
                                                message: "Are you sure you want to sign out?",
                                                preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: nil))
            actionSheet.addAction(UIAlertAction(title: "Log Out",
                                                style: .destructive,
                                                handler: { [weak self] _ in
                self?.didTapLogOut()
            }))
            actionSheet.popoverPresentationController?.sourceView = self?.view
            actionSheet.popoverPresentationController?.sourceRect = (self?.view.bounds)!
            self?.present(actionSheet, animated: true, completion: nil)
        })])
        
        
        
    }
    
    
    //methods
    private func configureNavigationBar() {
        navigationItem.title = "My Account"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func clearUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
    
    private func didTapLogOut() {
        AuthManager.shared.logOutUser { [weak self] result in
            switch result {
            case .success(_):
                self?.clearUserDefaults()
                NotificationCenter.default.post(name: NSNotification.Name(NotificationKeyNameString.logOut), object: nil)
                DispatchQueue.main.async {
                    self?.navigationController?.popToRootViewController(animated: true)
                    self?.tabBarController?.selectedIndex = 0
                    
                }
            case .failure(let error):
                guard let strongSelf = self else {return}
                DispatchQueue.main.async {
                    AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Could not sign out user", message: "\(error)")
                }
            }
        }
    }
    
    

    

}


extension MyAccountViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section][indexPath.row]
        switch model.type {
        case .standard(let data):
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                     for: indexPath)
            cell.textLabel?.text = data.title
            return cell
        case .sign_out(_):
            let cell = tableView.dequeueReusableCell(withIdentifier: SignOutTableViewCell.identifier,
                                                     for: indexPath) as! SignOutTableViewCell
            cell.configure(with: model)
            return cell
        }
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = models[indexPath.section][indexPath.row]
        switch model.type {
        case .standard(_):
            return 45
        case .sign_out(_):
            return 55
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.section][indexPath.row]
        model.handler?()
    }
    
}
