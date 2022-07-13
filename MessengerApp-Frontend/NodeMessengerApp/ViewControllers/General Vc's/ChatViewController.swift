//
//  ChatViewController.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 25/04/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SocketIO
import SDWebImage
import AVKit
import AVFoundation



class ChatViewController: MessagesViewController  {
    
    private let sender: Sender? = {
        guard let sender_id = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let username = UserDefaults.standard.value(forKey: "username") as? String else {
                  return nil
              }
        return Sender(senderId: sender_id, displayName: username)
    }()
    
    private let picker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        return picker
    }()
    
    private var messages = [Message]()
    private var socketChatManager: SocketChatManager?
    private var socketConversationManager: SocketConversationManager?
    
    
    
    private var recipient: ComposeChatModel
    private var conversation_id: Int?
    public var isNewConversation = false
        
    
    init(recipient: ComposeChatModel, conversation_id: Int?) {
        self.recipient = recipient
        self.conversation_id = conversation_id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureMessageKit()
        messageInputBar.delegate = self
        picker.delegate = self
        configureInputBar()
        fetchMessages()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        oldConversationConfiguration()
        configureRecipientConversationSocket()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let socketChatManager = socketChatManager else {
            return
        }
        socketChatManager.closeConnextion()

    }
    
    
    
    //methods
    //connects to recipients convo rooms
    private func configureRecipientConversationSocket() {
        guard let uid = UserDefaults.standard.value(forKey: "user_id") as? Int else {
            return
        }
        let socketManager = SocketConversationManager(current_uid: uid, recipient_uid: recipient.id)
        self.socketConversationManager = socketManager
        self.socketConversationManager?.establishConnection()
    }
    
    private func oldConversationConfiguration() {
        if isNewConversation == false {
            guard let conversation_id = conversation_id else {
                print("no convo id")
                return
            }
        
            let socketChatManager = SocketChatManager(conversation_id: conversation_id)
            self.socketChatManager = socketChatManager
            self.socketChatManager?.establishConnection()
            listenForMessages()
        }
    }
    

    
    private func configureNavigationBar() {
        navigationItem.title = recipient.username
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureInputBar() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.didTapAttachMedia()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func configureMessageKit() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
    }
    
    private func listenForMessages() {
        guard let scm = socketChatManager else {
            print("no scm")
            return
        }
        
        print("listening for new messages")
        scm.listenForMessages { [weak self] result in
            switch result {
            case .success(let newMessage):
                DispatchQueue.main.async {
                    self?.messages.append(newMessage)
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                }
                print("successfully got new message")
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    private func fetchMessages() {
        guard let conversation_id = conversation_id else {
            print("no convo id")
            return
        }
        ConversationManager.shared.getConversationMessages(conversation_id: conversation_id, otherUser: recipient) { [weak self] result in
            switch result {
            case .success(let messages):
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
//                    self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
                }
                print("success in getting messages")
            case .failure(let error):
                print(error)
                guard let strongSelf = self else {return}
                DispatchQueue.main.async {
                    AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Something went wrong...", message: "Could not load messages")
                }
            }
        }
    }
    
    private func didTapAddPhoto() {
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "Where would you like to attach the photo from?",
                                            preferredStyle: .actionSheet)
        
        
        actionSheet.addAction(UIAlertAction(title: "Camera",
                                            style: .default,
                                            handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            self?.picker.mediaTypes = ["public.image"]
            self?.picker.sourceType = .camera
            self?.present(strongSelf.picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library",
                                            style: .default,
                                            handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            self?.picker.mediaTypes = ["public.image"]
            self?.picker.sourceType = .photoLibrary
            self?.present(strongSelf.picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.popoverPresentationController?.sourceRect = view.bounds
        actionSheet.popoverPresentationController?.sourceView = view
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    private func didTapAddVideo() {
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "Where would you like to attach the video from?",
                                            preferredStyle: .actionSheet)
        
        
        actionSheet.addAction(UIAlertAction(title: "Camera",
                                            style: .default,
                                            handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            self?.picker.mediaTypes = ["public.movie"]
            self?.picker.sourceType = .camera
            self?.picker.videoQuality = .typeHigh
            self?.present(strongSelf.picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Video Library",
                                            style: .default,
                                            handler: { [weak self] _ in
            guard let strongSelf = self else {return}
            self?.picker.mediaTypes = ["public.movie"]
            self?.picker.sourceType = .photoLibrary
            self?.picker.videoQuality = .typeHigh
            self?.present(strongSelf.picker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.popoverPresentationController?.sourceRect = view.bounds
        actionSheet.popoverPresentationController?.sourceView = view
        present(actionSheet, animated: true, completion: nil)
    }
    

    
    
    
    private func didTapAttachMedia() {
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "What media type would you like to send?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo",
                                            style: .default,
                                            handler: { [weak self]_ in
            self?.didTapAddPhoto()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Video",
                                            style: .default,
                                            handler: { [weak self]_ in
            self?.didTapAddVideo()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Location",
                                            style: .default,
                                            handler: { [weak self]_ in
            //add location image stuff
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.popoverPresentationController?.sourceRect = view.bounds
        actionSheet.popoverPresentationController?.sourceView = view
        present(actionSheet, animated: true, completion: nil)
        
        
    }
}



/// CONFIGURE MESSAGE DATA
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        guard let selfSender = sender else {
            return Sender(senderId: 0, displayName: "")
        }
        return selfSender
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let current_user_profile_key = UserDefaults.standard.value(forKey: "profile_pic_key") as? String else {return}
        
        if isFromCurrentSender(message: message) {
            guard let imageUrl = UtilManager.shared.convertToAWSUrl(mediaKey: current_user_profile_key) else {
                return
            }
            DispatchQueue.main.async {avatarView.sd_setImage(with: imageUrl, completed: nil)}
            return
        } else {
            guard let imageUrl = UtilManager.shared.convertToAWSUrl(mediaKey: recipient.profile_pic_key) else {
                return
            }
            DispatchQueue.main.async {avatarView.sd_setImage(with: imageUrl, completed: nil)}
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let messageStyle: MessageStyle = isFromCurrentSender(message: message) ? MessageStyle.bubbleTail(.bottomRight, .curved) : MessageStyle.bubbleTail(.bottomLeft, .curved)
        return messageStyle
    }
    
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let backgroundColour: UIColor = isFromCurrentSender(message: message) ? UIColor.link : UIColor.systemGray5
        return backgroundColour
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch message.kind {
        case .photo(let media):
            imageView.sd_setImage(with: media.url, completed: nil)
        default:
            break
        }
    }
    
    
    
    
    
    
}







/// SENDING MESSAGES TO BOTH NEW AND EXISTING CONVERSATIONS
extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        DispatchQueue.main.async {
            self.messageInputBar.inputTextView.text = nil
        }
        
        guard let user_id = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let username = UserDefaults.standard.value(forKey: "username") as? String else {
                  print("missing cache")
                  return
              }
        
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            print("failed to get text")
            return
        }
        
        
        if isNewConversation {
            //we are already connected to the user conversation socket
            //create_convo --> is_new_convo == false & assign convo_id --> old convo configuration -->  create message --> send to chat socket --> send new convo to users in user_conversation room
            let convo_model = CreateConversationModel(user_1: user_id,
                                                      user_2: recipient.id,
                                                      latest_message: text,
                                                      latest_message_type: MessageValueType.text)
            ConversationManager.shared.createNewConversation(conversation: convo_model) { [weak self] result in
                guard let strongSelf = self else {return}
                switch result {
                case .success(let newConvo):
                    self?.conversation_id = newConvo.id
                    self?.isNewConversation = false
                    self?.oldConversationConfiguration()
                    
                    guard let conversation_id = self?.conversation_id else {return}
                    
                    let messageModel = SendMessageModel(conversation_id: conversation_id,
                                                        sender_id: user_id,
                                                        body: text,
                                                        type: MessageValueType.text)
                    
                    ConversationManager.shared.sendMessage(new_message: messageModel) { [weak self] result in
                        switch result {
                        case .success(_):
                            let updatedAtDateString = UtilManager.shared.dateFormatter.string(from: newConvo.updatedAt)
                            let newConversationSocketData: [String: Any] = [
                                "id": conversation_id,
                                "latest_message": newConvo.latest_message,
                                "latest_message_type": newConvo.latest_message_type,
                                "updatedAt": updatedAtDateString,
                                "recipient_id": newConvo.recipient.id,
                                "recipient_username": newConvo.recipient.username,
                                "recipient_first_name": newConvo.recipient.first_name,
                                "recipient_last_name": newConvo.recipient.last_name,
                                "recipient_profile_pic_key": newConvo.recipient.profile_pic_key
                            ]
                            
                            self?.socketConversationManager?.didCreateNewConversation(conversation_data: newConversationSocketData)
                            self?.fetchMessages()
                        case .failure(let error):
                            print(error)
                            DispatchQueue.main.async {
                                AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Something went wrong...", message: "Could not send message")
                            }
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {
                        AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Something went wrong...", message: "Could not create a new conversation")
                    }
                }
            }
            
            
        } else {
            guard let conversation_id = conversation_id else {return}
            let messageModel = SendMessageModel(conversation_id: conversation_id,
                                                sender_id: user_id,
                                                body: text,
                                                type: MessageValueType.text)
            
            ConversationManager.shared.sendMessage(new_message: messageModel) { [weak self] result in
                switch result {
                case .success(let newMessage):
                    let dateString = UtilManager.shared.dateFormatter.string(from: newMessage.sentDate)
                    let chat_message_data: [String: Any] = [
                        "sender_id": user_id,
                        "sender_username": username,
                        "text": "\(text)",
                        "type": newMessage.kind.messageKindString,
                        "dateString": dateString,
                        "message_id": newMessage.messageId
                    ]
                    
                    let convo_message_data: [String: Any] = [
                        "conversation_id": conversation_id,
                        "text": "\(text)",
                        "type": newMessage.kind.messageKindString,
                        "dateString": dateString,
                    ]
                    
                    
                    guard let socketChatManager = self?.socketChatManager else {
                        print("no socketChatManager")
                        return
                    }
                    
                    guard let socketConvoManager = self?.socketConversationManager else {
                        print("no socketConvoManager")
                        return
                    }
                    
                    socketChatManager.sendMessage(message_data: chat_message_data)
                    socketConvoManager.didSendMessage(convo_message_data: convo_message_data)
                    
 
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}



/// SENDING PHOTO AND VIDEO MESSAGES
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let email = UserDefaults.standard.value(forKey: "email") as? String,
              let uid = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let username = UserDefaults.standard.value(forKey: "username") as? String,
              let selfSender = sender,
              let conversation_id = conversation_id else {return}
        
        //get image or video
        if let pickedImage = info[.editedImage] as? UIImage {
            
            //upload to s3
            StorageManager.shared.uploadPhotoMessage(email: email, message_image: pickedImage) { [weak self] result in
                switch result {
                case .success(let imageKey):
                    //upload message to postgres db
                    let message = SendMessageModel(conversation_id: conversation_id,
                                                   sender_id: uid,
                                                   body: imageKey,
                                                   type: MessageValueType.photo)
                    
                    ConversationManager.shared.sendMessage(new_message: message) { [weak self] result in
                        switch result {
                        case .success(let newMessage):
                            //send message via web-socket
                            let dateString = UtilManager.shared.dateFormatter.string(from: newMessage.sentDate)
                            
                            let chat_message_data: [String: Any] = [
                                "sender_id": newMessage.sender.senderId  ,
                                "sender_username": username,
                                "text": "\(imageKey)",
                                "type": newMessage.kind.messageKindString,
                                "dateString": dateString,
                                "message_id": newMessage.messageId
                            ]
                            
                            
                            let convo_message_data: [String: Any] = [
                                "conversation_id": conversation_id,
                                "text": "\(imageKey)",
                                "type": newMessage.kind.messageKindString,
                                "dateString": dateString,
                            ]
                            
                            guard let socketChatManager = self?.socketChatManager else {
                                print("no socketChatManager")
                                return
                            }
                            
                            guard let socketConvoManager = self?.socketConversationManager else {
                                print("no socketConvoManager")
                                return
                            }
                            
                            socketChatManager.sendMessage(message_data: chat_message_data)
                            socketConvoManager.didSendMessage(convo_message_data: convo_message_data)
                            return
                            
                        case .failure(let error):
                            print(error)
                            guard let strongSelf = self else {return}
                            DispatchQueue.main.async {
                                AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Something went wrong...", message: "Could not send the photo message")
                            }
                        }
                    }
                    
                    
                case .failure(let error):
                    print(error)
                    guard let strongSelf = self else {return}
                    DispatchQueue.main.async {
                        AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Something went wrong", message: "Could not send the photo message")
                    }
                }
            }
            
            
            
        } else if let pickedVideoUrl = info[.mediaURL] as? URL {
            //upload video and get key
            StorageManager.shared.uploadVideoMessage(email: email, message_video_url: pickedVideoUrl) { [weak self] result in
                switch result {
                case .success(let videoKey):
                    print("success in video upload")
                    //send message to postgres
                    let messageModel = SendMessageModel(conversation_id: conversation_id,
                                                      sender_id: uid,
                                                      body: videoKey,
                                                      type: MessageValueType.video)
                    
                    ConversationManager.shared.sendMessage(new_message: messageModel) { [weak self] result in
                        switch result {
                        case .success(let newMessage):
                            //send to socket
                            print("here")
                            let dateString = UtilManager.shared.dateFormatter.string(from: newMessage.sentDate)
                            
                            let chat_message_data: [String: Any] = [
                                "sender_id": newMessage.sender.senderId  ,
                                "sender_username": username,
                                "text": "\(videoKey)",
                                "type": newMessage.kind.messageKindString,
                                "dateString": dateString,
                                "message_id": newMessage.messageId
                            ]
                            
                            
                            let convo_message_data: [String: Any] = [
                                "conversation_id": conversation_id,
                                "text": "\(videoKey)",
                                "type": newMessage.kind.messageKindString,
                                "dateString": dateString,
                            ]
                            
                            guard let socketChatManager = self?.socketChatManager else {
                                print("no socketChatManager")
                                return
                            }
                            
                            guard let socketConvoManager = self?.socketConversationManager else {
                                print("no socketConvoManager")
                                return
                            }
                            
                            socketChatManager.sendMessage(message_data: chat_message_data)
                            socketConvoManager.didSendMessage(convo_message_data: convo_message_data)
                            return
                            
                        case .failure(let error):
                            print(error)
                            guard let strongSelf = self else {return}
                            DispatchQueue.main.async {
                                AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Something went wrong...", message: "Could not send the video message")
                            }
                        }
                    }
                    
                    
                   
                case .failure(let error):
                    print(error)
                    guard let strongSelf = self else {return}
                    DispatchQueue.main.async {
                        AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Something went wrong...", message: "Could not send the video message")
                    }
                }
            }


            
            
        }

    }
    
}




///CONFIGURE TAPPING PHOTO, VIDEO AND LOCATION MESSAGES
extension ChatViewController: MessageCellDelegate {
    
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {return}
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .photo(let mediaItem):
            guard let imageUrl = mediaItem.url else {return}
            let vc = PhotoMessageViewController(photo_message_url: imageUrl)
            navigationController?.pushViewController(vc, animated: true)
        case .video(let mediaItem):
            guard let videoUrl = mediaItem.url else {return}
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true) {
                vc.player?.play()
            }
        default:
            break
        }
    }
    
    
    
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {return}
        let message = messages[indexPath.section]
        
        switch message.kind {
        case .location(let locationItem):
            break
        default:
            break
        }
        
    }
    
    
    
    
}

