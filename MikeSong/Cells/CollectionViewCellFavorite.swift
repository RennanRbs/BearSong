//
//  CollectionViewCellFavorite.swift
//  BearSong
//
//  Created by Rennan Rebouças on 24/10/18.
//  Copyright © 2018 Rennan Rebouças. All rights reserved.
//

import UIKit

class CollectionViewCellFavorite: UICollectionViewCell {

    @IBOutlet weak var uiimage_favorite: UIImageView!
    
    
    override func awakeFromNib() {
        
        uiimage_favorite?.layer.cornerRadius = 20
        uiimage_favorite?.clipsToBounds = true
        
        super.awakeFromNib()
    }

}
