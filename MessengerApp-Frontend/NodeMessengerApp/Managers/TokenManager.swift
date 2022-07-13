//
//  TokenManager.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 23/04/2022.
//

import Foundation
import UIKit




class TokenManager: UIViewController {
    
    static let shared = TokenManager()
    
    
    public func requestNewAccessToken(completion: @escaping BooleanCompletion) {
        guard let refresh_token = UserDefaults.standard.value(forKey: "refresh_token") as? String else {
            completion(.failure(DataError.missing_cache))
            return
        }
        guard let url = ApiUrls.getNewAccessToken else {
            completion(.failure(TaskError.faulty_url))
            return
        }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.POST
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(refresh_token)", forHTTPHeaderField: "Authorization")
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                if let error = error {
                    print(error)
                    completion(.failure(TaskError.task_failed))
                }
                return
            }
            
            switch response.statusCode {
            case 201:
                guard let payload = try? JSONDecoder().decode(AccessTokenModel.self, from: data) else {
                    completion(.failure(DataError.decode_failed))
                    return
                }
                UserDefaults.standard.set(payload.access_token, forKey: "access_token")
                completion(.success(true))
            case 401:
                AuthManager.shared.logOutUser { [weak self] result in
                    switch result {
                    case .success(_):
                        NotificationCenter.default.post(name: NSNotification.Name(NotificationKeyNameString.logOut), object: nil)
                        guard let strongSelf = self else {return}
                        DispatchQueue.main.async {
                            self?.navigationController?.popToRootViewController(animated: true)
                            self?.tabBarController?.selectedIndex = 0
                            AlertManager.shared.showErrorAlert(vc: strongSelf, title: "Refresh Token Expired", message: "Please log in to continue")
                        }
                        completion(.success(true))
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
    
    
    
    
    
    
    
    
}
