//
//  ConversationModels.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 18/04/2022.
//

import Foundation
import MessageKit


public struct ComposeChatModel: Codable {
    let id: Int
    let username: String
    let first_name: String
    let last_name: String
    let profile_pic_key: String
}

public struct CreateConversationModel: Codable {
    let user_1: Int
    let user_2: Int
    let latest_message: String
    let latest_message_type: String
}

public struct ConversationDecodeModel: Codable {
    let id: Int
    let latest_message: String
    let latest_message_type: String
    let users: [ComposeChatModel]
    let updatedAt: String
}


public struct ConversationModel: Codable {
    let id: Int
    var latest_message: String
    var latest_message_type: String
    let recipient: ComposeChatModel
    var updatedAt: Date
}


public struct GetMessageModel: Codable {
    let id: Int
    let body: String
    let type: String
    let conversation_id: Int
    let sender_id: Int
    let sent_date: String
}


public struct Message: MessageType {
    public var sender: SenderType
    public var messageId: Int
    public var sentDate: Date
    public var kind: MessageKind
}


struct Sender: SenderType {
    var senderId: Int
    var displayName: String
}

public struct SendMessageModel: Codable {
    let conversation_id: Int
    let sender_id: Int
    let body: String
    let type: String
}

public struct UpdateLatestMessageModel {
    let conversation_id: Int
    let body: String
    let dateString: String
    let type: String
}


extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}


struct MessageValueType {
    static let text = "text"
    static let photo = "photo"
    static let video = "video"
}


struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
