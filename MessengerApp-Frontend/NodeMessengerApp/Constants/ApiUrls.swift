//
//  ApiUrls.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 19/04/2022.
//

import Foundation


class ApiUrls {
    
    ///AUTH URLS
    static let registrationUrl = UtilManager.shared.convertToUrl(urlString: "http://localhost:3000/user/registration")
    static let loginUrl = UtilManager.shared.convertToUrl(urlString: "http://localhost:3000/user/login")
    static let logOutUrl = UtilManager.shared.convertToUrl(urlString: "http://localhost:3000/user/log-out")
    
    
    ///TOKEN URLS
    static let getNewAccessToken = UtilManager.shared.convertToUrl(urlString: "http://localhost:3000/token/new-access-token")
    
    
    
    ///USER URLS
    static let updateUserDetailUrl = UtilManager.shared.convertToUrl(urlString: "http://localhost:3000/user/update-user-detail")
    static let getAllUsers = UtilManager.shared.convertToUrl(urlString: "http://localhost:3000/user/get-users")

    
    ///CONVERSATION URLS
    static let getConversationsUrl = UtilManager.shared.convertToUrl(urlString: "http://localhost:3000/conversation/get-chats")
    static let getConvoMessagesUrl = UtilManager.shared.convertToUrl(urlString: "http://localhost:3000/message/get-chat-messages")
    static let createConversationUrl = UtilManager.shared.convertToUrl(urlString: "http://localhost:3000/conversation/create-conversation")
    static let sendMessageToConversation = UtilManager.shared.convertToUrl(urlString: "http://localhost:3000/message/send-message")
    
    
    

}




