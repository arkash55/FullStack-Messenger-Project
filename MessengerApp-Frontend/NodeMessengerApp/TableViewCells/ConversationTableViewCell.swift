//
//  ConversationTableViewCell.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 18/04/2022.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    static let identifier = "ConversationTableViewCell"
    
    private let profileView: UIImageView = {
        let profileView = UIImageView()
        profileView.image = UIImage(systemName: "person.circle")
        profileView.tintColor = .secondaryLabel
        profileView.layer.masksToBounds = true
        return profileView
    }()
    
    private let usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.textColor = .label
        usernameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        usernameLabel.layer.masksToBounds = true
        return usernameLabel
    }()
    
    private let latestMessageLabel: UILabel = {
        let latestMessageLabel = UILabel()
        latestMessageLabel.textColor = .label
        latestMessageLabel.numberOfLines = 2
        return latestMessageLabel
    }()
    

    
    private let latestMessageDate: UILabel = {
        let latestMessageDate = UILabel()
        latestMessageDate.textColor = .secondaryLabel
        latestMessageDate.font = .systemFont(ofSize:13, weight: .semibold)
        latestMessageDate.numberOfLines = 1
        return latestMessageDate
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 2
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let profileViewSize = contentView.frame.size.height/1.3
        let dateTimeWidth = contentView.frame.size.width/6
        let usernameWidth = contentView.frame.size.width - profileViewSize - dateTimeWidth - 20
        let labelWidth = contentView.frame.size.width - profileViewSize - 50
        let labelHeight = contentView.frame.size.height/3.5
        let lmlHeight = heightForView(text: latestMessageLabel.text!, font: latestMessageLabel.font, width: labelWidth)
        
        profileView.frame = CGRect(x: 10,
                                   y: 10,
                                   width: profileViewSize,
                                   height: profileViewSize)
        profileView.layer.cornerRadius = profileViewSize/2
        
        usernameLabel.frame = CGRect(x: profileView.frame.maxX + 8,
                                     y: 10,
                                     width: usernameWidth,
                                     height: labelHeight)
        

        latestMessageLabel.frame = CGRect(x: profileView.frame.maxX + 8,
                                          y: usernameLabel.frame.maxY + 5,
                                          width: labelWidth,
                                          height: lmlHeight)
        
        latestMessageDate.frame = CGRect(x: contentView.frame.maxX - dateTimeWidth - 5,
                                         y: 10,
                                         width: dateTimeWidth,
                                         height: labelHeight)
    }
    
    
    //methods
    private func configureSubviews() {
        contentView.addSubview(profileView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(latestMessageLabel)
        contentView.addSubview(latestMessageDate)
    }
    
    private func configureLatestMessageLabel(_ model: ConversationModel) -> String {
        if model.latest_message_type == "text" {
            latestMessageLabel.font = .systemFont(ofSize: 13, weight: .regular)
            return model.latest_message
        } else if model.latest_message_type == "photo" {
            latestMessageLabel.font = .italicSystemFont(ofSize: 13)
            return "Photo Message"
        } else if model.latest_message_type == "video" {
            latestMessageLabel.font = .italicSystemFont(ofSize: 13)
            return "Video Message"
        } else if model.latest_message_type == "location" {
            latestMessageLabel.font = .italicSystemFont(ofSize: 13)
            return "Location Message"
        } else {
            return "Some other message type sent, (need to configure this properly)"
        }
    }
    
    private func configureLatestMessageDateTime(date: Date) -> String {
        let dateString = UtilManager.shared.conversationUpdatedAtTime(date) 
        return dateString
    }
    
    
    private func configureProfilePicture(_ model: ConversationModel) {
        let imageKey = model.recipient.profile_pic_key
        guard let imageUrl = UtilManager.shared.convertToAWSUrl(mediaKey: imageKey) else {
            print("failed to make image url")
            return
        }
        DispatchQueue.main.async {
            self.profileView.sd_setImage(with: imageUrl, completed: nil)
        }
        
    }
    
    

    
    
    public func configure(with model: ConversationModel) {
        usernameLabel.text = model.recipient.username
        latestMessageDate.text = configureLatestMessageDateTime(date: model.updatedAt)
        latestMessageLabel.text = configureLatestMessageLabel(model)
        configureProfilePicture(model)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        latestMessageLabel.text = nil
        profileView.image = nil
        latestMessageDate.text = nil
    }
    
    
    

}
