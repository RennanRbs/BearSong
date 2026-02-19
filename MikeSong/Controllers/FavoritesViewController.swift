//
//  FavoritesViewController.swift
//  BearSong
//
//  Created by Rennan Rebouças on 23/10/18.
//  Copyright © 2018 Rennan Rebouças. All rights reserved.
//

import UIKit
import CoreData

class FavoritesViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var favoritesCollectionView: UICollectionView!
    @IBOutlet weak var previewImageView: UIImageView!

    var favorites = [Favorite]()
    var favoriteImages = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(title: "Favorites")
        if #available(iOS 13.0, *) {
            let item = UITabBarItem(
                title: nil,
                image: UIImage(systemName: "star"),
                selectedImage: UIImage(systemName: "star.fill")
            )
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            (navigationController ?? self).tabBarItem = item
        }
        favoritesCollectionView.delegate = self
        favoritesCollectionView.dataSource = self
        favoritesCollectionView.register(UINib(nibName: "FavoriteItemCell", bundle: nil), forCellWithReuseIdentifier: "FavoriteCell")
        if let flowLayout = favoritesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = LayoutConstants.sectionInset
            flowLayout.minimumLineSpacing = LayoutConstants.cellSpacing
            flowLayout.minimumInteritemSpacing = LayoutConstants.cellSpacing
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavoritesFromCoreData()
        loadFavoriteImages()
        favoritesCollectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCell", for: indexPath) as! FavoriteItemCell
        cell.uiimage_favorite?.image = favoriteImages[indexPath.item]
        return cell
    }

    func fetchFavoritesFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
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

extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = favoritesCollectionView.frame.width
        let cellSideLength = collectionViewWidth - LayoutConstants.sectionInset.left - LayoutConstants.sectionInset.right
        return CGSize(width: cellSideLength, height: cellSideLength)
    }
}
