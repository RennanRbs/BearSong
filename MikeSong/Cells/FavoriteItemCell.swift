//
//  FavoriteItemCell.swift
//  BearSong
//
//  Created by Rennan Rebouças on 24/10/18.
//  Copyright © 2018 Rennan Rebouças. All rights reserved.
//

import UIKit

class FavoriteItemCell: UICollectionViewCell {

    @IBOutlet weak var uiimage_favorite: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        uiimage_favorite?.layer.cornerRadius = LayoutConstants.cornerRadiusMedium
        uiimage_favorite?.clipsToBounds = true
    }
}
