//
//  ConversationManager.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 24/04/2022.
//

import Foundation
import Amplify
import MessageKit
import UIKit




class ConversationManager {
    
    static let shared = ConversationManager()
    
    ///CREATE  A NEW CONVERSATION
    func createNewConversation(conversation: CreateConversationModel, completion: @escaping CreateConversationsCompletion) {
        guard let access_token = UserDefaults.standard.value(forKey: "access_token") as? String else {
            completion(.failure(DataError.missing_cache))
            return
        }
        
        guard let encoded_data = try? JSONEncoder().encode(conversation) else {
            completion(.failure(DataError.encode_failed))
            return
        }
        
        guard let url = ApiUrls.createConversationUrl else {
            completion(.failure(TaskError.faulty_url))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.POST
        request.httpBody = encoded_data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                if let error = error {print(error)}
                completion(.failure(TaskError.task_failed))
                return
            }
            switch response.statusCode {
            case 201:
                guard let decodedData = try? JSONDecoder().decode(ConversationDecodeModel.self, from: data) else {
                    completion(.failure(DataError.decode_failed))
                    return
                }
                guard let updatedAtDate = UtilManager.shared.dateFormatter.date(from: decodedData.updatedAt) else {
                    print("failed to get updatedAtDate @CM-57")
                    completion(.failure(DateError.dateConversionFailed))
                    return 
                }
            
                let newConversation = ConversationModel(id: decodedData.id,
                                                          latest_message: decodedData.latest_message,
                                                          latest_message_type: decodedData.latest_message_type,
                                                          recipient: decodedData.users[0] ,
                                                          updatedAt: updatedAtDate)
                completion(.success(newConversation))
            case 401:
                TokenManager.shared.requestNewAccessToken { [weak self] result in
                    switch result {
                    case .success(_):
                        self?.createNewConversation(conversation: conversation, completion: completion)
                        return
                    case .failure(let error):
                        print(error)
                        completion(.failure(error))
                        return
                    }
                }
            case 400:
                completion(.failure(RequestError.badRequest))
                return
            default:
                completion(.failure(RequestError.otherErrorCode))
                return
            }
        }
        task.resume()
        
    }
    
    
    
    ///GET ALL CONVERSATIONS FOR A SPECIFIC USER
    func getUserConversations(completion: @escaping GetConversationsCompletion) {
        guard let uid = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let access_token = UserDefaults.standard.value(forKey: "access_token") as? String else {
            completion(.failure(DataError.missing_cache))
            return
        }
        guard let url = ApiUrls.getConversationsUrl else {
            completion(.failure(TaskError.faulty_url))
            return
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.path += "/\(uid)"
        guard let finalUrl = urlComponents?.url else {
            completion(.failure(TaskError.guardFailed))
            return
        }
        var request = URLRequest(url: finalUrl)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HttpMethods.GET
        
        let task = URLSession.shared.dataTask(with: request) {  data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                if let error = error {
                    print(error)
                    completion(.failure(TaskError.task_failed))
                }
                return
            }
            
            switch response.statusCode {
            case 200:
                guard let payload = try? JSONDecoder().decode([ConversationDecodeModel].self, from: data) else {
                    completion(.failure(DataError.decode_failed))
                    return
                }
                
                
                let conversationModels: [ConversationModel] = payload.compactMap { model in
                    
                    guard let updatedAtDate = UtilManager.shared.dateFormatter.date(from: model.updatedAt) else {
                        print("failed to get updatedAtDate @ CM-137")
                        completion(.failure(DateError.dateConversionFailed))
                        return nil
                    }
                    
                    return ConversationModel(id: model.id,
                                             latest_message: model.latest_message,
                                             latest_message_type: model.latest_message_type,
                                             recipient: model.users[0],
                                             updatedAt: updatedAtDate)
                }
                completion(.success(conversationModels))
                return
            case 401:
                TokenManager.shared.requestNewAccessToken { [weak self] result in
                    switch result {
                    case .success(_):
                        self?.getUserConversations(completion: completion)
                    case .failure(let error):
                        print("getting new token failed")
                        completion(.failure(error))
                        return
                    }
                }
            case 400:
                completion(.failure(RequestError.badRequest))
                return
            default:
                completion(.failure(RequestError.otherErrorCode))
                return
            }
            
        }
        task.resume()
    }
    
    
    
    
    ///GET MESSAGES FOR A SPECIFIC CONVERSATION
    func getConversationMessages(conversation_id: Int, otherUser: ComposeChatModel ,completion: @escaping GetMessagesCompletion) {
        guard let access_token = UserDefaults.standard.value(forKey: "access_token") as? String,
              let uid = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let username = UserDefaults.standard.value(forKey: "username") as? String else {
                  completion(.failure(DataError.missing_cache))
                  return
              }
        
        guard let url = ApiUrls.getConvoMessagesUrl else {
            completion(.failure(TaskError.faulty_url))
            return
        }
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.path += "/\(conversation_id)"
        guard let finalUrl = urlComponents?.url else {
            completion(.failure(TaskError.faulty_url))
            return
        }
        
        var request = URLRequest(url: finalUrl)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HttpMethods.GET
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                if let error = error {
                    print(error)
                    completion(.failure(TaskError.task_failed))
                }
                return
            }
            
            switch response.statusCode {
            case 200:
                guard let payload = try? JSONDecoder().decode([GetMessageModel].self, from: data) else {
                    completion(.failure(DataError.decode_failed))
                    return
                }
                let messages: [Message] = payload.map { message in
                    var sender = Sender(senderId: 0, displayName: "")
                    if message.sender_id == otherUser.id {
                        sender = Sender(senderId: otherUser.id, displayName: otherUser.username)
                    } else {
                        sender = Sender(senderId: uid, displayName: username)
                    }
                    let messageDate = UtilManager.shared.getMessageDate(dateString: message.sent_date)
                    
                    
                    var kind = MessageKind.text("Message Type Failure")
                    if message.type == "text" {
                        kind = MessageKind.text(message.body)
                        
                    } else if message.type == "photo" {
                        let imageUrl = UtilManager.shared.convertToAWSUrl(mediaKey: message.body)
                        let media = Media(url: imageUrl,
                                          image: nil,
                                          placeholderImage: UIImage(systemName: "photo.fill")!,
                                          size: CGSize(width: 220, height: 220))
                        kind = MessageKind.photo(media)
                        
                    } else if message.type == "video" {
                        let videoUrl = UtilManager.shared.convertToAWSUrl(mediaKey: message.body)
                        let media = Media(url: videoUrl,
                                          image: nil,
                                          placeholderImage: UIImage(systemName: "video")!,
                                          size: CGSize(width: 220, height: 220))
                        kind = MessageKind.video(media)
                        
                    } else if message.type == "location" {
                        
                    }
                    return Message(sender: sender,
                                   messageId: message.id,
                                   sentDate: messageDate ?? Date(),
                                   kind: kind)
                    
                }
                completion(.success(messages))
                return
           
                
            case 401:
                TokenManager.shared.requestNewAccessToken { [weak self] result in
                    switch result {
                    case .success(_):
                        self?.getConversationMessages(conversation_id: conversation_id, otherUser: otherUser, completion: completion)
                    case .failure(let error):
                        print("getting new token failed")
                        completion(.failure(error))
                        return
                    }
                }
            case 400:
                completion(.failure(RequestError.badRequest))
                return
            default:
                completion(.failure(RequestError.otherErrorCode))
                return
            }
        }
        task.resume()
    }
    
    
    
    
    ///SEND A MESSAGE TO A SPECIFIC CONVERSATION
    func sendMessage(new_message: SendMessageModel, completion: @escaping SendMessageCompletion) {
        guard let access_token = UserDefaults.standard.value(forKey: "access_token") as? String,
              let username = UserDefaults.standard.value(forKey: "username") as? String  else {
                  completion(.failure(DataError.missing_cache))
                  return
              }
        
        guard let url = ApiUrls.sendMessageToConversation else {
            completion(.failure(TaskError.faulty_url))
            return
        }
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.path += "/\(new_message.conversation_id)"
        guard let finalUrl = urlComponents?.url else {
            completion(.failure(TaskError.faulty_url))
            return
        }
        
        var request = URLRequest(url: finalUrl)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HttpMethods.POST
        
        guard let encodedData = try? JSONEncoder().encode(new_message) else {
            completion(.failure(DataError.encode_failed))
            return
        }
        request.httpBody = encodedData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data ,let response = response as? HTTPURLResponse, error == nil else {
                if let error = error {
                    print(error)
                    completion(.failure(TaskError.task_failed))
                }
                return
            }
            
            switch response.statusCode {
            case 201:
                guard let payload = try? JSONDecoder().decode(GetMessageModel.self, from: data) else {
                    completion(.failure(DataError.decode_failed))
                    return
                }
                
                let sender = Sender(senderId: payload.sender_id,
                                    displayName: username)
                
                
                var kind: MessageKind?
                if payload.type == "text" {
                    kind = MessageKind.text(payload.body)
                } else if payload.type == "photo" {
                    let imageUrl = UtilManager.shared.convertToAWSUrl(mediaKey: payload.body)
                    let media = Media(url: imageUrl,
                                      image: nil,
                                      placeholderImage: UIImage(systemName: "photo.fill")!,
                                      size: CGSize(width: 220, height: 220))
                    kind = MessageKind.photo(media)
                } else if payload.type == "video" {
                    let videoUrl = UtilManager.shared.convertToAWSUrl(mediaKey: payload.body)
                    let media = Media(url: videoUrl,
                                      image: nil,
                                      placeholderImage: UIImage(systemName: "video")!,
                                      size: CGSize(width: 220, height: 220))
                    kind = MessageKind.video(media)
                } else if payload.type == "location" {
                    
                } else {
                    kind = MessageKind.text("Unsupported message type")
                }
                guard let finalKind = kind, let sent_date = UtilManager.shared.getMessageDate(dateString: payload.sent_date) else {
                    print("failed to get kind @ send message func")
                    return
                }
                
                let newMessage = Message(sender: sender,
                                         messageId: payload.id,
                                         sentDate: sent_date,
                                         kind: finalKind)
                completion(.success(newMessage))
                return
            case 401:
                TokenManager.shared.requestNewAccessToken { [weak self] result in
                    switch result {
                    case .success(_):
                        self?.sendMessage(new_message: new_message, completion: completion)
                        return
                    case .failure(let error):
                        print("getting new token failed")
                        completion(.failure(error))
                        return
                    }
                }
            case 400:
                completion(.failure(RequestError.badRequest))
                return
            default:
                completion(.failure(RequestError.otherErrorCode))
                return
            }
        }
        task.resume()
        
        
    }
    
    
    
    
    
    
    
    
    
    
}
