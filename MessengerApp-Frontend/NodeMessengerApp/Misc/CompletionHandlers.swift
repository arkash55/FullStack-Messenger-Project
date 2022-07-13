//
//  CompletionHandlers.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 19/04/2022.
//

import Foundation


public typealias RegistrationCompletion =  (Result<User, Error>) -> Void
public typealias StringCompletion = (Result<String, Error>) -> Void
public typealias DownloadProfilePictureCompletion = (Result<Data, Error>) -> Void
public typealias BooleanCompletion = (Result<Bool, Error>) -> Void
public typealias GetUsersCompletion = (Result<[ComposeChatModel], Error>) -> Void
public typealias GetConversationsCompletion = (Result<[ConversationModel], Error>) -> Void
public typealias GetMessagesCompletion = (Result<[Message], Error>) -> Void
public typealias SendMessageCompletion = (Result<Message, Error>) -> Void
public typealias ListenForMessagesCompletion = (Result<Message, Error>) -> Void
public typealias ListenForConversationLatestMessageCompletion = (Result<UpdateLatestMessageModel, Error>) -> Void
public typealias ListenForConversationCompletion = (Result<ConversationModel, Error>) -> Void
public typealias CreateConversationsCompletion = (Result<ConversationModel, Error>) -> Void


public typealias ConnectToSocketcompletion = (Result< (), Error>) -> Void

