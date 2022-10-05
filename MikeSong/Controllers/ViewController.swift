//
//  ViewController.swift
//  MikeSong
//
//  Created by Rennan Rebouças on 16/10/18.
//  Copyright © 2018 Rennan Rebouças. All rights reserved.
//
//

import UIKit


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBAction func editProfile(_ sender: Any) {
        let url = URL(string: "https://www.mixcloud.com/settings/profile/")
        UIApplication.shared.open(url!)
    }
    
    
    @IBOutlet weak var view_following: UIView!
    @IBOutlet weak var view_favorite: UIView!
    @IBOutlet weak var view_city: UIView!
    @IBOutlet weak var view_bio: UIView!
    @IBOutlet weak var view_name: UIView!
    @IBOutlet weak var view_profile: UIView!
    @IBOutlet weak var image_Profile: UIImageView!
    @IBOutlet weak var label_Name: UILabel!
    @IBOutlet weak var label_bio: UILabel!
    @IBOutlet weak var label_favorite: UILabel!
    @IBOutlet weak var label_following: UILabel!
    @IBOutlet weak var label_City: UILabel!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view_profile.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundProfile.png")!)
        ParseMusicCloudProfile()
        
        self.image_Profile.layer.cornerRadius = 40
        self.image_Profile.layer.borderWidth = 5
        let myColor = UIColor.white
        self.image_Profile.layer.borderColor = myColor.cgColor
        self.image_Profile.clipsToBounds = true
        self.view_name.layer.cornerRadius = 20
        self.view_name.layer.borderWidth = 5
        self.view_name.layer.borderColor = myColor.cgColor
        self.view_name.clipsToBounds = true
        self.view_bio.layer.cornerRadius = 20
        self.view_bio.layer.borderWidth = 5
        self.view_bio.layer.borderColor = myColor.cgColor
        self.view_city.layer.cornerRadius = 20
        self.view_city.layer.borderWidth = 5
        self.view_city.layer.borderColor = myColor.cgColor
        self.view_favorite.layer.cornerRadius = 20
        self.view_favorite.layer.borderWidth = 5
        self.view_favorite.layer.borderColor = myColor.cgColor
        self.view_following.layer.cornerRadius = 20
        self.view_following.layer.borderWidth = 5
        self.view_following.layer.borderColor = myColor.cgColor
    }
    
// CollectionViewProfile
    let reuseIdentifier = "Cell";
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as UICollectionViewCell
        return cell
    }
    override func viewWillAppear(_ animated: Bool) {
        ParseMusicCloudProfile()
    }
    
    
// Consuming API
    func ParseMusicCloudProfile()  {
        
        guard let url = URL(string: "https://api.mixcloud.com/rennan-rebou%C3%A7as/")
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
                    self.label_Name.text = profile.name
                    self.label_bio.text = profile.biog
                    self.label_City.text = profile.city
                    self.label_favorite.text = " Favorites Sounds: \(profile.favorite_count.unsafelyUnwrapped)"
                    self.label_following.text = "Following: \(profile.following_count.unsafelyUnwrapped)"
                    self.image_Profile.image(fromUrl: (profile.pictures?._640wx640h)!)
                   

                }
                
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
    
    
}



//Extension UIIMageViewFromURL
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



