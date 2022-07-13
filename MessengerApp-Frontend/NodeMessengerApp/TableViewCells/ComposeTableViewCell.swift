//
//  ComposeTableViewCell.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 23/04/2022.
//

import UIKit
import SDWebImage

class ComposeTableViewCell: UITableViewCell {
    
    static let identifier = "ComposeTableViewCell"

    private let profileView: UIImageView = {
        let profileView = UIImageView()
        profileView.image = UIImage(systemName: "person.circle")
        profileView.tintColor = .secondaryLabel
        profileView.layer.masksToBounds = true
        return profileView
    }()
    
    
    private let nameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.textColor = .secondaryLabel
        usernameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        usernameLabel.layer.masksToBounds = true
        return usernameLabel
    }()
    
    private let usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.textColor = .label
        usernameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        usernameLabel.layer.masksToBounds = true
        return usernameLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        configureSubviews()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let profileViewSize = contentView.frame.size.height/1.3
        let labelWidth = contentView.frame.size.width - profileViewSize - 20
        let labelHeight = contentView.frame.size.height/2 - 10
        
        profileView.frame = CGRect(x: 10,
                                   y: 10,
                                   width: profileViewSize,
                                   height: profileViewSize)
        profileView.layer.cornerRadius = profileViewSize/2
        
        nameLabel.frame = CGRect(x: profileView.frame.maxX + 5,
                                     y: 10,
                                     width: labelWidth,
                                     height: labelHeight)
        
        usernameLabel.frame = CGRect(x: profileView.frame.maxX + 5,
                                     y: nameLabel.frame.maxY + 5,
                                     width: labelWidth,
                                     height: labelHeight)
        
    }
    
    
    //methods
    private func configureSubviews() {
        contentView.addSubview(profileView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(usernameLabel)
    }
    
    private func configureProfilePic(_ imageKey: String) {
        guard let imageUrl = UtilManager.shared.convertToAWSUrl(mediaKey: imageKey) else {
            return
        }
        DispatchQueue.main.async {self.profileView.sd_setImage(with: imageUrl, completed: nil)}
    }
    
    
    public func configure(with model: ComposeChatModel) {
        usernameLabel.text = model.username
        nameLabel.text = "\(model.first_name) \(model.last_name)"
        configureProfilePic(model.profile_pic_key)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        nameLabel.text = nil
        profileView.image = nil
    }
    
    

}

