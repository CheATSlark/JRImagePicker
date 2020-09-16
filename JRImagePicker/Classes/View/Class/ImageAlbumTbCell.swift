//
//  ImageAlbumTbCell.swift
//  23
//
//  Created by 焦瑞洁 on 2020/8/26.
//  Copyright © 2020 ddcx. All rights reserved.
//

import UIKit

class ImageAlbumTbCell: UITableViewCell {
    
    @IBOutlet weak var lbAlbumCount: UILabel!
    @IBOutlet weak var lbAlbumName: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    func setup(model:MTImagePickerAlbumModel) {
        self.lbAlbumCount.text = "(\(model.getAlbumCount()))"
        self.lbAlbumName.text = model.getAlbumName()
        self.posterImageView.image = model.getAlbumImage(size: self.posterImageView.frame.size)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
