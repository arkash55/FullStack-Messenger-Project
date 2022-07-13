//
//  SettingsModels.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 15/04/2022.
//

import Foundation
import UIKit


enum MyAccountCellType {
    case standard(data: StandardCell)
    case sign_out(data: SignOutModel)
}

struct SignOutModel {
    let title: String
}

struct StandardCell {
    let title: String
}


struct MyAccountModel {
    let type: MyAccountCellType
    let handler: (() -> Void)?
}



enum SettingCellType {
    case profile(data: UserProfile)
    case basic(data: BasicSettingsModel)
}

struct ProfileSettingsModel {
    let first_name: String
    let last_name: String
    let username: String
    let profilePicPath: String
}


struct BasicSettingsModel {
    let iconImage: UIImage
    let title: String
}

struct SettingsModel {
    let type: SettingCellType
    let handler: (() -> Void)?
}


struct UserProfileModel {
    let title: String
    var value: String
    let handler: (() -> Void)?
}

