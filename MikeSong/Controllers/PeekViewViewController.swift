//
//  PeekViewViewController.swift
//  BearSong
//
//  Created by Rennan Rebouças on 22/10/18.
//  Copyright © 2018 Rennan Rebouças. All rights reserved.
//

import UIKit
import CoreData

class PeekViewViewController: UIViewController {

    @IBOutlet weak var uiimage_peekImage: UIImageView!
    @IBOutlet weak var label_peekText: UILabel!
    var favorites: [NSManagedObject] = []
    
    var peekimage: UIImage?
    var peekText: String?
    var urlMusic: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let peekimage = peekimage{
            uiimage_peekImage.image = peekimage
        }
        
        if let peekText = peekText {
            label_peekText.text = peekText
        }
        
        createDirectory()
        
        
    }
    
    override var previewActionItems: [UIPreviewActionItem] {
        
        let action = UIPreviewAction(title: "Favorite this HotSong", style: .default) { (action, viewController) in
            print("I believe I can fly")
            let id = UUID.init().uuidString
            self.saveFavoriteCoreData(pathImage: id, name: self.peekText!)
            self.SaveImageFileManager(nameImage: id, photo: self.peekimage!)
        }
        
        let action2 = UIPreviewAction(title: "Listen this Song", style: .default){(action2, ViewController) in
            let url = URL(string: self.urlMusic!)
            UIApplication.shared.open(url!)
        }

        
        
        return [action,action2]
    }
    
// função save on CoreData
    func saveFavoriteCoreData(pathImage: String, name: String)  {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Favorite",in: managedContext)!
        let person = NSManagedObject(entity: entity,insertInto: managedContext)
        
        person.setValue(pathImage, forKeyPath: "pathImageFavorite")
        person.setValue(name, forKeyPath: "name")
        
        do {
            try managedContext.save()
            favorites.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    
   
    
//file Manager
    func createDirectory(){
        
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("fotosfavoritas")
        
        if !fileManager.fileExists(atPath: paths){
            
            try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
            
        }else{
            print("Diretorio Favoritos já criado.")
        }
    }
    
//save Image On File Manager
    func SaveImageFileManager(nameImage: String, photo: UIImage) {
       
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("fotosfavoritas")
        let imagePath = (path as NSString).appendingPathComponent(nameImage)
        
        let image = photo
        let data = image.pngData()
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
    }
    



    
}
