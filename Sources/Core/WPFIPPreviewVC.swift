//
//  WPFIPPreviewVC.swift
//  WPFImagePicker
//
//  Created by alex on 2017/10/11.
//  Copyright © 2017年 alex. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

/// Collection 之间的间隔
private let kPreItemSpacing: CGFloat = 15
/// 控件背景颜色
private let kBarBackgroundColor: UIColor = UIColor(white: 0.08, alpha: 0.9)

/// 返回时间 回调定义
typealias WPFIPPreviewVCBackBlock = (_ vc: WPFIPPreviewVC) -> Void
typealias WPFIPPreviewVCSelectBlock = (_ idx: Int) -> Int


class WPFIPPreviewVC: WPFIPBaseVC {
    
    /// 预览全部
    let selectIndex: Int
    /// 预览选中的照片
    let selectImages: [String]
    
    /// 返回 按钮点击事件回调
    var backBlock: WPFIPPreviewVCBackBlock? = nil
    /// 原图 按钮点击事件回调
    var fullImageBlock: WPFIPVoidBlock? = nil
    /// 选择 按钮点击事件回调
    var selectBlock: WPFIPPreviewVCSelectBlock? = nil
    /// 发送 按钮点击事件回调
    var sendBlock: WPFIPVoidBlock? = nil
    
    /// 是否已点击返回 针对返回动画过程中，cell会重新加载的问题
    var isBacked: Bool = false
    
    /// 旧的被选中高亮Cell
    var oldHightlightedCell: WPFIPPreviewSelectedCell? = nil
    var oldSelectedCurrent: Int = -1
    
    let navigationView: UIView = {
        let nav = UIView()
        nav.backgroundColor = kBarBackgroundColor
        return nav
    }()
    
