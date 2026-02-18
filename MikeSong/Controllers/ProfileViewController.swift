//
//  ProfileViewController.swift
//  BearSong
//
//  Created by Rennan Rebouças on 16/10/18.
//  Copyright © 2018 Rennan Rebouças. All rights reserved.
//

import UIKit

// MARK: - Mixcloud Profile Models
private struct MixcloudProfile: Decodable {
    let name: String?
    let biog: String?
    let city: String?
    let favorite_count: Int?
    let following_count: Int?
    let pictures: Pictures?
}

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
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
        view_profile.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundProfile.png")!)
        parseMusicCloudProfile()

        image_Profile.layer.cornerRadius = 40
        image_Profile.layer.borderWidth = 5
        let myColor = UIColor.white
        image_Profile.layer.borderColor = myColor.cgColor
        image_Profile.clipsToBounds = true
        view_name.layer.cornerRadius = 20
        view_name.layer.borderWidth = 5
        view_name.layer.borderColor = myColor.cgColor
        view_name.clipsToBounds = true
        view_bio.layer.cornerRadius = 20
        view_bio.layer.borderWidth = 5
        view_bio.layer.borderColor = myColor.cgColor
        view_city.layer.cornerRadius = 20
        view_city.layer.borderWidth = 5
        view_city.layer.borderColor = myColor.cgColor
        view_favorite.layer.cornerRadius = 20
        view_favorite.layer.borderWidth = 5
        view_favorite.layer.borderColor = myColor.cgColor
        view_following.layer.cornerRadius = 20
        view_following.layer.borderWidth = 5
        view_following.layer.borderColor = myColor.cgColor
    }

    let reuseIdentifier = "Cell"

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parseMusicCloudProfile()
    }

    func parseMusicCloudProfile() {
        guard let url = URL(string: "https://api.mixcloud.com/rennan-rebou%C3%A7as/") else { return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            do {
                let decoder = JSONDecoder()
                let profile = try decoder.decode(MixcloudProfile.self, from: data)
                let favoriteCount = profile.favorite_count ?? 0
                let followingCount = profile.following_count ?? 0
                let imageURLString = profile.pictures?._640wx640h ?? ""

                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.label_Name.text = profile.name
                    self.label_bio.text = profile.biog
                    self.label_City.text = profile.city
                    self.label_favorite.text = " Favorites Sounds: \(favoriteCount)"
                    self.label_following.text = "Following: \(followingCount)"
                    if !imageURLString.isEmpty {
                        self.image_Profile.image(fromUrl: imageURLString)
                    }
                }
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
}

// MARK: - UIImageView URL Loading
extension UIImageView {
    func image(fromUrl urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Couldn't create URL from \(urlString)")
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                }
            }
        }.resume()
    }
}
