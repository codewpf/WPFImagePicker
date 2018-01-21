//
//  WPFIPForceTouchVC.swift
//  WPFImagePicker
//
//  Created by alex on 2018/1/16.
//  Copyright © 2018年 alex. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class WPFIPForceTouchVC: WPFIPBaseVC {

    /// 当前 item 索引
    let index: Int
    /// 当前 item 资源
    let model: WPFIPModel
    
    init(_ index: Int) {
        self.index = index
        self.model = WPFIPManager.manager.listModel.models[index]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(white: 0.8, alpha: 0.5)
        
        
        switch self.model.type {
        case .image: self.initImage()
        case .gif:
            if WPFImagePicker.imagePicker.conf.canFTGif == true {
                self.initGIF()
            } else {
                self.initImage()
            }
        case .livePhoto: self.initLivePhoto()
        case .video: self.initVideo()
        default: break
        }
        
        

    }
    
    
    func initImage() {
        let size = self.size()
        let imageView = UIImageView(frame: CGRect(x: -1, y: -1, width: size.width+2, height: size.height+2))
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        
        WPFIPManager.manager.requestImage(for: self.model.asset, size: CGSize(width: size.width*2, height: size.height*2)) { (result, image, _) in
            if result == true {
                imageView.image = image
            }
        }
        
    }
    
    func initGIF() {
        let size = self.size()
        let imageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: size))
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        
        WPFIPManager.manager.requestImageData(for: self.model.asset) { (result, data, _) in
            if result == true, let image = data.toGIF() {
                imageView.image = image
            }
        }
        
        
    }
    
    func initLivePhoto() {
        
        let size = self.size()
        let livePhotoView: PHLivePhotoView = PHLivePhotoView(frame: CGRect(origin: CGPoint.zero, size: size))
        livePhotoView.contentMode = .scaleAspectFit
        self.view.addSubview(livePhotoView)
        
        WPFIPManager.manager.requestLivePhoto(for: self.model.asset) { (result, livePhoto, _) in
            if result == true {
                livePhotoView.livePhoto = livePhoto
                livePhotoView.startPlayback(with: .full)
            }
        }
        
        
    }
    
    func initVideo() {
        let size = self.size()
        let playLayer = AVPlayerLayer()
        playLayer.frame = CGRect(origin: CGPoint.zero, size: size)
        self.view.layer.addSublayer(playLayer)
        
        WPFIPManager.manager.requestVideo(for: self.model.asset) { (result, item, _) in
            if result == true {
                DispatchQueue.main.async {
                    let player = AVPlayer(playerItem: item)
                    playLayer.player = player
                    player.play()
                }
            }
        }
        
        
    }
    
    
    
    
    
    
    func size() -> CGSize {
        
        var w: CGFloat = min(CGFloat(self.model.asset.pixelWidth), UIScreen.screenW)
        var h: CGFloat = w * CGFloat(self.model.asset.pixelHeight) / CGFloat(self.model.asset.pixelWidth)
        
        if h.isNaN == true {
            return CGSize.zero
        }
        
        if h > UIScreen.screenH {
            h = UIScreen.screenH
            w = h * CGFloat(self.model.asset.pixelWidth) / CGFloat(self.model.asset.pixelHeight)
        }
        
        return CGSize(width: w, height: h)
        
    }

    
    
    
    

}
