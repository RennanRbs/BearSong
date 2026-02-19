//
//  FavoriteStorageHelper.swift
//  BearSong
//
//  Shared logic for saving favorites to Core Data and disk.
//

import UIKit
import CoreData

enum FavoriteStorageHelper {

    static let favoritesSubdirectory = "fotosfavoritas"

    /// Creates the favorites directory in Documents if it does not exist.
    static func createDirectoryIfNeeded() {
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(favoritesSubdirectory)
        if !fileManager.fileExists(atPath: paths) {
            try? fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
        }
    }

    /// Saves the image to Documents/fotosfavoritas/<nameImage> as PNG.
    static func saveImageToDisk(nameImage: String, photo: UIImage) {
        let fileManager = FileManager.default
        let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(favoritesSubdirectory)
        let imagePath = (path as NSString).appendingPathComponent(nameImage)
        fileManager.createFile(atPath: imagePath as String, contents: photo.pngData(), attributes: nil)
    }

    /// Saves a Favorite entity to Core Data with pathImageFavorite and name (uses AppDelegate context).
    static func saveFavoriteToCoreData(pathImage: String, name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        saveFavoriteToCoreData(pathImage: pathImage, name: name, context: appDelegate.persistentContainer.viewContext)
    }

    /// Saves a Favorite entity to Core Data with the given context (SwiftUI / injected context).
    static func saveFavoriteToCoreData(pathImage: String, name: String, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Favorite", in: context) else { return }
        let favorite = NSManagedObject(entity: entity, insertInto: context)
        favorite.setValue(pathImage, forKeyPath: "pathImageFavorite")
        favorite.setValue(name, forKeyPath: "name")
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save favorite. \(error), \(error.userInfo)")
        }
    }

    /// Creates directory, saves image to disk, and saves Favorite to Core Data. Returns true on success (uses AppDelegate context).
    @discardableResult
    static func saveFavorite(image: UIImage, name: String) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        return saveFavorite(image: image, name: name, context: appDelegate.persistentContainer.viewContext)
    }

    /// Creates directory, saves image to disk, and saves Favorite to Core Data with the given context. Returns true on success.
    @discardableResult
    static func saveFavorite(image: UIImage, name: String, context: NSManagedObjectContext) -> Bool {
        guard !name.isEmpty else { return false }
        createDirectoryIfNeeded()
        let id = UUID().uuidString
        saveImageToDisk(nameImage: id, photo: image)
        saveFavoriteToCoreData(pathImage: id, name: name, context: context)
        return true
    }
}
