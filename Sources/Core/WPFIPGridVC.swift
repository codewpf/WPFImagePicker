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

class WPFIPGridVC: WPFIPBaseVC {
    
    /// 整个内容页面
    let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        // cancel bar btn
        let cancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelBtnClick))
        self.navigationItem.setRightBarButton(cancel, animated: false)
        
        self.contentView.frame = self.view.bounds
        self.view.addSubview(self.contentView)
        
        // collectionview
        self.collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.screenW, height: UIScreen.screenH-self.contentToolBarHeight())
        self.collectionView.contentInset = UIEdgeInsets(top: self.contentInsetTop(false), left: 0, bottom:  0, right: 0)
        self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
        self.collectionView.backgroundColor = UIColor.white
        self.collectionView.register(WPFIPGridCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        }
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.contentView.addSubview(self.collectionView)
        if WPFImagePicker.imagePicker.conf.canForceTouch == true {
            registerForPreviewing(with: self, sourceView: self.collectionView)
        }

        // toolbar
        self.initToolBar()
        
    }
    
    var initScroll: Int = 0

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// 第一次进入当前页面滚动到底部

        if self.initScroll == 0 {
            self.initScroll = 1
            if WPFIPManager.manager.listModel.count > 1 {
                self.collectionView.scrollToItem(at: IndexPath(item: WPFIPManager.manager.listModel.count - 1, section: 0), at: .top, animated: false)
            }

        }

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
        self.previewBtn.addTarget(self, action: #selector(self.preSelectImage), for: .touchUpInside)
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
        self.toolBar.frame = CGRect(x: 0, y: 0, width: UIScreen.screenW, height: self.kToolBarHeight)
        
        
        let toolBarBgView: UIView = UIView(frame: CGRect(x: 0, y: UIScreen.screenH-self.contentToolBarHeight()-self.contentInsetBottom(), width: UIScreen.screenW, height: self.contentToolBarHeight()))
        toolBarBgView.addSubview(self.toolBar)
        self.contentView.addSubview(toolBarBgView)
        
    }
    
    var isStatusBarHidden: Bool = false
    override var prefersStatusBarHidden: Bool {
        return self.isStatusBarHidden
    }
    
}

//MARK: - Private Medhod
extension WPFIPGridVC {
    // ------ 导航事件
    /// 取消选择图片
    func cancelBtnClick() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    // ------ 工具栏事件
    /// 预览已选择图片
    func preSelectImage() {
        
    }
    /// 使用原图
    func fullImageBtnClick(_ btn: UIButton) {
        btn.isSelected = !btn.isSelected
    }
    /// 确定选择
    func sendBtnClick() {
        
    }
    


    
    // ------ Cell事件
    /// cell 被选择(WPFIPGridCellSelectBlock 调用)
    /// - Parameter cell: 选中cell
    /// - Parameter isSelected: 当前状态
    func cellSelectBtnClick(_ cell: WPFIPGridCell, _ isSelected: Bool) {
        // 如果之前是被选中的状态 则修改为取消选中
        if isSelected == true {
            cell.updateBtn(selectIndex: 0, newState: !isSelected)
            
            WPFIPManager.manager.selectedCell.remove(object: cell.row)
        } else {
            // 判断当前的数量是否已经满额
            guard WPFIPManager.manager.selectedCell.count < WPFImagePicker.imagePicker.conf.maxSelect else {
                self.showMaximumAlert()
                return
            }
            cell.updateBtn(selectIndex: WPFIPManager.manager.selectedCell.count, newState: !isSelected, animate: true)
            
            // 添加进数组
            WPFIPManager.manager.selectedCell.append(cell.row)
        }
        
        if WPFIPManager.manager.selectedCell.count > 0 {
            self.previewBtn.isEnabled = true
            
            self.sendBtn.isEnabled = true
            self.sendBtn.setTitle("\(Bundle.localizeString(forkey: WPFIPConstants.keys.imagePickerGridVCSendBbiTitle))(\(WPFIPManager.manager.selectedCell.count))", for: .normal)
        } else {
            self.previewBtn.isEnabled = false
            
            self.sendBtn.isEnabled = false
            self.sendBtn.setTitle(Bundle.localizeString(forkey: WPFIPConstants.keys.imagePickerGridVCSendBbiTitle), for: .normal)
        }
        
        
        self.updateSelectedItem()
        
        // 两个临界点 刷新Collection item coverView 的状态
        if WPFIPManager.manager.selectedCell.count == WPFImagePicker.imagePicker.conf.maxSelect ||
            WPFIPManager.manager.selectedCell.count == WPFImagePicker.imagePicker.conf.maxSelect - 1 {
            for cell in self.collectionView.visibleCells {
                if let grid = cell as? WPFIPGridCell {
                    grid.updateCoverState(self.canClick(grid.row))
                }
            }
        }
    }

    
    
