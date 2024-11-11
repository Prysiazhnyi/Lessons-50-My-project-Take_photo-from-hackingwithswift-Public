//
//  DetailViewController.swift
//  Lessons-50-My-project-Take_photo
//
//  Created by Serhii Prysiazhnyi on 11.11.2024.
//

import UIKit

protocol DetailViewControllerDelegate: AnyObject {
    func didDeletePerson(at indexPath: IndexPath)
}

class DetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var selectedImage: String?
    var selectedPictureNumber = 0
    var totalPictures = 0
    var selectPath: URL?
    var imageName:  String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = imageName ?? "This image is \(selectedPictureNumber) from \(totalPictures)"
        navigationItem.largeTitleDisplayMode = .never
        if let path = selectPath {
            imageView.image = UIImage(contentsOfFile: path.path)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
}
