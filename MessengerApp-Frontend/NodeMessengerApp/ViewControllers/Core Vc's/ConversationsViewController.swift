//
//  ConversationsViewController.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 13/04/2022.
//

import UIKit




class ConversationsViewController: UIViewController {
    
    private var socketConversationManager: SocketConversationManager?
    
    private var models: [ConversationModel] = [ConversationModel]()
    private var searchResults: [ConversationModel] = [ConversationModel]()
    
    private var hasFetched = false
    

    
    
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.returnKeyType = .search
        searchController.searchBar.backgroundColor = .systemBackground
        searchController.searchBar.placeholder = "Search Chats..."
        return searchController
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return tableView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureTableView()
        handleAuthentication()
        configureSocket()
        listenForLatestMessages()
        listenForConversations()
        createObservers()
        configureSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        handleAuthentication()
        if !hasFetched {fetchData()}
    }
    
    
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
    }
    
    private func handleAuthentication() {
        if UserDefaults.standard.value(forKey: "user_id") != nil {return}
        let vc = LoginViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    private func createObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didSignIn),
                                               name: NSNotification.Name(NotificationKeyNameString.signIn),
                                               object: nil)
    }

    
    private func configureSocket() {
        guard let uid = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            return
        }
        let socketManager = SocketConversationManager(current_uid: uid, recipient_uid: nil)
        self.socketConversationManager = socketManager
        self.socketConversationManager?.establishConnection()
    }
    
    
    private func configureNavigationBar() {
        navigationItem.title = "Chats"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold, scale: .default)
        let composeImage = UIImage(systemName: "square.and.pencil")?.withTintColor(.link, renderingMode: .alwaysOriginal).withConfiguration(config)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: composeImage,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
    }
    

    private func restoreSearchResults() {
        searchResults = models
    }
    
    private func sortConversations(_ data: [ConversationModel]) -> [ConversationModel] {
        let sortedConversations =  data.sorted(by: {$0.updatedAt > $1.updatedAt})
        return sortedConversations
    }
    
    
    private func fetchData() {
        ConversationManager.shared.getUserConversations { [weak self] result in
            switch result {
            case .success(let payload):
                guard let strongSelf = self else {return}
                guard let sortedPayload = self?.sortConversations(payload) else {
                    DispatchQueue.main.async {
                        AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Something went wrong", message: "Could not load conversations")
                    }
                    print("failed to sort")
                    return
                }
                self?.models = sortedPayload
                self?.searchResults = sortedPayload
                self?.hasFetched = true
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                guard let strongSelf = self else {return}
                print(error)
                DispatchQueue.main.async {
                    AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Something went wrong", message: "Could not load conversations")
                }
            }
        }
    }
    
    
    

    private func listenForConversations() {
        socketConversationManager?.listenForNewConversations(completion: { [weak self] result in
            switch result {
            case .success(let newConvoModel):
                self?.models.insert(newConvoModel, at: 0)
                self?.restoreSearchResults()
                DispatchQueue.main.async {self?.tableView.reloadData()}
                return
            case .failure(let error):
                print(error)
                return
            }
        })
    }
    
    
    
    private func listenForLatestMessages() {
        socketConversationManager?.listenForConversationsLatestMessage(completion: { [weak self] result in
            switch result {
            case.success(let updatedConvoData):
                
                // find convo that needs to be updated
                guard let convo_index = self?.findUpdatedConversation(convo_id: updatedConvoData.conversation_id),
                      var targetConversation = self?.models[convo_index] else {
                    //this occurs if current user has deleted the conversation
                    print("failed to find convo")
                    return
                }
                
                
                guard let updatedAtDate = UtilManager.shared.dateFormatter.date(from: updatedConvoData.dateString) else {
                    print("failed to get date at listen for latest message in convo vc")
                    return
                }
                
                //delete the convo from models
                self?.models.remove(at: convo_index)
                
                //update it
                targetConversation.latest_message = updatedConvoData.body
                targetConversation.latest_message_type = updatedConvoData.type
                targetConversation.updatedAt = updatedAtDate
                
                
                //insert at top of array
                self?.models.insert(targetConversation, at: 0)
                self?.restoreSearchResults()

                //refresh tableview
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
                return
            }
        })
    }
    
    
    
    // can be optimised (data can be sorted via quicksort using convo id, then binary search, using binary search rn)
    private func findUpdatedConversation(convo_id: Int) -> Int? {
        var model_index = 0
        for conversation in models {
            if convo_id == conversation.id {
                return model_index
            }
            model_index += 1
        }
        return nil
    }
    
    
    private func checkIfConvoExists(_ user: ComposeChatModel) -> ConversationModel? {
        var target_convo: ConversationModel?
        for conversation in models {
            if conversation.recipient.id == user.id {
                target_convo =  conversation
                break
            }
        }
        guard let target_convo = target_convo else {
            return nil
        }
        return target_convo
    }
    
    private func openExistingConversation(_ conversation: ConversationModel) {
        let vc = ChatViewController(recipient: conversation.recipient,
                                    conversation_id: conversation.id)
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openNewConversation(_ user: ComposeChatModel) {
        let vc = ChatViewController(recipient: user,
                                    conversation_id: nil)
        vc.isNewConversation = true
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    
    
    //@objc method
    @objc private func didTapComposeButton() {
        let vc = ComposeViewController()
        vc.completion = { [weak self] selectedUser in
            //check if conversation exists
            guard let conversation = self?.checkIfConvoExists(selectedUser) else {
                //convo does not exist create it
                self?.openNewConversation(selectedUser)
                return
            }
            
            //convo exists open it
            self?.openExistingConversation(conversation)
        }
        
        
        
        
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .popover
        present(navVc, animated: true, completion: nil)
    }
    
    
    @objc private func didSignIn() {
        fetchData()
    }

}






extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = searchResults[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = searchResults[indexPath.row]
        let vc = ChatViewController(recipient: model.recipient, conversation_id: model.id)
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
}






extension ConversationsViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text?.replacingOccurrences(of: " ", with: "").lowercased(),
              !query.isEmpty  else {
                  return
              }
        
        //filter results
        filterConversations(query: query)
        //update ui
        updateUI()
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchController.searchBar.text?.replacingOccurrences(of: " ", with: "").lowercased(),
              !query.isEmpty  else {
                  return
              }
        
        //filter results
        filterConversations(query: query)
        //update ui
        updateUI()
    }
    

    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            restoreSearchResults()
            updateUI()
        }
    }
    
    


    
    
    
    func filterConversations(query: String) {
        searchResults = models
        let filteredResults: [ConversationModel] = searchResults.filter({
            let username = $0.recipient.username.lowercased()
            let first_name = $0.recipient.first_name.lowercased()
            return username.hasPrefix(query) || first_name.hasPrefix(query)
        })
        searchResults = filteredResults
    }
    
    
    
    func updateUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    
    
    
}




