//
//  ViewController.swift
//  Lessons-50-My-project-Take_foto
//
//  Created by Serhii Prysiazhnyi on 11.11.2024.
//

import UIKit

class ViewController: UITableViewController {
    
    var photos = [ImageSave]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        title = "My photos"
        navigationController?.navigationBar.prefersLargeTitles = false
        
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
            vc.selectedImage = photos[indexPath.row].nameImage
            vc.selectedPictureNumber = indexPath.row + 1
            vc.totalPictures = photos.count
            // 3: now push it onto the navigation controller
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
    
}

