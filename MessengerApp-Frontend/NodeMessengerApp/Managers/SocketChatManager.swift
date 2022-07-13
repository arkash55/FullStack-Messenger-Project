//
//  SocketChatManager.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 10/05/2022.
//

import Foundation
import SocketIO
import MessageKit

class SocketChatManager {


    private var socket: SocketIOClient!
    private var manager: SocketManager!
    
    init(conversation_id: Int) {
        manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!,
                                config: [
                                    .log(false),
                                    .compress,
                                    .path("/ws/messaging"),
                                    .connectParams(["conversation_id": conversation_id])
                                ])
        socket = manager.defaultSocket
        setupSocketEvents()
        
    }
    


    
    //socket setup
    func getSocket() -> SocketIOClient {
        return socket
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnextion() {
        socket.disconnect()
    }
    
    
    func sendMessage(message_data: [String: Any]) {

        socket?.emit("message",message_data)
    }
    
    
    func setupSocketEvents() {
        print("setup events")
        socket?.on(clientEvent: .connect) {data, ack in
            print("Connected to chat socket")
        }
        
    }
    
    
    
    func listenForMessages(completion: @escaping ListenForMessagesCompletion) {
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
            } else if message_type == "photo" {
                let imageUrl = UtilManager.shared.convertToAWSUrl(mediaKey: message_text)
                let media = Media(url: imageUrl,
                                  image: nil,
                                  placeholderImage: UIImage(systemName: "photo.fill")!,
                                  size: CGSize(width: 220, height: 220))
                kind = MessageKind.photo(media)
            } else if message_type == "video" {
                let videoUrl = UtilManager.shared.convertToAWSUrl(mediaKey: message_text)
                let media = Media(url: videoUrl,
                                  image: nil,
                                  placeholderImage: UIImage(systemName: "video")!,
                                  size: CGSize(width: 220, height: 220))
                kind = MessageKind.video(media)
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
