//
//  ErrorModels.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 19/04/2022.
//

import Foundation


enum AuthError: Error {
    case access_token_expired
    case refresh_token_expired
    case user_does_not_exist
    case incorrect_password
    case user_not_verified
}


enum DataError: Error {
    case decode_failed
    case encode_failed
    case missing_cache
    case PngConversionFailed
    case unwrapFailed
}



enum TaskError: Error {
    case guardFailed
    case task_failed
    case faulty_url
}


enum RegistrationError: Error {
    case usernameTaken
    case emailTaken
    case account_exists
}


enum RequestError: Error {
    case badRequest
    case otherErrorCode
}

enum TokenError: Error {
    case refreshTokenExpired
    case accessTokenExpired
}

enum SocketError: Error {
    case socketFailedToEmit
    case socketFailedToRespond
    case noSocketData
}

enum DateError: Error {
    case dateConversionFailed
}


struct ErrorMessageModel: Decodable {
    let message: String
}


struct ErrorMessages {
    static let emailIsTaken = "Email Constraint Error"
    static let usernameIsTaken = "Username Constraint Error"
}
