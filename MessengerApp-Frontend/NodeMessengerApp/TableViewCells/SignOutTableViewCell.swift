//
//  SignOutTableViewCell.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 13/06/2022.
//

import UIKit

class SignOutTableViewCell: UITableViewCell {

    static let identifier = "SignOutTableViewCell"
    
    private let title: UILabel = {
        let title = UILabel()
        title.textColor = .red
        title.clipsToBounds = true
        title.textAlignment = .center
        title.font = .systemFont(ofSize: 20, weight: .semibold)
        return title
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = contentView.frame.size.width/2
        let height = contentView.frame.height - 10
        title.frame = CGRect(x: contentView.frame.midX - width/2,
                             y: 5,
                             width: width,
                             height: height)
        
    }
    
    public func configure(with model: MyAccountModel) {
        switch model.type {
        case .sign_out(let data):
            title.text = data.title
        case .standard(_):
            break
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        title.text = nil
    }
    
    

    

}
