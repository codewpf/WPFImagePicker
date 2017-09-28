//
//  WPFIPGridVC.swift
//  WPFImagePicker
//
//  Created by alex on 2017/9/22.
//  Copyright © 2017年 alex. All rights reserved.
//

import UIKit
import Photos

fileprivate let gridGap: CGFloat = 4
fileprivate let gridLines: CGFloat = 4

class WPFIPGridVC: WPFIPBaseVC {
    
    let cellIdentifier = "wpf_ip_grid_vc_cell"
    let collectionView: UICollectionView = {
        
        let width = (UIScreen.screenW - gridGap * (gridLines + 1)) / gridLines
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = gridGap
        layout.minimumInteritemSpacing = gridGap
        layout.itemSize = CGSize(width: width, height: width)
        layout.sectionInset = UIEdgeInsets(top: gridGap, left: gridGap, bottom: gridGap, right: gridGap)
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        return cv
    }()
    
    /// This vc presents grid's datasources
    fileprivate var privateAssets: PHFetchResult<PHAsset>
    var assets: PHFetchResult<PHAsset> {
        get {
            return self.privateAssets
        }
    }
    
    init(_ assets: PHFetchResult<PHAsset> ) {
        self.privateAssets = assets
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.assets.count > 1 {
            self.collectionView.scrollToItem(at: IndexPath(item: self.assets.count-1, section: 0), at: .bottom, animated: false)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.frame = self.contentRect()
        self.collectionView.register(WPFIPGridCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(self.collectionView)
    }


}


extension WPFIPGridVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: WPFIPGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as? WPFIPGridCell else {
            fatalError("unexpected cell in collection view")
        }
//        cell.backgroundColor = UIColor(r: CGFloat(arc4random() % 255), g: CGFloat(arc4random() % 255), b: CGFloat(arc4random() % 255))
        cell.setValue(self.assets.object(at: indexPath.row))
        return cell
    }
}



class WPFIPGridCell: UICollectionViewCell {
    let imageView: UIImageView
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        super.init(frame: frame)
        imageView.frame = self.contentView.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.contentView.addSubview(imageView)
    }
    
    func setValue(_ asset: PHAsset) {
        let width = (UIScreen.screenW - gridGap * (gridLines + 1)) / gridLines
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: width, height: width), contentMode: .default, options: nil) { (image, _) in
            self.imageView.image = image
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}