    /// 点击Cell 预览
    func previewBtnClick(_ index: Int) {
        let prevc = WPFIPPreviewVC(all: index)
        self.addChildViewController(prevc)
        prevc.view.frame = CGRect(x: self.view.bounds.width, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(prevc.view)
        prevc.didMove(toParentViewController: self)
        
        self.updateNavigation(isHidden: true, subvc: prevc)
        prevc.backBlock = { [weak self] vc in
            self?.previewBackClick(vc)
        }
        prevc.fullImageBlock = { [weak self] in
            self?.previewFullImageClick()
        }
        prevc.selectBlock = { [weak self] idx in
            if let result =  self?.previewSelectClick(idx) {
                return result
            } else {
                return -1
            }
        }
        prevc.sendBlock = { [weak self] in
            self?.previewSendClick()
        }
        
        prevc.setFullImageBtnState(self.fullImageBtn.isSelected)
    }
    
    /// 预览界面变化导致的导航变化
    func updateNavigation(isHidden state: Bool, subvc vc: WPFIPBaseVC) {
        self.isStatusBarHidden = state
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.setNavigationBarHidden(state, animated: false)
        
        var currentLeading: CGFloat = -100
        var leading: CGFloat = 0
        if state == false {
            currentLeading = 0
            leading = self.view.bounds.width
            //            self.navigationController?.setNavigationBarHidden(state, animated: true)
        } else {
            //            self.navigationController?.setNavigationBarHidden(state, animated: false)
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.contentView.leading = currentLeading
            vc.view.leading = leading
        }) { (_) in
            if state == false {
                vc.willMove(toParentViewController: nil)
                vc.view.removeFromSuperview()
                vc.removeFromParentViewController()
            }
        }
    }

    
    /// 当前cell 是否能点击
    func canClick(_ row: Int) -> Bool {
        var state = false
        state = WPFIPManager.manager.selectedCell.count < 9
        if WPFIPManager.manager.selectedCell.contains(row) {
            state = true
        }
        return state
    }
    
    // ------ 公共事件
    /// 选择item有变化，刷新选择item
    func updateSelectedItem() {
        for (idx, value) in WPFIPManager.manager.selectedCell.enumerated() {
            let indexPath = IndexPath(item: value, section: 0)
            if let cell = self.collectionView.cellForItem(at: indexPath) as? WPFIPGridCell {
                cell.updateBtn(selectIndex: idx+1, newState: true, animate: false)
            }
        }
    }
}

//MARK: - Preview VC Block Methods
extension WPFIPGridVC {
    /// 预览界面 返回 按钮点击
    func previewBackClick(_ vc: WPFIPPreviewVC) {
        self.updateNavigation(isHidden: false, subvc: vc)
    }
    /// 预览界面 原图 按钮点击
    func previewFullImageClick() {
        self.fullImageBtn.isSelected = !self.fullImageBtn.isSelected
    }
    /// 预览界面 选择 按钮点击
    func previewSelectClick(_ idx: Int) -> Int {
        guard WPFIPManager.manager.selectedCell.count < WPFIPConfiguration.default.maxSelect else {
            return -1
        }
        
        let indexPath = IndexPath(item: idx, section: 0)
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? WPFIPGridCell else {
            return -1

        }
        
        self.cellSelectBtnClick(cell, cell.selectBtn.isSelected)

        /// cell 状态改变之后的判断
        if cell.selectBtn.isSelected == true {
            return WPFIPManager.manager.selectedCell.count
        } else {
            return -1
        }
        
        
    }
    /// 预览界面 发送 按钮点击
    func previewSendClick() {
        self.sendBtnClick()
    }
}


