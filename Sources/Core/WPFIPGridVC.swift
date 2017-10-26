//
//  WPFIPGridVC.swift
//  WPFImagePicker
//
//  Created by alex on 2017/9/22.
//  Copyright © 2017年 alex. All rights reserved.
//

import UIKit
import Photos

fileprivate let kGridGap: CGFloat = 4
fileprivate let kGridLines: CGFloat = 4
let kToolBarHeight: CGFloat = 45

class WPFIPGridVC: WPFIPBaseVC {
    
    /// 已经被选中的Cell
    var selectedCell: [Int] = []
    
    // Collection View
    let cellIdentifier = "wpf_ip_grid_vc_cell"
    let collectionView: UICollectionView = {
        let width = (UIScreen.screenW - kGridGap * (kGridLines + 1)) / kGridLines
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = kGridGap
        layout.minimumInteritemSpacing = kGridGap
        layout.itemSize = CGSize(width: width, height: width)
        layout.sectionInset = UIEdgeInsets(top: kGridGap, left: kGridGap, bottom: kGridGap, right: kGridGap)
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        return cv
    }()
    
    // tool bar
    let toolBar: UIToolbar = {
        let tb = UIToolbar()
        
        tb.tintColor = UIColor.white
        tb.barTintColor = UIColor(r: 38, g: 45, b: 51)
        tb.isTranslucent = false
        tb.barStyle = .black
        
        return tb
    }()
    
