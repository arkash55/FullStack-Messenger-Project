//
//  BasicTableViewCell.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 15/04/2022.
//

import UIKit

class BasicTableViewCell: UITableViewCell {
    
    static let identifier = "BasicTableViewCell"
    
    private let iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.backgroundColor = .systemBackground
        iconView.tintColor = .link
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = 8.0
        iconView.layer.masksToBounds = true
        return iconView
    }()

    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = .label
        return titleLabel
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
        let iconSize = contentView.frame.size.width/10
        let titleWidth = contentView.frame.size.width - iconSize - 35
        let titleHeight = contentView.frame.size.height/2
        
        iconView.frame = CGRect(x: 10,
                                y: contentView.frame.midY - iconSize/2,
                                width: iconSize,
                                height: iconSize)
        
        titleLabel.frame = CGRect(x: iconView.frame.maxX + 30,
                                  y: contentView.frame.midY - titleHeight/2,
                                  width: titleWidth,
                                  height: titleHeight)
    }
    
    
    //methods
    private func configureSubviews() {
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
    }
    
    public func configure(with model: SettingsModel) {
        switch model.type {
        case .basic(let data):
            iconView.image = data.iconImage
            titleLabel.text = data.title
        case .profile(_):
            break
        }
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        iconView.image = nil
    }
    
    

}