    /// 集合视图 单元标识
    let cellIdentifier = "wpf_ip_pre_vc_cell"
    /// 集合视图
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = kPreItemSpacing
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.screenW, height: UIScreen.screenH)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        let _collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        return _collectionView
    }()
    
    /// tool bar
    let toolBar: UIToolbar = {
        let _toolBar = UIToolbar()
        _toolBar.tintColor = UIColor.white
        _toolBar.backgroundColor = UIColor(white: 0.08, alpha: 0.7)
        _toolBar.barStyle = .black
        return _toolBar
    }()
    
    /// 选中视图 单元标识
    let selectedCellIdentifier = "wpf_ip_pre_vc_selected_cell"
    /// selected View
    let selectedView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 13
        layout.minimumInteritemSpacing = 13
        layout.itemSize = CGSize(width: 54, height: 54)
        layout.sectionInset = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)
        layout.scrollDirection = .horizontal
        let _selectedView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        _selectedView.backgroundColor = kBarBackgroundColor
        return _selectedView;
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
        
        // selected view
        self.initSelectedView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.selectIndex != -1,
            WPFIPManager.manager.listModel.count >= self.selectIndex {
            self.collectionView.setContentOffset(CGPoint(x: (UIScreen.screenW + kPreItemSpacing) * CGFloat(self.selectIndex), y: 0) , animated: false)
            let idx: Int = lroundf(Float(self.collectionView.contentOffset.x / (UIScreen.screenW + kPreItemSpacing)))
            self.oldSelectedCurrent = idx

        }
        
    }
    
    /// 选择按钮
    fileprivate let selectBtn = WPFIPPreviewSelectButton(type: .custom)
    func initNavigation() {
        var height = UIApplication.shared.statusBarFrame.height
        if let tempHeight = self.navigationController?.navigationBar.height {
            height = height + tempHeight
        }
        self.navigationView.frame = CGRect(x: 0, y: 0, width: UIScreen.screenW, height: height)
        self.view.addSubview(self.navigationView)
        
        let back = UIButton(frame: CGRect(x: 8, y: (height-42)/2, width: 42, height: 42))
        back.setBackgroundImage(UIImage(named: "nav_back", in: Bundle.wpf(), compatibleWith: nil), for: .normal)
        back.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        self.navigationView.addSubview(back)
        
        self.selectBtn.frame = CGRect(x: UIScreen.screenW-42-8, y: (height-42)/2, width: 42, height: 42)
        self.selectBtn.setImage(UIImage(named: "nav_select_normal", in: Bundle.wpf(), compatibleWith: nil), for: .normal)
        self.selectBtn.idxLabel.text = ""
        self.selectBtn.setImage(UIImage(named: "nav_select_selected", in: Bundle.wpf(), compatibleWith: nil), for: .selected)
        self.selectBtn.addTarget(self, action: #selector(self.selectAction), for: .touchUpInside)
        self.navigationView.addSubview(selectBtn)
        
    }
    
    //    fileprivate let previewBtn = UIButton(type: .custom)
    /// 原图按钮
    fileprivate let fullImageBtn = UIButton(type: .custom)
    /// 发送按钮
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
    
    func initSelectedView() {
        
        self.selectedView.frame = CGRect(x: 0, y: UIScreen.screenH-self.contentToolBarHeight()-self.contentInsetBottom()-80, width: UIScreen.screenW, height: 80)
        self.selectedView.register(WPFIPPreviewSelectedCell.self, forCellWithReuseIdentifier: self.selectedCellIdentifier)
        self.selectedView.delegate = self
        self.selectedView.dataSource = self
        self.view.addSubview(self.selectedView)
        
        let line = UIView(frame: CGRect(x: 0, y: 79.5, width: UIScreen.screenW, height: 0.5))
        line.backgroundColor = UIColor(white: 0.21, alpha: 1)
        self.selectedView.addSubview(line)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Private Methods
extension WPFIPPreviewVC {
    /// 设置FullImageBtn状态
    func setFullImageBtnState(_ isSelected: Bool) {
        self.fullImageBtn.isSelected = isSelected
    }
    /// 返回点击事件
    func backAction() {
        self.isBacked = true
        if let block = self.backBlock {
            block(self)
        }
    }
    
    /// 新选中一个图片点击事件
    func selectAction() {
        guard let block = self.selectBlock  else {
            return
        }
        
        let idx: Int = lroundf(Float(self.collectionView.contentOffset.x / (UIScreen.screenW + kPreItemSpacing)))
        let result = block(idx)
        if result != -1 {
            self.selectBtn.idxLabel.text = "\(result)"
            let keyframe = CAKeyframeAnimation(keyPath: "transform.scale")
            keyframe.duration = 0.4
            keyframe.keyTimes = [0, 0.33, 0.66, 1]
            keyframe.values = [0.75, 1.08, 0.92, 1]
            self.selectBtn.layer.add(keyframe, forKey: "select_btn_transform")
            self.selectBtn.isSelected = true
            
            let items = [IndexPath(item: idx, section: 0)]
            self.selectedView.insertItems(at: items)
        } else {
            self.selectBtn.idxLabel.text = ""
            self.selectBtn.isSelected = false
            
            
            let items = [IndexPath(item: idx, section: 0)]
            self.selectedView.deleteItems(at: items)
        }
        
        WPFLog("测试")
    }
    
    /// 原图点击事件
    func fullImageBtnClick(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
        if let block = self.fullImageBlock {
            block()
        }
    }
    
    /// 发送按钮点击事件
    func sendBtnClick() {
        if let block = self.sendBlock {
            block()
        }
    }
    
    /// cell 点击
    func cellClick(_ isHidden: Int) {
        if isHidden != -1 {
            let temp = isHidden > 0 ? true : false
            
            self.navigationView.isHidden = temp
            self.toolBar.isHidden = temp
            self.selectedView.isHidden = temp
        } else {
            self.navigationView.isHidden = !self.navigationView.isHidden
            self.toolBar.isHidden = !self.toolBar.isHidden
            self.selectedView.isHidden = !self.selectedView.isHidden
        }
    }
    
    
}

//MARK: - Delegate
extension WPFIPPreviewVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            if self.selectIndex != -1 {
                return WPFIPManager.manager.listModel.count
            } else {
                return self.selectImages.count
            }
        } else {
            return WPFIPManager.manager.selectedCell.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            guard let cell: WPFIPPreviewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as? WPFIPPreviewCell else {
                fatalError("unexpected preview cell in collection view")
            }
            
            let model = WPFIPManager.manager.listModel.models[indexPath.row]
            
            if self.isBacked == true {
                return cell
            }
            
            cell.singleTapBlock = { [weak self] isHidden in
                self?.cellClick(isHidden)
            }
            
            cell.setValue(model, indexPath.row)
            
            if self.selectIndex != -1 {
                //            cell.setValue(WPFIPManager.manager.assets!.object(at: indexPath.row), indexPath.row)
            } else {
                
            }
            return cell
        } else {
            guard let cell: WPFIPPreviewSelectedCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.selectedCellIdentifier, for: indexPath) as? WPFIPPreviewSelectedCell else {
                fatalError("unexpected preview cell in collection view")
            }
            
            let idx = WPFIPManager.manager.selectedCell[indexPath.row]
            let model = WPFIPManager.manager.listModel.models[idx]
            
            let temp: Int = lroundf(Float(self.collectionView.contentOffset.x / (UIScreen.screenW + kPreItemSpacing)))
            
            if temp == idx {
                cell.setHightlighted(true)
                
                self.oldHightlightedCell = cell
            }

            cell.setValue(model)
            
            return cell
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView {
            let idx: Int = lroundf(Float(scrollView.contentOffset.x / (UIScreen.screenW + kPreItemSpacing)))
            
            // 控制 原图 按钮是否显示
            let model: WPFIPModel = WPFIPManager.manager.listModel.models[idx]
            if model.type == .image {
                self.fullImageBtn.isHidden = false
            } else {
                self.fullImageBtn.isHidden = true
            }
            
            // 控制 选中 按钮选择顺序
            if let seletIdx = WPFIPManager.manager.selectedCell.index(of: idx) {
                self.selectBtn.idxLabel.text = "\(seletIdx + 1)"
                self.selectBtn.isSelected = true
            } else {
                self.selectBtn.idxLabel.text = ""
                self.selectBtn.isSelected = false
            }
            
            
            /// 旧的高亮Cell取消高亮
            if let old = self.oldHightlightedCell {
                old.setHightlighted(false)
            }
            // 控制 已选中列表中的高亮
            if let current = WPFIPManager.manager.selectedCell.index(of: idx) {
                if current != self.oldSelectedCurrent {
                    let indexPath = IndexPath(item: current, section: 0)
                    if let cell: WPFIPPreviewSelectedCell = self.selectedView.cellForItem(at: indexPath) as? WPFIPPreviewSelectedCell {
                        cell.setHightlighted(true)
                        
                        self.oldHightlightedCell = cell
                    }

                    
                    self.oldSelectedCurrent = current
                }
            }

        } else {
            
            
            
        }
    }
    
}






