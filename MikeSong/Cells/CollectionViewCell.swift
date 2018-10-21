//
//  CollectionViewCell.swift
//  BearSong
//
//  Created by Rennan Rebouças on 19/10/18.
//  Copyright © 2018 Rennan Rebouças. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var uiImage_image: UIImageView!
    @IBOutlet weak var label_hotBear: UILabel!
    
    override func awakeFromNib() {
        uiImage_image.layer.cornerRadius = 20
        uiImage_image.clipsToBounds = true
        
        
        super.awakeFromNib()
        
    }

}
