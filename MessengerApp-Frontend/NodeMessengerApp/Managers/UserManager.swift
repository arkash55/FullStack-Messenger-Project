//
//  UserManager.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 23/04/2022.
//

import Foundation


class UserManager {
    
    static let shared = UserManager()
    
    
    ///UPDATE CURRENT USERS DATA
    public func updateUserData(updatedUserModel: UpdateUserProfileModel, completion: @escaping BooleanCompletion) {
        guard let url = ApiUrls.updateUserDetailUrl else {
            completion(.failure(TaskError.faulty_url))
            return
        }
        
        guard let access_token = UserDefaults.standard.value(forKey: "access_token") as? String else {
            completion(.failure(DataError.missing_cache))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = HttpMethods.PATCH
        
  
        guard let encodedData = try? JSONEncoder().encode(updatedUserModel) else {
            completion(.failure(DataError.encode_failed))
            return
        }
        request.httpBody = encodedData
        
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
                guard let userData = try? JSONDecoder().decode(UpdateUserProfileModel.self, from: data) else {
                    completion(.failure(DataError.decode_failed))
                    return
                }
                UserDefaults.standard.set(userData.username, forKey: "username")
                UserDefaults.standard.set(userData.first_name, forKey: "first_name")
                UserDefaults.standard.set(userData.last_name, forKey: "last_name")
                UserDefaults.standard.set(userData.profile_pic_key, forKey: "profile_pic_key")
                completion(.success(true))
            case 401:
                TokenManager.shared.requestNewAccessToken { [weak self] result in
                    switch result {
                    case .success(_):
                        self?.updateUserData(updatedUserModel: updatedUserModel, completion: completion)
                        return
                    case .failure(let error):
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
    
    
    
    
    
    ///GET ALL USERS WITHIN THE APP
    public func getAllUsers(completion: @escaping GetUsersCompletion) {
        guard let url = ApiUrls.getAllUsers else {
            completion(.failure(TaskError.faulty_url))
            return
        }
        
        guard let access_token = UserDefaults.standard.value(forKey: "access_token") as? String else {
            completion(.failure(DataError.missing_cache))
            return
        }
        
        var request = URLRequest(url: url)
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
                guard let payload = try? JSONDecoder().decode([ComposeChatModel].self, from: data) else {
                    completion(.failure(DataError.decode_failed))
                    return
                }
                completion(.success(payload))
                return
            case 401:
                TokenManager.shared.requestNewAccessToken { [weak self] result in
                    switch result {
                    case .success(_):
                        self?.getAllUsers(completion: completion)
                        return
                    case .failure(let error):
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