    // This vc presents grid's datasources
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

    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        // cancel bar btn
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtonClick))
        self.navigationItem.setRightBarButton(cancel, animated: false)
        
        // collectionview
        self.collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.screenW, height: UIScreen.screenH-kToolBarHeight)
        self.collectionView.contentInset = UIEdgeInsets(top: self.contentInsetTop(false), left: 0, bottom:  0, right: 0)
        self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(WPFIPGridCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        }
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(self.collectionView)
        
        // toolbar
        self.initToolBar()
        
        
    }
    
    
    var initScroll: Int = 0
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.initScroll == 0 {
            if self.assets.count > 1 {
                self.collectionView.scrollToItem(at: IndexPath(item: self.assets.count-1, section: 0), at: .bottom, animated: false)
            }
        }
        self.initScroll = 1
        
    }

    
    fileprivate let previewBtn = UIButton(type: .custom)
    fileprivate let fullImageBtn = UIButton(type: .custom)
    fileprivate let sendBtn = UIButton(type: .custom)
    func initToolBar() {
        let rect = CGRect(x: 0, y: 0, width: 60, height: 30)
        self.previewBtn.frame = rect
        self.previewBtn.setTitle(Bundle.localizeString(forkey: WPFIPConstants.keys.imagePickerGridVCPreviewBbiTitle), for: .normal)
        self.previewBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.previewBtn.contentHorizontalAlignment = .left
        self.previewBtn.addTarget(self, action: #selector(self.previewBtnClick), for: .touchUpInside)
        self.previewBtn.isEnabled = false
        let previewBbi = UIBarButtonItem(customView: self.previewBtn)
        
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
        let items = [previewBbi, spaceBbi, fullImageBbi, spaceBbi, sendBbi]
        
        self.toolBar.items = items
        self.toolBar.frame = CGRect(x: 0, y: UIScreen.screenH-kToolBarHeight-self.contentInsetBottom(), width: UIScreen.screenW, height: kToolBarHeight)
        self.view.addSubview(self.toolBar)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isStatusBarHidden: Bool = false
    override var prefersStatusBarHidden: Bool {
        return self.isStatusBarHidden
    }
    
}

//MARK: - PrivateMedhod
extension WPFIPGridVC {
    
    func updateSelectedItem() {
        for (idx, value) in self.selectedCell.enumerated() {
            let indexPath = IndexPath(item: value, section: 0)
            if let cell = self.collectionView.cellForItem(at: indexPath) as? WPFIPGridCell {
                cell.updateBtn(selectIndex: idx+1, newState: true, false)
            }
        }
    }
    
    func cancelButtonClick() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func previewBtnClick() {
        let prevc = WPFIPPreviewVC()
        self.addChildViewController(prevc)
        prevc.view.frame = CGRect(x: self.view.bounds.width, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(prevc.view)
        prevc.didMove(toParentViewController: self)
        
        self.updateNavigation(isHidden: true, subvc: prevc)
        prevc.backBlock = { [weak self] in
            self?.updateNavigation(isHidden: false, subvc: prevc)
        }
    }
    
    func updateNavigation(isHidden state: Bool, subvc vc: WPFIPBaseVC) {
        self.isStatusBarHidden = state
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.setNavigationBarHidden(state, animated: false)
        
        var leading: CGFloat = 0
        if state == false {
            leading = self.view.bounds.width
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            vc.view.leading = leading

        }) { (_) in
            if state == false {
                vc.willMove(toParentViewController: nil)
                vc.view.removeFromSuperview()
                vc.removeFromParentViewController()
            }

        }
    }
    
    
    
    func fullImageBtnClick(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
    }
    
    func sendBtnClick() {
        
    }

    
}


//MARK: - CollectionView Delegate & DataSource
extension WPFIPGridVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assets.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: WPFIPGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as? WPFIPGridCell else {
            fatalError("unexpected cell in collection view")
        }
        
        cell.renewCell()
        
        cell.setValue(self.assets.object(at: indexPath.row), indexPath.row, self.canClick(indexPath.row))
        
        cell.selectBlock = { [weak self] (cell, isSelected) in
            self?.cellSelectBtnClick(cell, isSelected)
        }
        cell.tapBlock = { [weak self] in
            self?.previewBtnClick()
        }
        
        if let idx = self.selectedCell.index(of: indexPath.row) {
            cell.updateBtn(selectIndex: idx+1, newState: true, false)
        }
        
        return cell
    }
    
    // 被 WPFIPGridCellSelectBlock 调用
    // isSelected: 当前状态
    func cellSelectBtnClick(_ cell: WPFIPGridCell, _ isSelected: Bool) {
        // 如果之前是被选中的状态 则修改为取消选中
        if isSelected == true {
            cell.updateBtn(selectIndex: 0, newState: !isSelected)
            
            self.selectedCell.remove(object: cell.row)
        } else {
            // 判断当前的数量是否已经满额
            guard self.selectedCell.count < WPFImagePicker.imagePicker.ipMaxSeleted else {
                self.showMaximumAlert()
                return
            }
            cell.updateBtn(selectIndex: self.selectedCell.count, newState: !isSelected, true)
            
            
            // 添加进数组
            self.selectedCell.append(cell.row)
        }
        
        if self.selectedCell.count > 0 {
            self.previewBtn.isEnabled = true
            
            self.sendBtn.isEnabled = true
            self.sendBtn.setTitle("\(Bundle.localizeString(forkey: WPFIPConstants.keys.imagePickerGridVCSendBbiTitle))(\(self.selectedCell.count))", for: .normal)
        } else {
            self.previewBtn.isEnabled = false
            
            self.sendBtn.isEnabled = false
            self.sendBtn.setTitle(Bundle.localizeString(forkey: WPFIPConstants.keys.imagePickerGridVCSendBbiTitle), for: .normal)
        }
        
        
        self.updateSelectedItem()
        
        
        
        // 两个临界点 刷新Collection item coverView 的状态
        if self.selectedCell.count == WPFImagePicker.imagePicker.ipMaxSeleted ||
            self.selectedCell.count == WPFImagePicker.imagePicker.ipMaxSeleted - 1 {
            for cell in self.collectionView.visibleCells {
                if let grid = cell as? WPFIPGridCell {
                    grid.updateCoverState(self.canClick(grid.row))
                }
            }
        }
        
        
    }
    
    func canClick(_ row: Int) -> Bool {
        var state = false
        state = self.selectedCell.count < 9
        if self.selectedCell.contains(row) {
            state = true
        }
        return state
    }
    
}