//MARK: - CollectionView Delegate & DataSource
extension WPFIPGridVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return WPFIPManager.manager.listModel.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell: WPFIPGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as? WPFIPGridCell else {
            fatalError("unexpected cell in collection view")
        }
        
        /// 重置Cell
        cell.renewCell()
        
//        /// 设置图片数据
        let row = indexPath.row
        let model = WPFIPManager.manager.listModel.models[row]
        cell.setValue(model, row, self.canClick(row))
        
        /// 选择
        cell.cellSelectBlock = { [weak self] cell in
            self?.cellSelectBtnClick(cell, cell.selectBtn.isSelected)
        }
        /// 预览
        cell.tapBlock = { [weak self] in
            self?.previewBtnClick(indexPath.row)
        }
        
        /// 设置选择状态
        if let idx = WPFIPManager.manager.selectedCell.index(of: indexPath.row) {
            cell.updateBtn(selectIndex: idx+1, newState: true, animate: false)
        }
        
        return cell
    }
}

//MARK: - UIViewControllerPreviewingDelegate
extension WPFIPGridVC: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.collectionView.indexPathForItem(at: location),
            let cell = self.collectionView.cellForItem(at: indexPath) as? WPFIPGridCell else {
            return nil
        }
        
        previewingContext.sourceRect = cell.frame
        
        let forceTouchVC = WPFIPForceTouchVC(cell.row)
        forceTouchVC.preferredContentSize = forceTouchVC.size()
        return forceTouchVC
    }

    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        guard let forceTouchVC = viewControllerToCommit as? WPFIPForceTouchVC else {
            return
        }
        
        let prevc = WPFIPPreviewVC(all: forceTouchVC.index)
        prevc.backBlock = { [weak self] vc in
            self?.previewBackClick(vc)
        }
        prevc.fullImageBlock = { [weak self] in
            self?.previewFullImageClick()
        }

        self.addChildViewController(prevc)
        prevc.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.view.addSubview(prevc.view)
        prevc.didMove(toParentViewController: self)

        self.updateNavigation(isHidden: true, subvc: prevc)
        
        prevc.setFullImageBtnState(self.fullImageBtn.isSelected)

    }
    
}


//MARK: - WPFIPGridCell
/// 选择按钮 被点击
///
/// - Parameters:
///   - griCell: current item.
///   - isSelected: now state.
typealias WPFIPGridCellSelectBlock = (_ griCell: WPFIPGridCell) -> Void

class WPFIPGridCell: UICollectionViewCell {
    
    // row of the cell
    var row: Int = -1
    
    // block
    var cellSelectBlock: WPFIPGridCellSelectBlock? = nil
    
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
    func setValue(_ model: WPFIPModel, _ row: Int, _ canClick: Bool) {
        let width = ((UIScreen.screenW - kGridGap * (kGridLines + 1)) / kGridLines ) * 3

        DispatchQueue.global().async {
            _ = WPFIPManager.manager.requestImage(for: model.asset, size: CGSize(width: width, height: width)) { (restult, image, _) in
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
        
        self.row = row
        
        self.coverView.isHidden = canClick
    }
    
    // 修改白色覆盖状态
    func updateCoverState(_ canClick: Bool) {
        self.coverView.isHidden = canClick
    }
    
    // 修改选择按钮状态
    func updateBtn(selectIndex index: Int, newState isSelected: Bool, animate: Bool = true) {
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
        guard let block = self.cellSelectBlock else {
            fatalError("the cell does not have the block of select action")
        }
        block(self)
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







