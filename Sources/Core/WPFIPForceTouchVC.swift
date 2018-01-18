//
//  WPFIPForceTouchVC.swift
//  WPFImagePicker
//
//  Created by alex on 2018/1/16.
//  Copyright © 2018年 alex. All rights reserved.
//

import UIKit
import Photos

class WPFIPForceTouchVC: WPFIPBaseVC {

    let asset: PHAsset
    init(_ asset: PHAsset) {
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        
        
        /*
        PHImageManager.default().requestImage(for: assets.lastObject!, targetSize: CGSize(width: self.height*2, height: self.height*2), contentMode: .default, options: nil) { (image, _) in
            self.ipImageView.image = image
        }
*/
        
        
        

    }
    
    func size() -> CGSize {
        
        var w: CGFloat = min(CGFloat(self.asset.pixelWidth), UIScreen.screenW)
        var h: CGFloat = w * CGFloat(self.asset.pixelHeight) / CGFloat(self.asset.pixelWidth)
        
        if h.isNaN == true {
            return CGSize.zero
        }
        
        if h > UIScreen.screenH {
            h = UIScreen.screenH
            w = h * CGFloat(self.asset.pixelWidth) / CGFloat(self.asset.pixelHeight)
        }
        
        return CGSize(width: w, height: h)
        
    }

    
    
    
    

}
