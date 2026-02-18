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
    

    
    @IBOutlet weak var favoritesCollectionView: UICollectionView!
    var favorites = [Favorite]()
    var favoriteImages = [UIImage]()
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoritesCollectionView.delegate = self
        favoritesCollectionView.dataSource = self
        
        favoritesCollectionView.register(UINib(nibName: "CollectionViewCellFavorite", bundle: nil), forCellWithReuseIdentifier: "FavoriteCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFavoritesFromCoreData()
        loadFavoriteImages()
        
        favoritesCollectionView.reloadData()
    }
//CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("imagens salvas: \(favorites.count)")
        return favoriteImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCell", for: indexPath) as! CollectionViewCellFavorite
        cell.uiimage_favorite?.image = favoriteImages[indexPath.item]
        return cell
    }
    
    
    
    func fetchFavoritesFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Favorite>(entityName: "Favorite")
        
        do {
            favorites = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func loadFavoriteImages() {
        favoriteImages = favorites.map { favorite -> UIImage in
            let fileManager = FileManager.default
            let favoritesDirectoryURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("fotosfavoritas")
            let imageFileURL = favoritesDirectoryURL.appendingPathComponent(favorite.pathImageFavorite!)
            if let data = try? Data(contentsOf: imageFileURL), let image = UIImage(data: data) {
                return image
            } else {
                print("não achou uma imagem no filemanager")
                return UIImage()
            }
        }
    }
    
    func checkImageExists(imageName: String) {
        let fileManager = FileManager.default
        let favoritesDirectoryPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("fotosfavoritas")
        let imageFilePath = (favoritesDirectoryPath as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imageFilePath) {
            print("image found")
        } else {
            print("Panic! No Image!")
        }
    }
}


extension ViewControllerStar: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = favoritesCollectionView.frame.width
        let cellSideLength = collectionViewWidth - 16
        return CGSize(width: cellSideLength, height: cellSideLength)
    }
    
}
