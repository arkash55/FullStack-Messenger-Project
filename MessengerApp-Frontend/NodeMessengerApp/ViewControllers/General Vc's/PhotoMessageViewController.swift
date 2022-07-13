//
//  PhotoMessageViewController.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 03/07/2022.
//

import UIKit

class PhotoMessageViewController: UIViewController {
    
    private let photoImageView: UIImageView = {
        let photoImageView = UIImageView()
        photoImageView.image = UIImage(systemName: "photo.fill")
        photoImageView.backgroundColor = .secondaryLabel
        photoImageView.layer.masksToBounds = true
        photoImageView.layer.cornerRadius = 8.0
        return photoImageView
    }()
    
    private let imageUrl: URL
    
    
    init(photo_message_url: URL) {
        self.imageUrl = photo_message_url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureImageView()

    }
    
    override func viewDidLayoutSubviews() {
        let imageSize = view.frame.size.width - 40
        
        
        photoImageView.frame = CGRect(x: view.frame.midX - imageSize/2,
                                      y: view.frame.midY - imageSize/2,
                                      width: imageSize,
                                      height: imageSize)
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Photo Message"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureImageView() {
        view.addSubview(photoImageView)
        DispatchQueue.main.async {
            self.photoImageView.sd_setImage(with: self.imageUrl, completed: nil)
        }
    }
    
    

   

}
