//
//  WPFIPPreviewVC.swift
//  WPFImagePicker
//
//  Created by alex on 2017/10/11.
//  Copyright © 2017年 alex. All rights reserved.
//

import UIKit
import Photos

private let kPreItemSpacing:CGFloat = 15

class WPFIPPreviewVC: WPFIPBaseVC {
    
    /// 预览全部
    let selectIndex: Int
    /// 预览选中的照片
    let selectImages: [String]
    
    var backBlock: WPFIPVoidBlock? = nil
    
    let navigationView: UIView = {
        let nav = UIView()
        nav.backgroundColor = UIColor(white: 0.145, alpha: 0.8)
        return nav
    }()
    
    let cellIdentifier = "wpf_ip_pre_vc_cell"
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = kPreItemSpacing
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.screenW, height: UIScreen.screenH)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        return cv
    }()
    
    // tool bar
    let toolBar: UIToolbar = {
        let tb = UIToolbar()
        tb.tintColor = UIColor.white
        tb.backgroundColor = UIColor(white: 0.145, alpha: 0.8)
        //        tb.isTranslucent = false
        tb.barStyle = .black
        
        return tb
    }()
    
    
    init(all index: Int) {
        selectIndex = index
        selectImages = []
        super.init(nibName: nil, bundle: nil)
    }
    
    init(select images: [String]) {
        selectImages = images
        selectIndex = -1
        super.init(nibName: nil, bundle: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.register(WPFIPPreviewCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        self.collectionView.isPagingEnabled = true
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.screenW+kPreItemSpacing, height: UIScreen.screenH)
        self.view.addSubview(self.collectionView)
        
        
        
        // navigation
        self.initNavigation()
        
        // toolbar
        self.initToolBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.selectIndex != -1,
            WPFIPManager.manager.listModel.count >= self.selectIndex {
            self.collectionView.setContentOffset(CGPoint(x: (UIScreen.screenW + kPreItemSpacing) * CGFloat(self.selectIndex), y: 0) , animated: false)
        }
        
    }
    
    func initNavigation() {
        
        var height = UIApplication.shared.statusBarFrame.height
        if let tempHeight = self.navigationController?.navigationBar.height {
            height = height + tempHeight
        }
        self.navigationView.frame = CGRect(x: 0, y: 0, width: UIScreen.screenW, height: height)
        self.view.addSubview(self.navigationView)
        let ges = UITapGestureRecognizer(target: self, action: #selector(self.backAction))
        self.navigationView.addGestureRecognizer(ges)
        
        let back = UIButton(frame: CGRect(x: 8, y: height-42, width: 42, height: 42))
        back.setBackgroundImage(UIImage(named: "nav_back", in: Bundle.wpf(), compatibleWith: nil), for: .normal)
        back.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        self.navigationView.addSubview(back)
        
        let select = UIButton(frame: CGRect(x: UIScreen.screenW-42-8, y: height-42, width: 42, height: 42))
        select.setImage(UIImage(named: "nav_select", in: Bundle.wpf(), compatibleWith: nil), for: .normal)
        select.addTarget(self, action: #selector(self.selectAction), for: .touchUpInside)
        self.navigationView.addSubview(select)
        
    }
    
    //    fileprivate let previewBtn = UIButton(type: .custom)
    fileprivate let fullImageBtn = UIButton(type: .custom)
    fileprivate let sendBtn = UIButton(type: .custom)
    func initToolBar() {
        let rect = CGRect(x: 0, y: 0, width: 60, height: 30)
        //        self.previewBtn.frame = rect
        //        self.previewBtn.setTitle(Bundle.localizeString(forkey: WPFIPConstants.keys.imagePickerGridVCPreviewBbiTitle), for: .normal)
        //        self.previewBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        //        self.previewBtn.contentHorizontalAlignment = .left
        //        self.previewBtn.addTarget(self, action: #selector(self.previewBtnClick), for: .touchUpInside)
        //        self.previewBtn.isEnabled = false
        //        let previewBbi = UIBarButtonItem(customView: self.previewBtn)
        
        self.fullImageBtn.frame = rect
        self.fullImageBtn.setTitle(Bundle.localizeString(forkey: WPFIPConstants.keys.imagePickerGridVCFullImageBbiTitle), for: .normal)
        self.fullImageBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        self.fullImageBtn.setImage(UIImage(named: "btn_fullimage_normal", in: Bundle.wpf(), compatibleWith: nil), for: .normal)
        self.fullImageBtn.setImage(UIImage(named: "btn_fullimage_selected", in: Bundle.wpf(), compatibleWith: nil), for: .selected)
        self.fullImageBtn.addTarget(self, action: #selector(self.fullImageBtnClick(_:)), for: .touchUpInside)
        let fullImageBbi = UIBarButtonItem(customView: self.fullImageBtn)
        
        self.sendBtn.frame = rect
        self.sendBtn.setTitle(Bundle.localizeString(forkey: WPFIPConstants.keys.imagePickerGridVCSendBbiTitle), for: .normal)
        self.sendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.sendBtn.setBackgroundImage(UIImage(named: "btn_send", in: Bundle.wpf(), compatibleWith: nil), for: .normal)
        self.sendBtn.isEnabled = false
        let sendBbi = UIBarButtonItem(customView: self.sendBtn)
        
        let spaceBbi = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let items = [spaceBbi, fullImageBbi, spaceBbi, sendBbi]
        
        self.toolBar.items = items
        self.toolBar.frame = CGRect(x: 0, y: 0, width: UIScreen.screenW, height: self.kToolBarHeight)
        
        let toolBarBgView: UIView = UIView(frame: CGRect(x: 0, y: UIScreen.screenH-self.contentToolBarHeight()-self.contentInsetBottom(), width: UIScreen.screenW, height: self.contentToolBarHeight()))
        toolBarBgView.addSubview(self.toolBar)
        self.view.addSubview(toolBarBgView)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MAKR: - Private Methods
extension WPFIPPreviewVC {
    
    func backAction() {
        if let block = self.backBlock {
            block()
        }
    }
    
    func selectAction() {
        
    }
    
    func fullImageBtnClick(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
    }
    
    func sendBtnClick() {
        
    }
    
    
}

//MARK: - Delegate
extension WPFIPPreviewVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.selectIndex != -1 {
            return WPFIPManager.manager.listModel.count
        } else {
            return self.selectImages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell: WPFIPPreviewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as? WPFIPPreviewCell else {
            fatalError("unexpected cell in collection view")
        }
        
        if self.selectIndex != -1 {
//            cell.setValue(WPFIPManager.manager.assets!.object(at: indexPath.row), indexPath.row)
        } else {
            
        }
        
        return cell
    }
    
}



//MARK: - Preview Collection Cell
class WPFIPPreviewCell: UICollectionViewCell {
    
    // row of the cell
    var row: Int = -1
    
    
    let detailView: WPFIPPreviewDetailView
    
    override init(frame: CGRect) {
        detailView = WPFIPPreviewDetailView(frame: CGRect(origin: .zero, size: frame.size))
        super.init(frame: frame)
        detailView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.addSubview(detailView)
        
    }
    
    
    
    func setValue(_ asset: PHAsset, _ row: Int) {
        
        let option = PHImageRequestOptions()
        option.resizeMode = .fast
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: option) { (image, _) in
            
        }
        
        self.detailView.asset = asset
        self.row = row
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

/// the detail of cell
class WPFIPPreviewDetailView: UIView {
    /// Default is false. if set to true, the view could dispaly gif
    var isShowGif: Bool = false
    /// Default is false. if set to true, the view could dispaly live photo
    var isShowLivePhoto: Bool = false
    
    
    /// source
    var asset: PHAsset = PHAsset()
    
}

/// the base of the detail
class WPFIPPreviewBaseView: UIView {
    
}

///
class WPFIPPreviewImageAndGifView: WPFIPPreviewBaseView {
    
}

class WPFIPPreviewLivePhotoView: WPFIPPreviewBaseView {
    
}

class WPFIPPreviewVideoView: WPFIPPreviewBaseView {
    
}















