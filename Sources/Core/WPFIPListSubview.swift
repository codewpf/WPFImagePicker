//
//  WPFIPListSubview.swift
//  WPFImagePicker
//
//  Created by Alex on 2018/3/11.
//  Copyright © 2018年 alex. All rights reserved.
//

import UIKit
import Photos

class WPFIPListCell: UITableViewCell {
    let ipImageView: UIImageView
    let titleLabel: UILabel
    let countLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        ipImageView = UIImageView()
        titleLabel = UILabel()
        countLabel = UILabel()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.ipImageView.clipsToBounds = true
        self.countLabel.textColor = UIColor.lightGray
        
        self.addSubview(ipImageView)
        self.addSubview(titleLabel)
        self.addSubview(countLabel)
        
    }
    
    func setValue(_ listModel: WPFIPListModel) {
        
        if let model = listModel.thumbAsset {
            PHImageManager.default().requestImage(for: model.asset, targetSize: CGSize(width: self.height*2, height: self.height*2), contentMode: .default, options: nil) { (image, _) in
                self.ipImageView.image = image
            }
        } else {
            self.ipImageView.image = UIImage(named: "image_default", in: Bundle.wpf(), compatibleWith: nil)
        }
        self.ipImageView.contentMode = .scaleAspectFill
        self.titleLabel.text = listModel.title
        self.titleLabel.sizeToFit()
        
        self.countLabel.text = "（\(listModel.models.count)）"
        self.countLabel.sizeToFit()
    }
    
    func setCellHeight(_ height: CGFloat) {
        assert(self.countLabel.text != nil, "Please set value firstly")
        
        self.ipImageView.frame = CGRect(x: 0, y: 0, width: height, height: height)
        self.titleLabel.frame = CGRect(origin: CGPoint(x: self.ipImageView.trailing + 3, y: (height-self.titleLabel.height)/2), size: self.titleLabel.size)
        self.countLabel.frame = CGRect(origin: CGPoint(x: self.titleLabel.trailing + 3, y: (height-self.countLabel.height)/2), size: self.countLabel.size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

