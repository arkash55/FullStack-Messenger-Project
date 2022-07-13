//
//  ChatNavigationBar.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 25/04/2022.
//

import UIKit

class ChatNavigationBar: UINavigationBar {
    
    
    private let recipient: ComposeChatModel?
    

    private let profileView: UIImageView = {
        let profileView = UIImageView()
        profileView.image = UIImage(systemName: "person.circle")
        profileView.tintColor = .link
        profileView.layer.masksToBounds = true
        return profileView
    }()
    
    private let usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.textColor = .label
        usernameLabel.font = .systemFont(ofSize: 19, weight: .semibold)
        return usernameLabel
    }()
    
    
    
  
//    init(recipient: ComposeChatModel) {
//        self.recipient = recipient
//        super.init(frame: frame)
//        self.backgroundColor = .systemBackground
//        configureSubviews()
//        loadProfileImage()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//

    
    override func layoutSubviews() {
        super.layoutSubviews()
        let profileSize = frame.size.height/2
        profileView.frame = CGRect(x: 10,
                                   y: 10,
                                   width: profileSize,
                                   height: profileSize)
        profileView.layer.cornerRadius = profileSize/2
        
        
        let labelHeight = frame.size.height/2
        let labelWidth = frame.size.width - profileView.frame.size.width - 20
        usernameLabel.frame = CGRect(x: profileView.frame.maxX + 10,
                                     y: frame.midY - labelHeight/2,
                                     width: labelWidth,
                                     height: labelHeight)
        
    }
    
    //methods
    private func configureSubviews() {
        self.addSubview(profileView)
        self.addSubview(usernameLabel)
    }
    
    private func loadProfileImage() {
        let imageKey = recipient?.profile_pic_key ?? ""
        guard let url = UtilManager.shared.convertToAWSUrl(imageKey: imageKey) else {
            return
        }
        profileView.sd_setImage(with: url, completed: nil)
    }
  
    

    

    
}
