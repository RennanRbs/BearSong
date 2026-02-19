//
//  FeedItemCell.swift
//  BearSong
//
//  Created by Rennan Rebouças on 19/10/18.
//  Copyright © 2018 Rennan Rebouças. All rights reserved.
//

import UIKit

class FeedItemCell: UICollectionViewCell {

    @IBOutlet weak var uiImage_image: UIImageView!
    @IBOutlet weak var label_hotBear: UILabel!

    private let heartImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            iv.image = UIImage(systemName: "heart.fill")
            iv.tintColor = .systemPink
        }
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        return iv
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        uiImage_image.layer.cornerRadius = LayoutConstants.cornerRadiusMedium
        uiImage_image.clipsToBounds = true
        contentView.addSubview(heartImageView)
        NSLayoutConstraint.activate([
            heartImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: LayoutConstants.paddingStandard),
            heartImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -LayoutConstants.paddingStandard),
            heartImageView.widthAnchor.constraint(equalToConstant: 24),
            heartImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        heartImageView.isHidden = true
    }

    func setFavorited(_ favorited: Bool) {
        heartImageView.isHidden = !favorited
    }
}
