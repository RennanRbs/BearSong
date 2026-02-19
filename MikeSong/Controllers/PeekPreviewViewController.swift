//
//  PeekPreviewViewController.swift
//  BearSong
//
//  Created by Rennan Rebouças on 22/10/18.
//  Copyright © 2018 Rennan Rebouças. All rights reserved.
//

import UIKit
import CoreData

class PeekPreviewViewController: UIViewController {

    @IBOutlet weak var uiimage_peekImage: UIImageView!
    @IBOutlet weak var label_peekText: UILabel!

    var favorites: [NSManagedObject] = []
    var peekimage: UIImage?
    var peekText: String?
    var urlMusic: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let peekimage = peekimage {
            uiimage_peekImage.image = peekimage
        }
        if let peekText = peekText {
            label_peekText.text = peekText
        }
        FavoriteStorageHelper.createDirectoryIfNeeded()
    }

    override var previewActionItems: [UIPreviewActionItem] {
        let action = UIPreviewAction(title: "Favorite this HotSong", style: .default) { [weak self] _, _ in
            guard let self = self, let name = self.peekText, let image = self.peekimage else { return }
            _ = FavoriteStorageHelper.saveFavorite(image: image, name: name)
        }
        let action2 = UIPreviewAction(title: "Listen this Song", style: .default) { [weak self] _, _ in
            guard let self = self, let urlString = self.urlMusic, let url = URL(string: urlString) else { return }
            UIApplication.shared.open(url)
        }
        return [action, action2]
    }
}
