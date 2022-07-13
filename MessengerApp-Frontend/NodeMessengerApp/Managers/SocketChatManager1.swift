//
//  SocketChatManager1.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 23/05/2022.
//

import Foundation
import SocketIO
import MessageKit

class SocketChatManager1 {

    static let shared = SocketChatManager1()
    
    
    ///Creates a manager with the current convo_id as a param,  then returns a socket
    func socketConfiguration(conversation_id: Int) -> SocketIOClient {
        let manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!,
                                    config: [
                                        .log(false),
                                        .compress,
                                        .path("/ws/messaging"),
                                        .connectParams(["conversation_id":conversation_id])
                                    ])
        let socket = manager.defaultSocket
        return socket
    }
    
    ///connects to socket server
    func establishConnection(_ socket: SocketIOClient) {
        socket.connect()
    }
    
    ///disconnects to socket server
    func terminateConnection(_ socket: SocketIOClient) {
        socket.disconnect()
    }
    
    ///sends message to socket (not to room yet, needs to be changes...)
    func sendMessage(socket: SocketIOClient, message_data: [String: Any]) {
        socket.emit("message",message_data)
    }
    
    ///listens for messages within the room
    func listenForMessages(socket: SocketIOClient, completion: @escaping ListenForMessagesCompletion) {
        socket.on("message") { dataArray, ack in
            guard let message_data = dataArray[0] as? [String: Any] else {
                print("failed to get message via socket")
                completion(.failure(SocketError.noSocketData))
                return
            }
            guard let sender_id = message_data["sender_id"] as? Int,
                  let message_id = message_data["message_id"] as? Int,
                  let sender_username = message_data["sender_username"] as? String,
                  let message_text = message_data["text"] as? String,
                  let message_type = message_data["type"] as? String,
                  let dateString = message_data["dateString"] as? String else {
                      print("failed to unwrap message data")
                      return
                  }
            
            guard let message_date = UtilManager.shared.getMessageDate(dateString: dateString) else {
                print("failed to get message data")
                return
            }
            
            var kind = MessageKind.text("Message Type Failure")
            if message_type == "text" {
                kind = MessageKind.text(message_text)
            } else if message_type == "video" {
                
            } else if message_type == "photo" {
                
            } else if message_type == "location" {
                
            }
            
            let sender = Sender(senderId: sender_id, displayName: sender_username)
            let new_message = Message(sender: sender,
                                  messageId: message_id,
                                  sentDate: message_date,
                                  kind: kind)
            completion(.success(new_message))
            return
        }
    }
    
    
    
    
    
}
