//
//  AuthManager.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 19/04/2022.
//

import Foundation
import UIKit


class AuthManager {
    
    static let shared = AuthManager()
    
    private func decodeErrorMessage(data: Data) -> String? {
        guard let errorMessage = try? JSONDecoder().decode(ErrorMessageModel.self, from: data) else {
            print("failed to decode error message")
            return nil
        }
        print(errorMessage.message)
        return errorMessage.message
    }
    
    ///FIRST STEP IN REGISTERING A NEW USER (JSON DATA)
    private func registerNewUser(user: RegistrationModel, completion: @escaping RegistrationCompletion) {
        guard let url = ApiUrls.registrationUrl else {
            completion(.failure(TaskError.faulty_url))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.POST
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let encodedData = try? JSONEncoder().encode(user)  else {
            completion(.failure(DataError.encode_failed))
            return
        }
        request.httpBody = encodedData
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                if let error = error {print(error) }
                completion(.failure(TaskError.task_failed))
                return
            }
            switch response.statusCode {
            case 400:
                completion(.failure(RequestError.badRequest))
                return
            case 422:
                guard let errorMessage = self?.decodeErrorMessage(data: data) else {
                    completion(.failure(DataError.decode_failed))
                    return
                }
                if errorMessage == ErrorMessages.emailIsTaken {
                    completion(.failure(RegistrationError.emailTaken))
                } else if errorMessage == ErrorMessages.usernameIsTaken {
                    completion(.failure(RegistrationError.usernameTaken))
                }
                return
            case 201:
                //decode data
                guard let decodedData = try? JSONDecoder().decode(User.self, from: data) else {
                    completion(.failure(DataError.decode_failed))
                    return
                }
                completion(.success(decodedData))
                return
            default:
                break
            }
        }
        task.resume()
    }
    
    
    ///REGISTER A NEW USER
    public func completeNewUserRegistration(username: String, email: String, first_name: String, last_name: String, password: String, profileImage: UIImage, completion: @escaping BooleanCompletion) {
        //upload profile pic and return key
        StorageManager.shared.uploadProfilePicture(email: email, profile_image: profileImage) { [weak self] result in
            switch result {
            case .success(let profilePicKey):
                let newUser = RegistrationModel(username: username, email: email, first_name: first_name, last_name: last_name, password: password, profile_pic_key: profilePicKey)
                self?.registerNewUser(user: newUser, completion: { result in
                    switch result {
                    case .success(let userData):
                        UserDefaults.standard.set(userData.id, forKey: "user_id")
                        UserDefaults.standard.set(userData.email, forKey: "email")
                        UserDefaults.standard.set(userData.username, forKey: "username")
                        UserDefaults.standard.set(userData.first_name, forKey: "first_name")
                        UserDefaults.standard.set(userData.last_name, forKey: "last_name")
                        UserDefaults.standard.set(userData.profile_pic_key, forKey: "profile_pic_key")
                        UserDefaults.standard.set(userData.access_token, forKey: "access_token")
                        UserDefaults.standard.set(userData.refresh_token, forKey: "refresh_token")
                        completion(.success(true))
                        return
                    case .failure(let error):
                        completion(.failure(error))
                        return
                    }
                })
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
    }
    
    
    
    
    ///LOGIN A USER
    public func loginUser(user: LoginModel, completion: @escaping BooleanCompletion) {
        guard let url = ApiUrls.loginUrl else {
            completion(.failure(TaskError.faulty_url))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.POST
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let encodedData = try? JSONEncoder().encode(user) else {
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
                guard let userData = try? JSONDecoder().decode(User.self, from: data) else {
                    completion(.failure(DataError.decode_failed))
                    return
                }
                UserDefaults.standard.set(userData.id, forKey: "user_id")
                UserDefaults.standard.set(userData.email, forKey: "email")
                UserDefaults.standard.set(userData.username, forKey: "username")
                UserDefaults.standard.set(userData.first_name, forKey: "first_name")
                UserDefaults.standard.set(userData.last_name, forKey: "last_name")
                UserDefaults.standard.set(userData.profile_pic_key, forKey: "profile_pic_key")
                UserDefaults.standard.set(userData.access_token, forKey: "access_token")
                UserDefaults.standard.set(userData.refresh_token, forKey: "refresh_token")
                completion(.success(true))
                return
            case 400:
                completion(.failure(RequestError.badRequest))
                return
            case 401:
                completion(.failure(AuthError.incorrect_password))
                return
            case 403:
                completion(.failure(AuthError.user_not_verified))
                return
            case 404:
                completion(.failure(AuthError.user_does_not_exist))
                return
            default:
                completion(.failure(RequestError.otherErrorCode))
            }
        }
        task.resume()
    }
    
    
    func logOutUser(completion: @escaping BooleanCompletion) {
        guard let uid = UserDefaults.standard.value(forKey: "user_id") as? Int,
              let refresh_token = UserDefaults.standard.value(forKey: "refresh_token") as? String else {
            completion(.failure(DataError.missing_cache))
            return
        }
        var request = URLRequest(url: ApiUrls.logOutUrl!)
        request.httpMethod = HttpMethods.POST
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(refresh_token)", forHTTPHeaderField: "Authorization")
        
        guard let encodedData = try? JSONEncoder().encode(LogOutModel(uid: uid)) else {
            completion(.failure(DataError.decode_failed))
            return
        }
        request.httpBody = encodedData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse, error == nil else {
                if let error = error {
                    print(error)
                    completion(.failure(TaskError.task_failed))
                }
                return
            }
            switch response.statusCode {
            case 201:
                completion(.success(true))
                return
            case 400:
                completion(.failure(RequestError.badRequest))
            default:
                completion(.failure(RequestError.otherErrorCode))
            }
        }
        task.resume()
        
        
    }
    
    
    
    
    
    
}





