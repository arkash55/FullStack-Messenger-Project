//
//  AuthModels.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 13/04/2022.
//

import Foundation


enum LoginButtonOptions {
    case term
    case privacy
    case help
}

public struct LogOutModel: Codable {
    let uid: Int
}

public struct User: Codable {
    let id: Int
    let username: String
    let first_name: String
    let last_name: String
    let email: String
    let profile_pic_key: String
    let access_token: String
    let refresh_token: String
}


public struct UserProfile {
    let id: Int
    var username: String
    var first_name: String
    var last_name: String
    let email: String
    var profile_pic_key: String
}

struct RegistrationModel: Codable {
    let username: String
    let email: String
    let first_name: String
    let last_name: String
    let password: String
    var profile_pic_key: String
}

struct RegisterFieldsModel {
    let username: String
    let email: String
    let first_name: String
    let last_name: String
    let confirm_password: String
    let password: String
}

struct LoginModel: Codable {
    let email: String
    let password: String
}


struct UpdateUserProfileModel: Codable, Equatable {
    let id: Int
    var username: String
    var first_name: String
    var last_name: String
    var profile_pic_key: String
}


struct AccessTokenModel: Decodable {
    let access_token: String
}




//struct RegistrationResponseModel: Codable {
//    let id: Int
//    let username: String
//    let email: String
//    let first_name: String
//    let last_name: String
//    let profile_pic_data: Data
//    let access_token: String
//    let refresh_token: String
//}
//
