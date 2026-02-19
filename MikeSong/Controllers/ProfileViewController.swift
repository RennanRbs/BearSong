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

class ProfileViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
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

    private var loadingIndicator: UIActivityIndicatorView?
    private var errorView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(title: "Profile")
        if #available(iOS 13.0, *) {
            let item = UITabBarItem(
                title: nil,
                image: UIImage(systemName: "person"),
                selectedImage: UIImage(systemName: "person.fill")
            )
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            (navigationController ?? self).tabBarItem = item
        }
        view_profile.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundProfile.png")!)
        parseMusicCloudProfile()

        let myColor = UIColor.white
        image_Profile.layer.cornerRadius = LayoutConstants.cornerRadiusLarge
        image_Profile.layer.borderWidth = LayoutConstants.borderWidth
        image_Profile.layer.borderColor = myColor.cgColor
        image_Profile.clipsToBounds = true
        for cardView in [view_name, view_bio, view_city, view_favorite, view_following] {
            cardView?.layer.cornerRadius = LayoutConstants.cornerRadiusMedium
            cardView?.layer.borderWidth = LayoutConstants.borderWidth
            cardView?.layer.borderColor = myColor.cgColor
            cardView?.clipsToBounds = true
        }

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        loadingIndicator = indicator

        let errView = makeProfileErrorView()
        view.addSubview(errView)
        NSLayoutConstraint.activate([
            errView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: LayoutConstants.paddingStandard),
            errView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -LayoutConstants.paddingStandard)
        ])
        errView.isHidden = true
        errorView = errView
    }

    private func makeProfileErrorView() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            icon.image = UIImage(systemName: "exclamationmark.triangle")
        }
        icon.tintColor = .systemGray
        icon.contentMode = .scaleAspectFit
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Erro ao carregar perfil."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        container.addSubview(icon)
        container.addSubview(label)
        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: container.topAnchor),
            icon.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 48),
            icon.heightAnchor.constraint(equalToConstant: 48),
            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: LayoutConstants.paddingStandard),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
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
        loadingIndicator?.isHidden = false
        loadingIndicator?.startAnimating()
        guard let url = URL(string: "https://api.mixcloud.com/rennan-rebou%C3%A7as/") else {
            finishProfileRequest(hadError: true)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("[ProfileViewController]", error.localizedDescription)
                DispatchQueue.main.async { self?.finishProfileRequest(hadError: true) }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                if let http = response as? HTTPURLResponse {
                    print("[ProfileViewController] HTTP status:", http.statusCode)
                }
                DispatchQueue.main.async { self?.finishProfileRequest(hadError: true) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { self?.finishProfileRequest(hadError: true) }
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
                    self.finishProfileRequest(hadError: false)
                }
            } catch let parsingError {
                print("[ProfileViewController] Error", parsingError)
                DispatchQueue.main.async { self?.finishProfileRequest(hadError: true) }
            }
        }
        task.resume()
    }

    private func finishProfileRequest(hadError: Bool = false) {
        loadingIndicator?.stopAnimating()
        loadingIndicator?.isHidden = true
        errorView?.isHidden = !hadError
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
