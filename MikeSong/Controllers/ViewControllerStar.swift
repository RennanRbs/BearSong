//
//  ViewControllerStar.swift
//  BearSong
//
//  Created by Rennan Rebouças on 23/10/18.
//  Copyright © 2018 Rennan Rebouças. All rights reserved.
//

import UIKit
import CoreData

class ViewControllerStar: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    

    
    @IBOutlet weak var collectionView_Star: UICollectionView!
    var favorites = [Favorite]()
    var favoritesImg = [UIImage]()
    
    @IBOutlet weak var imageTest: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView_Star.delegate = self
        collectionView_Star.dataSource = self
        
        
        
        self.collectionView_Star.register(UINib(nibName: "CollectionViewCellFavorite", bundle: nil), forCellWithReuseIdentifier: "FavoriteCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchCoreData()
        mapingImage()
        
        self.collectionView_Star.reloadData()
        
    }
//CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("imagens salvas: \(favorites.count)")
        return favoritesImg.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCell", for: indexPath) as! CollectionViewCellFavorite
        
        cell.uiimage_favorite?.image = favoritesImg[indexPath.item]
        //print("Path: \(String(describing: favorites[indexPath.item].pathImageFavorite))")
         return cell
        
        
    }
    
    
    
    func fetchCoreData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate 
            else {
                return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Favorite>(entityName: "Favorite")
        
        do {
            favorites = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func mapingImage()  {
        self.favoritesImg = favorites.map { (favorite) -> UIImage in
            let fileManager = FileManager.default
            let imagePath = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("fotosfavoritas")
            let imagepath2 = imagePath.appendingPathComponent(favorite.pathImageFavorite!)
            if let data = try? Data.init(contentsOf: imagepath2), let image = UIImage.init(data: data) {
                return image
            } else {
                print("não achou uma image no filemanager")
                return UIImage()
            }
        }

    }
    
    
    func getImage(imageName: String){
        
        let fileManager = FileManager.default
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("fotosfavoritas")
        let imagepath2 = (imagePath as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagepath2){
            print("image found")
        }else{
            print("Panic! No Image!")
        }
    }
}


extension ViewControllerStar: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let largura = self.collectionView_Star.frame.width
        let side = (largura - 16)
        return CGSize(width: side, height: side)
    }
    
}
