//
//  StorageManager.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 21/04/2022.
//

import Foundation
import UIKit
import Amplify





class StorageManager {
    
    static let shared = StorageManager()
    
    
    
    ///UPLOAD A USERS PROFILE PICTURE
    func uploadProfilePicture(email: String, profile_image: UIImage, completion: @escaping StringCompletion) {
        guard let imageData = UtilManager.shared.convertImageToData(profile_image) else {
            return completion(.failure(DataError.PngConversionFailed))
        }
        
        let imageKey = "profile_image/\(UtilManager.shared.generateMediaKey(email)).png"
        
        Amplify.Storage.uploadData(key: imageKey, data: imageData) { result in
            switch result {
            case .success(let responseData):
                completion(.success(responseData))
                return
            case.failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
    
    
    
    
    func uploadPhotoMessage(email: String, message_image: UIImage, completion: @escaping StringCompletion) {
        guard let imageData = UtilManager.shared.convertImageToData(message_image) else {
            completion(.failure(DataError.PngConversionFailed))
            return
        }
        
        let imageKey = "message_image/\(UtilManager.shared.generateMediaKey(email)).png"
        
        //upload to aws s3 bucket
        Amplify.Storage.uploadData(key: imageKey, data: imageData) { result in
            switch result {
            case .success(let photo_image_key):
                completion(.success(photo_image_key))
                return
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
        
    }
    
    
    
    
    func uploadVideoMessage(email: String, message_video_url: URL, completion: @escaping StringCompletion) {
        let videoKey = "message_video/\(UtilManager.shared.generateMediaKey(email)).mov"
        
        Amplify.Storage.uploadFile(key: videoKey, local: message_video_url) { result in
            switch result   {
            case .success(_):
                completion(.success(videoKey))
                return
            case .failure(let error):
                print(error)
                completion(.failure(error))
                return
            }
        }
        
    }
    
    
    
    
    
    
    
    
}
