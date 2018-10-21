//
//  ViewController.swift
//  MikeSong
//
//  Created by Rennan Rebouças on 16/10/18.
//  Copyright © 2018 Rennan Rebouças. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    let reuseIdentifier = "Cell";
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as UICollectionViewCell
        return cell
    }
    
    @IBOutlet weak var image_Cover: UIImageView!
    @IBOutlet weak var image_profile: UIImageView!
    @IBOutlet weak var label_name: UILabel!
    @IBOutlet weak var label_bio: UILabel!
    @IBOutlet weak var label_Following: UILabel!
    @IBOutlet weak var label_Favorite: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ParseMusicCloudProfile()
    }

    func ParseMusicCloudProfile()  {
        
        guard let url = URL(string: "https://api.mixcloud.com/spartacus/")
            else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do {
                let decoder = JSONDecoder()
                let profile = try decoder.decode(Json4Swift_Profile.self, from: dataResponse)
                
                
                DispatchQueue.main.async {
                    self.label_bio.text = profile.biog 
                    self.label_name.text = profile.name
                    self.label_Favorite.text = " Fav \(profile.favorite_count.unsafelyUnwrapped)"
                    self.label_Following.text = "Following \(profile.following_count.unsafelyUnwrapped) "
                    self.image_Cover.image(fromUrl: (profile.cover_pictures?._835wx120h.unsafelyUnwrapped)!)
                    self.image_profile.image(fromUrl: (profile.pictures?._640wx640h.unsafelyUnwrapped)!)
                }
                
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
    
    
}
extension UIImageView {
    public func image(fromUrl urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Couldn't create URL from \(urlString)")
            return
        }
        let theTask = URLSession.shared.dataTask(with: url) {
            data, response, error in
            if let responseData = data {
                DispatchQueue.main.async {
                    self.image = UIImage(data: responseData)
                }
            }
        }
        theTask.resume()
    }
}



