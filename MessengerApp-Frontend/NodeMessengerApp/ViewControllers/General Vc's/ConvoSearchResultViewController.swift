//
//  ConvoSearchResultViewController.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 07/07/2022.
//

import UIKit

class ConvoSearchResultViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue

    }
    

    

}
