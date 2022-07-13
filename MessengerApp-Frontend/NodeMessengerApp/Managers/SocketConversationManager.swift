//
//  SocketConversationManager.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 10/06/2022.
//

import Foundation
import SocketIO
import MessageKit


class SocketConversationManager {
    
    
    private let manager: SocketManager!
    private let socket: SocketIOClient!
    
    init(current_uid: Int, recipient_uid: Int?) {
        if let recipient_uid = recipient_uid {
            manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!,
                                    config: [
                                        .log(false),
                                        .compress,
                                        .path("/ws/conversations"),
                                        .connectParams([
                                            "current_user_id": current_uid,
                                            "recipient_user_id": recipient_uid
                                        ])
                                    ])
        } else {
            manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!,
                                    config: [
                                        .log(false),
                                        .compress,
                                        .path("/ws/conversations"),
                                        .connectParams([
                                            "current_user_id": current_uid
                                        ])
                                    ])
        }

        socket = manager.defaultSocket
        configureSocketEvents()
    }
    
    
    
    //socket methods
    func establishConnection() {
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func didSendMessage(convo_message_data: [String: Any]) {
        socket.emit("new_conversation_latest_message", convo_message_data)
    }
    
    func didCreateNewConversation(conversation_data: [String: Any]) {
        guard let uid = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let username = UserDefaults.standard.value(forKey: "username") as? String,
              let first_name = UserDefaults.standard.value(forKey: "first_name") as? String,
              let last_name = UserDefaults.standard.value(forKey: "last_name") as? String,
              let profile_pic_key = UserDefaults.standard.value(forKey: "profile_pic_key") as? String  else {
                  print("failed to get user cache info @socket-convo-manager")
                  return
              }
        
        let recipient_data: [String: Any] = [
            "user_id": uid,
            "username": username,
            "first_name": first_name,
            "last_name": last_name,
            "profile_pic_key": profile_pic_key,
            "conversation_id": conversation_data["id"]!,
            "latest_message_text": conversation_data["latest_message"]!,
            "latest_message_type": conversation_data["latest_message_type"]!,
            "dateString": conversation_data["updatedAt"]!,
        ]
        
        let current_user_data: [String: Any] = [
            "user_id": conversation_data["recipient_id"]!,
            "username": conversation_data["recipient_username"]!,
            "first_name": conversation_data["recipient_first_name"]!,
            "last_name": conversation_data["recipient_last_name"]!,
            "profile_pic_key": conversation_data["recipient_profile_pic_key"]!,
            "conversation_id": conversation_data["id"]!,
            "latest_message_text": conversation_data["latest_message"]!,
            "latest_message_type": conversation_data["latest_message_type"]!,
            "dateString": conversation_data["updatedAt"]!,
        ]
        
        let final_data: [String: Any] = [
            "recipient_data": recipient_data,
            "current_user_data": current_user_data
        ]
        socket.emit("new_conversation_created", final_data)
    }
    
    
    //socket events
    private func configureSocketEvents() {
        socket.on(clientEvent: .connect) { data, ack in
            print("connected to user convo room")
        }
        
        socket.on(clientEvent: .disconnect) { data, ack in
            print("disconnected from user convo room")
        }

    }
        
    func listenForNewConversations(completion: @escaping ListenForConversationCompletion) {
        socket.on("new_conversation_created") { dataArray, ack in
            guard let conversation_data = dataArray[0] as? [String: Any]  else {
                completion(.failure(SocketError.noSocketData))
                return
            }
            
            guard let conversation_id = conversation_data["conversation_id"] as? Int,
                  let user_id = conversation_data["user_id"] as? Int,
                  let username = conversation_data["username"] as? String,
                  let first_name = conversation_data["first_name"] as? String,
                  let last_name = conversation_data["last_name"] as? String else {
                      print("failed to unwrap message data @ LISTEN_FOR_NEW_CONVO --1")
                      return
                  }
                  
              guard let user_profile_pic_key = conversation_data["profile_pic_key"] as? String,
                  let latest_message_text = conversation_data["latest_message_text"] as? String else {
                      print("failed to unwrap message data @ LISTEN_FOR_NEW_CONVO --2")
                      return
                  }
                  
            guard let latest_message_type = conversation_data["latest_message_type"] as? String,
                  let dateString = conversation_data["dateString"] as? String else {
                      print("failed to unwrap message data @ LISTEN_FOR_NEW_CONVO --3")
                      return
                  }
            
            let composeModel = ComposeChatModel(id: user_id,
                                                username: username,
                                                first_name: first_name,
                                                last_name: last_name,
                                                profile_pic_key: user_profile_pic_key)
    
            guard let updatedAtDate = UtilManager.shared.dateFormatter.date(from: dateString) else {
                print("failed to get updatedAtDate @ SCM")
                completion(.failure(DateError.dateConversionFailed))
                return
            }
            
            let convoModel = ConversationModel(id: conversation_id,
                                               latest_message: latest_message_text,
                                               latest_message_type: latest_message_type,
                                               recipient: composeModel,
                                               updatedAt: updatedAtDate)
            completion(.success(convoModel))
        }
    }
    
    
    
    
    func listenForConversationsLatestMessage(completion: @escaping ListenForConversationLatestMessageCompletion) {
        socket.on("new_conversation_latest_message") { dataArray, ack in
            guard let message_data = dataArray[0] as? [String: Any] else {
                print("failed to get convo latest messagevia socket")
                completion(.failure(SocketError.noSocketData))
                return
            }
            
            guard let conversation_id = message_data["conversation_id"] as? Int,
                  let message_text = message_data["text"] as? String,
                  let message_type = message_data["type"] as? String,
                  let dateString = message_data["dateString"] as? String else {
                      print("failed to unwrap message data")
                      completion(.failure(DataError.unwrapFailed))
                      return
                  }
            

            
            let convoLatestMessageModel = UpdateLatestMessageModel(conversation_id: conversation_id,
                                                                   body: message_text,
                                                                   dateString: dateString,
                                                                   type: message_type)
            
            completion(.success(convoLatestMessageModel))

        }
    }
    
    
    
}