//MARK: - WPFIPGridCell
/// 选择按钮 被点击
///
/// - Parameters:
///   - griCell: current item.
///   - isSelected: now state.
typealias WPFIPGridCellSelectBlock = (_ griCell: WPFIPGridCell, _ isSelected: Bool) -> Void

class WPFIPGridCell: UICollectionViewCell {
    
    // row of the cell
    var row: Int = -1
    
    // block
    var selectBlock: WPFIPGridCellSelectBlock? = nil
    
    var tapBlock: WPFIPVoidBlock? = nil
    
    let imageView: UIImageView
    
    let coverView: UIView
    
    let selectBtn: UIButton
    
    override init(frame: CGRect) {
        imageView = UIImageView()
        coverView = UIView()
        selectBtn = UIButton(type: .custom)
        super.init(frame: frame)
        imageView.frame = self.contentView.bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        self.contentView.addSubview(imageView)
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(self.tapClick))
        self.imageView.addGestureRecognizer(tapGes)
        
        coverView.frame = imageView.frame
        coverView.backgroundColor = UIColor(white: 1, alpha: 0.7)
        self.contentView.addSubview(coverView)
        
        selectBtn.frame = CGRect(x: imageView.width-27, y: 0, width: 27, height: 27)
        selectBtn.setBackgroundImage(UIImage(named: "btn_image_normal", in: Bundle.wpf(), compatibleWith: nil), for: .normal)
        selectBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        selectBtn.setTitle("", for: .normal)
        selectBtn.setBackgroundImage(UIImage(named: "btn_image_selected", in: Bundle.wpf(), compatibleWith: nil), for: .selected)
        selectBtn.addTarget(self, action: #selector(self.selectBtnClick(_:)), for: .touchUpInside)
        self.contentView.addSubview(selectBtn)
        
        
    }
    
    func renewCell() {
        //        imageView.image = nil
        selectBtn.isSelected = false
        coverView.isHidden = true
    }
    
    
    //
    func setValue(_ asset: PHAsset, _ row: Int, _ canClick: Bool) {
        //        WPFLog("row = \(row) start")
        let width = ((UIScreen.screenW - kGridGap * (kGridLines + 1)) / kGridLines ) * 3
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: width, height: width), contentMode: .default, options: nil) { (image, _) in
            //            WPFLog("row = \(row) end ")
            self.imageView.image = image
        }
        
        self.row = row
        
        self.coverView.isHidden = canClick
    }
    
    // 修改白色覆盖状态
    func updateCoverState(_ canClick: Bool) {
        self.coverView.isHidden = canClick
    }
    
    // 修改选择按钮状态
    func updateBtn(selectIndex index: Int, newState isSelected: Bool, _ animate: Bool = true) {
        self.selectBtn.setTitle("\(index)", for: .selected)
        
        if isSelected == true && animate == true {
            let keyframe = CAKeyframeAnimation(keyPath: "transform.scale")
            keyframe.duration = 0.4
            keyframe.keyTimes = [0, 0.33, 0.66, 1]
            keyframe.values = [0.75, 1.08, 0.92, 1]
            self.selectBtn.layer.add(keyframe, forKey: "select_btn_transform")
        }
        
        self.selectBtn.isSelected = isSelected
    }
    
    
    
    // 选择 点击
    func selectBtnClick(_ btn: UIButton) {
        guard let block = self.selectBlock else {
            fatalError("the cell does not have the block of select action")
        }
        block(self, btn.isSelected)
    }
    
    
    // 预览 点击
    func tapClick() {
        guard let block = self.tapBlock else {
            fatalError("the cell does not have the block of tap")
        }
        block()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}







