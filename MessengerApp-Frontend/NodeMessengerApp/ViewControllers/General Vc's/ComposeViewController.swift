//
//  ComposeViewController.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 16/04/2022.
//

import UIKit

class ComposeViewController: UIViewController {
    
    public var hasFetched = false
    
    private let noResultsLabel: UILabel = {
        let noResultsLabel = UILabel()
        noResultsLabel.text = "No Results"
        noResultsLabel.textColor = .secondaryLabel
        noResultsLabel.textAlignment = .center
        noResultsLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        noResultsLabel.isHidden = true
        return noResultsLabel
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search User..."
        searchBar.backgroundColor = .systemBackground
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ComposeTableViewCell.self, forCellReuseIdentifier: ComposeTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    public var completion: ((ComposeChatModel) -> Void)?
    
    private var models = [ComposeChatModel]()
    
    private var queryResults = [ComposeChatModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationController()
        configureTableView()
        searchBar.delegate = self
        view.addSubview(noResultsLabel)

        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        let labelWidth = view.frame.size.width
        let labelHeight: CGFloat = 60
        noResultsLabel.frame = CGRect(x: view.frame.midX - labelWidth/2,
                                      y: view.frame.size.height * 0.25,
                                      width: labelWidth,
                                      height: labelHeight)
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureNavigationController() {
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapCancelButton))
    }
    
    
    private func alterData(data: inout [ComposeChatModel]) {
        guard let user_id = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            print("alter failed")
            return
        }
        var counter = 0
        for datum in data {
            if datum.id == user_id {
                data.remove(at: counter)
                break
            }
            counter += 1
        }
    }
    
    
    @objc private func didTapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension ComposeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queryResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = queryResults[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ComposeTableViewCell.identifier,
                                                      for: indexPath) as! ComposeTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = queryResults[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.completion?(selectedUser)
        }

        
        
        
        
    }
    
}
















extension ComposeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let queryText = searchBar.text?.replacingOccurrences(of: " ", with: "").lowercased(), !queryText.isEmpty else {
            return
        }
        
        if hasFetched {
            filterData(query: queryText)
        } else {
            UserManager.shared.getAllUsers { [weak self] result in
                switch result {
                case .success(var payload):
                    self?.alterData(data: &payload)
                    self?.models = payload
                    self?.hasFetched = true
                    self?.filterData(query: queryText)
                case.failure(let error):
                    print(error)
                    guard let strongSelf = self else {
                        return
                    }
                    DispatchQueue.main.async {
                        AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Something went wrong..", message: "Could not get users")
                    }
                }
            }
        }
        
    }
    

    private func filterData(query: String) {

    
        let results: [ComposeChatModel] = models.filter({
            let username = $0.username.lowercased()
            let first_name = $0.first_name.lowercased()

            return username.hasPrefix(query) || first_name.hasPrefix(query)

        })
        
        self.queryResults = results
        updateUI()
    }
    
    
    
    private func updateUI() {
        if queryResults.isEmpty {
            DispatchQueue.main.async {
                self.noResultsLabel.isHidden = false
                self.tableView.isHidden = true
            }
        } else {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.noResultsLabel.isHidden = true
                self.tableView.isHidden = false
            }
        }
    }

    
}
