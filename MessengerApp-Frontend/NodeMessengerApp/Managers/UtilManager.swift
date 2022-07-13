//
//  UtilManager.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 19/04/2022.
//

import Foundation
import UIKit

class UtilManager {
    
    static let shared = UtilManager()
    
    public func convertToUrl(urlString: String) -> URL? {
        guard let url = URL(string: urlString) else {return nil}
        return url
    }
    
    public let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "YYYY-dd-mm HH:mm:ss"
        return dateFormatter
    }()
    
    public func convertImageToData(_ image: UIImage) -> Data? {
        guard let imageData = image.jpegData(compressionQuality: 1) else {
            print("failed to convert image to jpeg data")
            return nil
        }
        return imageData
    }
    
    
//    public func generateProfilePicKey(_ email: String) -> String {
//        let dateString = UtilManager.shared.dateFormatter.string(from: Date())
//        return "\(email)-\(dateString)"
//    }
    
    func generateMediaKey(_ email: String) -> String {
        let df = DateFormatter()
        df.timeZone = .current
        df.locale = .current
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let dateString = df.string(from: Date())
        return "\(email)-\(dateString)"
    }
    
    
    public func convertToAWSUrl(mediaKey: String) -> URL? {
        let prefixUrl = "https://nodemessengerapp887bdc07f2b94459a8ed54163c404be200514-dev.s3.eu-west-2.amazonaws.com/public/"
            
        var mediaKeyArray = Array(mediaKey)
        let indexOfAt = mediaKeyArray.firstIndex(of: "@")!
        mediaKeyArray.insert("%", at: indexOfAt)
        
        let indexOfFirstColon = mediaKeyArray.firstIndex(of: ":")!
        mediaKeyArray.insert("%", at: indexOfFirstColon)
        
        let secondIndexOfColon = mediaKeyArray.secondIndex(of: ":")!
        mediaKeyArray.insert("%", at: secondIndexOfColon)
        
        let indexOfPlus = mediaKeyArray.firstIndex(of: "+")!
        mediaKeyArray.insert("%", at: indexOfPlus)

        let newKey = String(mediaKeyArray)
        let path = newKey.replacingOccurrences(of: "@", with: "40").replacingOccurrences(of: ":", with: "3A").replacingOccurrences(of: "+", with: "2B")
        
        let urlString = prefixUrl + path
        guard let url = URL(string: urlString) else {
            print("failed to make url")
            return nil
        }
        return url
    }
    

    
    func getMessageDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "YYYY-dd-mm HH:mm:ss"
        guard let finalDate = dateFormatter.date(from: dateString) else {
            print("dateformatter failed")
            return nil
        }
        return finalDate
    }
    
    
    
    func conversationUpdatedAtTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
//        dateFormatter.dateFormat = "YYYY-dd-mm HH:mm:ss"
//        guard let date = dateFormatter.date(from: dateString) else {
//            print("dateformatter failed")
//            return nil
//        }
        dateFormatter.dateFormat = "HH:mm"
        let timeString = dateFormatter.string(from: date)
        return timeString
    }
    
    
    
    
}









