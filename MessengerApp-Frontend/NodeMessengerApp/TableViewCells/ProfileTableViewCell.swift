//
//  ProfileTableViewCell.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 15/04/2022.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    
    static let identifier = "ProfileTableViewCell"
    
    private let profileView: UIImageView = {
        let profileView = UIImageView()
        profileView.image = UIImage(systemName: "person.circle")
        profileView.tintColor = .link
        profileView.layer.masksToBounds = true
        return profileView
    }()
    
    private let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textColor = .label
        return nameLabel
    }()
    
    private let usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.font = .systemFont(ofSize: 15, weight: .regular)
        usernameLabel.textColor = .label
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
        let profileSize = contentView.frame.size.width/5
        let nameWidth = contentView.frame.size.width - profileSize - 25
        let usernameWidth = contentView.frame.size.width - profileSize - 25
        let labelHeight = contentView.frame.size.height/2 - 15
        
        profileView.frame = CGRect(x: 5,
                                   y: contentView.frame.size.height/2 - profileSize/2,
                                   width: profileSize,
                                   height: profileSize)
        profileView.layer.cornerRadius = profileSize/2
        
        nameLabel.frame = CGRect(x: profileView.frame.maxX + 15,
                                 y: 15,
                                 width: nameWidth,
                                 height: labelHeight)
        
        usernameLabel.frame = CGRect(x: profileView.frame.maxX + 15,
                                     y: nameLabel.frame.maxY,
                                     width: usernameWidth,
                                     height: labelHeight)
        
    }
    
    
    //methods
    private func configureSubviews() {
        contentView.addSubview(profileView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(usernameLabel)
    }
    
    
    public func configure(with model: SettingsModel) {
        switch model.type {
        case .profile(let data):
            usernameLabel.text = data.username
            nameLabel.text = "\(data.first_name) \(data.last_name)"
            getProfileImage(data.profile_pic_key)
        case .basic(_):
            break
        }
        
    }
    

    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileView.image = nil
        nameLabel.text = nil
        usernameLabel.text = nil
    }
    
    
    private func getProfileImage(_ image_key: String) {
        guard let imageUrl = UtilManager.shared.convertToAWSUrl(mediaKey: image_key) else {return}
        DispatchQueue.main.async {
            self.profileView.sd_setImage(with: imageUrl, completed: nil)
        }
    }
    
    
    
    
}
