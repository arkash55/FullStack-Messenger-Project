//
//  UserProfileTableViewCell.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 16/04/2022.
//

import UIKit


protocol UserProfileCellDelegate: AnyObject{
    func didUpdateField(_ cell: UserProfileTableViewCell, updatedModel: UserProfileModel)
    
}

class UserProfileTableViewCell: UITableViewCell, UITextFieldDelegate {

    static let identifier = "UserProfileTableViewCell"
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 16, weight: .light)
        titleLabel.textColor = .label
        titleLabel.clipsToBounds = true
        return titleLabel
    }()
    
    private let valueField: UITextField = {
        let valueField = UITextField()
        valueField.backgroundColor = .systemBackground
        valueField.placeholder = "Type Here..."
        valueField.textColor = .label
        valueField.returnKeyType = .done
        valueField.autocorrectionType = .no
        valueField.autocapitalizationType = .none
        valueField.leftView = UIView(frame: .zero)
        valueField.leftViewMode = .always
        return valueField
    }()
    
    public weak var delegate: UserProfileCellDelegate?
    private var model: UserProfileModel?
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        configureSubviews()
        valueField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        let labelWidth = contentView.frame.size.width/4
        let labelHeight = contentView.frame.size.height/2
        let fieldWidth = contentView.frame.size.width - labelWidth - 35
        let fieldHeight = contentView.frame.size.height
        
        titleLabel.frame = CGRect(x: 10,
                                  y: contentView.frame.midY - labelHeight/2,
                                  width: labelWidth,
                                  height: labelHeight)
        
        valueField.frame = CGRect(x: titleLabel.frame.maxX + 10,
                                  y: contentView.frame.midY - fieldHeight/2,
                                  width: fieldWidth,
                                  height: fieldHeight)
        valueField.addGreyUnderline()
        
    }
    
    
    //methods
    private func configureSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueField)
    }
    public func configure(with model: UserProfileModel) {
        self.model = model
        titleLabel.text = model.title
        valueField.placeholder = "Enter \(model.title)..."
        valueField.text = model.value
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        valueField.placeholder = nil
        valueField.text = nil
    }
    

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        guard let textValue = textField.text else {
            return
        }
        model?.value = textValue
        guard let model = model else {
            return
        }
        delegate?.didUpdateField(self, updatedModel: model)
    }
    
    
}

