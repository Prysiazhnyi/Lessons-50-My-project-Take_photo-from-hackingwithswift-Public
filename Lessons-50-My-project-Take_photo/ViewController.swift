//
//  ViewController.swift
//  Lessons-50-My-project-Take_foto
//
//  Created by Serhii Prysiazhnyi on 11.11.2024.
//

import UIKit

protocol ViewControllerDetailViewControllerDelegate: AnyObject {
    func didDeletePhoto(photo: ImageSave)
    func updatePhotoList(with photos: [ImageSave])
    func didUpdatePhoto(photo: ImageSave)
}

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ViewControllerDetailViewControllerDelegate {
   
    
    
    var photos = [ImageSave]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My photos"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPhotos))
        
        DispatchQueue.global().async {
            let defaults = UserDefaults.standard
            
            if let savedPhotos = defaults.object(forKey: "photo") as? Data {
                let jsonDecoder = JSONDecoder()
                do {
                    self.photos = try jsonDecoder.decode([ImageSave].self, from: savedPhotos)
                    
                    print("Загрузка с памяти")
                } catch {
                    print("!!! Failed to load pictures")
                }
            }
        }
        
        DispatchQueue.main.async {
            // Сортировка и обновление UI на главном потоке
            self.photos.sort { $0.nameImage < $1.nameImage }  // Сортировка по имени изображения
            self.tableView.reloadData() // Обновление таблицы после завершения загрузки
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Photos", for: indexPath)
        
        // Основной текст
        cell.textLabel?.text = photos[indexPath.row].nameImage
        
        // Подзаголовок для каждой строки
        cell.detailTextLabel?.text = "Кол-во просмотров: \(photos[indexPath.row].viewCount)"  // Пример текста подзаголовка
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Увеличиваем счетчик просмотров для выбранного изображения
        photos[indexPath.row].viewCount += 1
        
        print(photos[indexPath.row].viewCount)
        
        tableView.reloadData()
        save()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
           vc.selectPath = getDocumentsDirectory().appendingPathComponent(photos[indexPath.row].imageUID)
            vc.selectedPhoto = photos[indexPath.row]
            vc.delegate = self // Устанавливаем делегат
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(photos) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "photo")
            
            print("Сохранение \(photos)" )
            
        } else {
            print("Failed to save pictures.")
        }
    }
    
    @objc func addNewPhotos() {
        let picker = UIImagePickerController()
        
        // Проверяем, доступна ли камера на устройстве
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // Показываем выбор между камерой и галереей
            let alertController = UIAlertController(title: "Select source", message: nil, preferredStyle: .actionSheet)
            
            // Камера
            alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.presentImagePicker(with: .camera)
            }))
            
            // Фотогалерея
            alertController.addAction(UIAlertAction(title: "Photo Gallery", style: .default, handler: { _ in
                self.presentImagePicker(with: .photoLibrary)
            }))
            
            // Отмена
            alertController.addAction(UIAlertAction(title: "Canсel", style: .cancel))
            
            // Отображаем диалоговое окно
            present(alertController, animated: true)
        } else {
            picker.sourceType = .photoLibrary // Если камера недоступна, используем фотогалерею
        }
        
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func presentImagePicker(with sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        // Создаем Alert с текстовым полем для ввода имени
        let alertController = UIAlertController(title: "Enter Photo Name", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter name or leave blank for 'Unknown'"
        }
        
        // Кнопка "Сохранить" для завершения ввода имени
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alertController] _ in
            guard let self = self else { return }
            let name = alertController?.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Используем введенное имя или значение по умолчанию
            let photoName = name?.isEmpty == false ? name! : "Unknown"
            
            // Создаем и сохраняем объект ImageSave
            let photo = ImageSave(nameImage: photoName, viewCount: 0, imageUID: imageName)
            self.photos.append(photo)
            self.tableView.reloadData()
            save()
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Показать Alert
        dismiss(animated: true) { [weak self] in
            self?.present(alertController, animated: true)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func didDeletePhoto(photo: ImageSave) {
        // Удаляем фото из массива в главном потоке
        DispatchQueue.main.async {
            if let index = self.photos.firstIndex(where: { $0.imageUID == photo.imageUID }) {
                self.photos.remove(at: index)
                self.tableView.reloadData() // Обновляем таблицу
                self.save() // Сохраняем данные сразу после изменения массива
            }
        }
    }
    func updatePhotoList(with photos: [ImageSave]) {
        self.photos = photos
        self.tableView.reloadData()
        save()
    }
    
    func didUpdatePhoto(photo: ImageSave) {
        self.tableView.reloadData()
        save()
    }
}
