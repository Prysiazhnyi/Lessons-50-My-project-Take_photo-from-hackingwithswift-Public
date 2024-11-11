//
//  DetailViewController.swift
//  Lessons-50-My-project-Take_photo
//
//  Created by Serhii Prysiazhnyi on 11.11.2024.
//

import UIKit

protocol DetailViewControllerDelegate: AnyObject {
    func didDeletePhoto(photo: ImageSave)
    func updatePhotoList(with photos: [ImageSave])
    func didUpdatePhoto(_ photo: ImageSave)
    
}


class DetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var selectPath: URL?
   // weak var delegate: DetailViewControllerDelegate?
    weak var delegate: ViewControllerDetailViewControllerDelegate?
    var selectedPhoto: ImageSave?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(reName))
    
        title = selectedPhoto?.nameImage ?? "Unknown"
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
    
    @objc func reName() {
        print("reName method was called")
        
        guard let selectedPhoto = selectedPhoto else {
            print("No photo selected")
            return
        }
        
        print("Selected photo: \(selectedPhoto.nameImage ?? "Unknown")")
        
        // Создаем UIAlertController для выбора действия
        let actionSheet = UIAlertController(title: "Choose an action", message: nil, preferredStyle: .actionSheet)
        
        // Добавляем кнопку для редактирования
        actionSheet.addAction(createEditAction(photo: selectedPhoto))
        
        // Добавляем кнопку для удаления
        actionSheet.addAction(createDeleteAction(photo: selectedPhoto))
        
        // Добавляем кнопку для отмены
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Показываем Action Sheet
        present(actionSheet, animated: true)
    }

    // Функция для создания действия редактирования
    private func createEditAction(photo: ImageSave) -> UIAlertAction {
          return UIAlertAction(title: "Edit name", style: .default) { [weak self] _ in
              guard let self = self else { return }
              
              var updatedPhoto = photo // Копируем объект в изменяемую переменную
              let ac = UIAlertController(title: "Rename photo", message: nil, preferredStyle: .alert)
              ac.addTextField { textField in
                  textField.text = updatedPhoto.nameImage
              }
              ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
              ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                  guard let newName = ac.textFields?.first?.text, !newName.isEmpty else { return }
                  updatedPhoto.nameImage = newName
                  self.selectedPhoto = updatedPhoto // Обновляем выбранную фотографию
                  print("This new name: \(newName)")
                  self.title = newName
                  self.delegate?.didUpdatePhoto(photo: updatedPhoto) // Передаем обновленную фотографию
              })
              self.present(ac, animated: true)
          }
    }

    // Функция для создания действия удаления
    private func createDeleteAction(photo: ImageSave) -> UIAlertAction {
            return UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.didDeletePhoto(photo: photo) // Передаем объект photo
                self.navigationController?.popViewController(animated: true)
                print("Photo deleted")
            }
    }
    
    func saveChanges() {
        // Сохраняем изменения или удаляем фотографию
        if let updatedPhotos = getUpdatedPhotos() {
            delegate?.updatePhotoList(with: updatedPhotos)
        }
    }
    
    func getUpdatedPhotos() -> [ImageSave]? {
        // Возвращаем актуализированный массив
            return [selectedPhoto].compactMap { $0 }
    }
}
