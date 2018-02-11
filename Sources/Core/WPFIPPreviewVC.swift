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
        } else {
            self.selectBtn.idxLabel.text = ""
            self.selectBtn.isSelected = false
        }
        
        self.selectedView.reloadData()
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
            
            
            
            // 控制 已选中列表中的高亮
        } else {
            
            
            
        }
    }
    
}

/// -1: 当前值取反； 0: false； 1: true
typealias WPFIPPreviewCellBlock = (_ isHidden: Int) -> Void

//MARK: - Preview Collection Cell
class WPFIPPreviewCell: UICollectionViewCell {
    
    /// 点击回调事件
    var singleTapBlock: WPFIPPreviewCellBlock? = nil
    
    // row of the cell
    var row: Int = -1
    
    /// Cell detail view
    let detailView: WPFIPPreviewDetailView
    
    override init(frame: CGRect) {
        detailView = WPFIPPreviewDetailView(frame: CGRect(origin: .zero, size: frame.size))
        super.init(frame: frame)
        detailView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.addSubview(detailView)
        
    }
    
    func setValue(_ model: WPFIPModel, _ row: Int) {
        self.row = row
        
        self.detailView.singleTapBlock = self.singleTapBlock
        
        self.detailView.model = model
    }
    
    /// 重置 状态
    func resetStatus() {
        self.singleTapBlock = nil
        
        self.row = -1
        
        self.detailView.resetStatus()
    }
    
    /// 重置 视图
    func reloadView() {
        self.detailView.reloadView()
    }
    
    /// 暂停动画
    func pauseAnimating() {
        self.detailView.pauseAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// the detail of cell
class WPFIPPreviewDetailView: UIView {

    /// 点击回调事件
    var singleTapBlock: WPFIPPreviewCellBlock? = nil
    
    private var pModel: WPFIPModel = WPFIPModel()
    /// source
    var model: WPFIPModel {
        get {
            return pModel
        }
        set {
            pModel = newValue
            self.setModel()
        }
    }
    
    private var imageView: WPFIPPreviewImageView? = nil
    private var livePhotoView: WPFIPPreviewLivePhotoView? = nil
    private var videoView: WPFIPPreviewVideoView? = nil
    
    private func setModel() {
        for sub in self.subviews {
            sub.removeFromSuperview()
        }
        
        switch self.pModel.type {
        case .image, .gif:
            self.imageView = WPFIPPreviewImageView(frame: self.bounds)
            self.imageView!.singleGesTabBlock = self.singleTapBlock
            self.addSubview(self.imageView!)
            self.imageView!.loadRequest(for: self.model)
            break
        case .livePhoto:
            self.livePhotoView = WPFIPPreviewLivePhotoView(frame: self.bounds)
            self.livePhotoView?.singleGesTabBlock = self.singleTapBlock
            self.addSubview(self.livePhotoView!)
            self.livePhotoView!.loadRequest(for: self.model)
            break
        case .video:
            self.videoView = WPFIPPreviewVideoView(frame: self.bounds)
            self.videoView!.singleGesTabBlock = self.singleTapBlock
            self.addSubview(self.videoView!)
            self.videoView!.loadRequest(for: self.model)
            break
        default: break
            
        }
    }
    
    /// 重置 视图、数据状态
    func resetStatus() {
        self.pModel = WPFIPModel()
        
        if let imageView = self.imageView {
            imageView.resetScale()
        }

        for sub in self.subviews {
            sub.removeFromSuperview()
        }
    }
    
    /// 重置 加载视图
    func reloadView() {
        switch self.pModel.type {
        case .image, .gif:
            if let imageView = self.imageView {
                imageView.loadRequest(for: self.model)
            }
            break
        case .livePhoto:
            if let livePhotoView = self.livePhotoView {
                livePhotoView.loadRequest(for: self.model)
            }
            break
        case .video:
            break
        default: break
        }

    }
    
    /// 暂停播放
    func pauseAnimating() {
        if let videoView = self.videoView {
            videoView.pausePlay()
        }
    }
    
    /// 充值比例
    func restScale() {
        if let imageView = self.imageView {
            imageView.resetScale()
        }
    }
}

/// 展示子类协议
protocol WPFIPPreviewType: NSObjectProtocol {
    /// 请求ID
    var requestID: PHImageRequestID { get }
    
    var singleTapGes: UITapGestureRecognizer { get }
    
    /// 单次点击事件回调
    var singleGesTabBlock: WPFIPPreviewCellBlock? { get set }

    /// 加载指示器
    var indicator: UIActivityIndicatorView { get }
    
    /// 加载视图事件
    func loadRequest(for model: WPFIPModel)

    /// 单次点击事件回调
    func singleGesTap()
}

/// 最大缩放比例
private let kMaximumZoomScale: CGFloat = 4.0
/// 最小缩放比例
private let kMinimumZoomScale: CGFloat = 1.0
/// ImageView
class WPFIPPreviewImageView: UIView, WPFIPPreviewType, UIScrollViewDelegate {
    
    var requestID: PHImageRequestID = -1
    
    var singleGesTabBlock: WPFIPPreviewCellBlock? = nil
    
    var indicator: UIActivityIndicatorView = {
        let _indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        _indicator.hidesWhenStopped = true
        return _indicator
    }()
    
    let scrollView: UIScrollView = {
        let _scrollView = UIScrollView(frame: CGRect.zero)
        _scrollView.maximumZoomScale = kMaximumZoomScale
        _scrollView.minimumZoomScale = kMinimumZoomScale
        _scrollView.isMultipleTouchEnabled = true
        _scrollView.scrollsToTop = true
        _scrollView.showsVerticalScrollIndicator = false
        _scrollView.showsHorizontalScrollIndicator = false
        _scrollView.delaysContentTouches = false
        return _scrollView
    }()
    
    let imageView: UIImageView = {
        let _imageView = UIImageView()
        _imageView.contentMode = .scaleAspectFit
        return _imageView
    }()
    
    let containView: UIView = {
        let _containView: UIView = UIView()
        return _containView
    }()
    
    var singleTapGes: UITapGestureRecognizer = {
        let _singleTapGes = UITapGestureRecognizer()
        return _singleTapGes
    }()
    
    var zoomScale: CGFloat = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.scrollView.frame = CGRect(origin: CGPoint.zero, size: self.bounds.size)
        self.scrollView.delegate = self
        self.addSubview(self.scrollView)
        
        self.scrollView.addSubview(self.containView)
        
        self.containView.addSubview(self.imageView)
        
        self.addSubview(self.indicator)
        
        self.singleTapGes.addTarget(self, action: #selector(self.singleGesTap))
        self.addGestureRecognizer(self.singleTapGes)
        
        let doubleTapGes = UITapGestureRecognizer(target: self, action: #selector(self.doubleGesTap(_:)))
        doubleTapGes.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGes)
        
        self.singleTapGes.require(toFail: doubleTapGes)
    }
    
    /// 单次点击事件
    @objc func singleGesTap() {
        guard let block = self.singleGesTabBlock else {
            return
        }
        block(-1)
    }
    
    @objc func doubleGesTap(_ tap: UITapGestureRecognizer) {
        var scale: CGFloat = 1.0
        if self.scrollView.zoomScale != kMaximumZoomScale {
            scale = kMaximumZoomScale / 2
        } else {
            scale = kMinimumZoomScale
        }
        let rect =  self.zoomRect(for: scale, with: tap.location(in: tap.view))
        scrollView.zoom(to: rect, animated: true)
    }
    
    func zoomRect(for scale: CGFloat, with center: CGPoint) -> CGRect {
        var rect: CGRect = CGRect()
        rect.size.height = self.scrollView.height / scale
        rect.size.width = self.scrollView.width / scale
        rect.origin.x = center.x - rect.size.width / 2
        rect.origin.y = center.y - rect.size.height / 2
        return rect
    }
    
    func loadRequest(for model: WPFIPModel) {

        self.indicator.startAnimating()
        
        if model.type == .gif {
            if self.requestID != -1 {
                PHCachingImageManager.default().cancelImageRequest(self.requestID)
            }
            DispatchQueue.global().async {
                let id = WPFIPManager.manager.requestImageData(for: model.asset) { (result, data, _) in
                    if result == true, let image = data.toGIF() {
                        DispatchQueue.main.async {
                            self.imageView.image = image
                            self.resumeAnimating()
                            self.resetContent(for: image.size)
                            self.indicator.stopAnimating()
                        }
                    }
                }
                self.requestID = id
            }
        } else {
            if self.requestID != -1 {
                PHCachingImageManager.default().cancelImageRequest(self.requestID)
            }
            
            let scale: CGFloat = 2.0
            let width: CGFloat = min(UIScreen.screenW, 500)
            let size = CGSize(width: width * scale, height: width * scale * CGFloat(model.asset.pixelHeight / model.asset.pixelWidth))
            let id = WPFIPManager.manager.requestImage(for: model.asset, size: size, completion: { (result, image, nil) in
                if result == true {
                    self.imageView.image = image
                    if let img = image {
                        self.resetContent(for: img.size)
                    }
                    self.indicator.stopAnimating()
                }
            })
            self.requestID = id
        }
        
    }
    
    func resetScale() {
        self.scrollView.zoomScale = 1.0
    }
    
    ///
    func resetContent(for size: CGSize) {
        var frame: CGRect = CGRect.zero
        
        let width = min(size.width, UIScreen.screenW)
        
        frame.size.width = width
        
        var imageScale: CGFloat = 1.0
        if let image = self.imageView.image {
            imageScale = image.size.height / image.size.width
        }
        let screenScale = self.height / UIScreen.screenW
        if imageScale > screenScale {
            frame.size.height = CGFloat(floor(Double(width * imageScale)))
        } else {
            var height = CGFloat(floor(Double(width * imageScale)))
            if height < 1 || height.isNaN {
                height = self.height
            }
            frame.size.height = height
        }
        
        self.containView.frame = frame
        
        
        let contentSize: CGSize = CGSize(width: width, height: max(self.height, frame.size.height))
        if frame.size.height < self.height {
            self.containView.center = CGPoint(x: self.width/2, y: self.height/2)
        } else {
            self.containView.frame = CGRect(origin: CGPoint(x: (self.width-frame.size.width)/2, y: 0), size: frame.size)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.scrollView.contentSize = contentSize
            
            self.imageView.frame = self.containView.bounds
            
            self.scrollView.scrollRectToVisible(self.bounds, animated: false)
        }
    }
    
    /// 开始GIF动画
    func resumeAnimating() {
        let layer = self.imageView.layer
        guard layer.speed == 0 else {
            return
        }
        let pausedTime: CFTimeInterval = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    
    /// 暂停GIF动画
    func pauseAnimating() {
        let layer = self.imageView.layer
        guard layer.speed != 0 else {
            return
        }
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    /// UIScrollViewDelegate
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.zoomScale = scrollView.zoomScale
        let offsetX = (scrollView.width > scrollView.contentSize.width) ? (scrollView.width - scrollView.contentSize.width) / 2 : 0.0
        let offsetY = (scrollView.height > scrollView.contentSize.height) ? (scrollView.height - scrollView.contentSize.height) / 2 : 0.0
        self.containView.center = CGPoint(x: scrollView.contentSize.width / 2 + offsetX, y: scrollView.contentSize.height / 2 + offsetY)
    }
    
    /// UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.resumeAnimating()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// LivePhoto
class WPFIPPreviewLivePhotoView: UIView, WPFIPPreviewType {
    
    var requestID: PHImageRequestID = -1
    
    var singleGesTabBlock: WPFIPPreviewCellBlock? = nil

    var indicator: UIActivityIndicatorView = {
        let _indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        _indicator.hidesWhenStopped = true
        return _indicator
    }()
    
    let livePhotoView: PHLivePhotoView = {
        let _livePhotoView = PHLivePhotoView()
        _livePhotoView.contentMode = .scaleAspectFit
        return _livePhotoView
    }()
    
    var singleTapGes: UITapGestureRecognizer = {
        let _singleTapGes = UITapGestureRecognizer()
        return _singleTapGes
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.livePhotoView.frame = self.bounds
        self.addSubview(self.livePhotoView)
        
        self.addSubview(self.indicator)

        self.singleTapGes.addTarget(self, action: #selector(self.singleGesTap))
        self.addGestureRecognizer(self.singleTapGes)
    }
    
    /// 加载livePhoto
    func loadRequest(for model: WPFIPModel) {
        self.requestID = WPFIPManager.manager.requestLivePhoto(for: model.asset, completion: { (result, livePhoto, _) in
            if result == true {
                self.livePhotoView.livePhoto = livePhoto
                self.livePhotoView.startPlayback(with: .full)
            }
        })
    }
    
    /// 停止播放
    func stopPlay() {
        self.livePhotoView.stopPlayback()
    }
    
    /// 单次点击事件
    @objc func singleGesTap() {
        guard let block = self.singleGesTabBlock else {
            return
        }
        block(-1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// Video
class WPFIPPreviewVideoView: UIView, WPFIPPreviewType {
    
    var requestID: PHImageRequestID = -1
    
    var singleGesTabBlock: WPFIPPreviewCellBlock? = nil

    var indicator: UIActivityIndicatorView = {
        let _indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        _indicator.hidesWhenStopped = true
        return _indicator
    }()
    
    var singleTapGes: UITapGestureRecognizer = {
        let _singleTapGes = UITapGestureRecognizer()
        return _singleTapGes
    }()
    
    /// 播放视图层
    let playLayer: AVPlayerLayer = {
        let _playLayer = AVPlayerLayer()
        return _playLayer
    }()
    /// 播放按钮
    var playBtn: UIButton = {
        let _playBtn = UIButton(type: .custom)
        _playBtn.setBackgroundImage(UIImage(named: "btn_video_play", in: Bundle.wpf(), compatibleWith: nil), for: .normal)
        _playBtn.setBackgroundImage(UIImage(named: "btn_video_play_hl", in: Bundle.wpf(), compatibleWith: nil), for: .highlighted)
        _playBtn.frame = CGRect(x: 0, y: 0, width: 85, height: 85)
        return _playBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.playLayer.frame = self.bounds
        self.layer.addSublayer(self.playLayer)
        
        self.playBtn.center = self.center
        self.playBtn.addTarget(self, action: #selector(self.playBtnClick), for: .touchUpInside)
        self.addSubview(self.playBtn)
        
        self.addSubview(self.indicator)
        
        self.singleTapGes.addTarget(self, action: #selector(self.singleGesTap))
        self.addGestureRecognizer(self.singleTapGes)

    }
    
    /// 加载资源
    func loadRequest(for model: WPFIPModel) {
        self.requestID = WPFIPManager.manager.requestVideo(for: model.asset) { (result, item, nil) in
            if result {
                let player: AVPlayer = AVPlayer(playerItem: item)
                self.playLayer.player = player
                NotificationCenter.default.addObserver(self, selector: #selector(self.playToEnd), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            }
        }
    }
    
    /// 暂停时 播放按钮点击
    func playBtnClick() {
        if let block = self.singleGesTabBlock {
            block(1)
        }
        self.playAction()
    }

    /// 播放时 手指点击
    func singleGesTap() {
        if let block = self.singleGesTabBlock {
            if self.playBtn.isHidden == true {
                block(0)
            } else {
                block(1)
            }
        }
        self.playAction()
    }

    func playAction() {
        guard let player = self.playLayer.player,
            let current = player.currentItem else {
                return
        }
        let stop = current.currentTime()
        let duration = current.duration
        
        if player.rate == 0.0 {
            self.playBtn.isHidden = true
            if stop.value == duration.value {
                current.seek(to: CMTime(value: 0, timescale: 1))
            }
            player.play()
        } else {
            self.playBtn.isHidden = false
            player.pause()
        }
    }
    
    /// 视频播放结束
    @objc func playToEnd() {
        guard let player = self.playLayer.player else {
            return
        }
        player.seek(to: kCMTimeZero)
        self.playBtn.isHidden = false
        if let block = self.singleGesTabBlock {
            block(0)
        }
    }
    
    /// 停止播放
    func pausePlay() {
        guard let player = self.playLayer.player else {
            return
        }
        if player.rate != 0.0 {
            self.playBtn.isHidden = false
            player.pause()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class WPFIPPreviewSelectButton: UIButton {
    
    let idxLabel: UILabel
    
    override init(frame: CGRect) {
        self.idxLabel = UILabel()
        super.init(frame: frame)
        
        self.idxLabel.font = UIFont.systemFont(ofSize: 16)
        self.idxLabel.textColor = UIColor.white
        self.idxLabel.textAlignment = .center
        self.addSubview(self.idxLabel)
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            self.idxLabel.frame = CGRect(origin: CGPoint.zero, size: frame.size)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class WPFIPPreviewSelectedCell: UICollectionViewCell {
    let imageView: UIImageView
    
    override init(frame: CGRect) {
        self.imageView = UIImageView()
        super.init(frame: frame)
        
        self.imageView.frame = self.contentView.bounds
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.contentView.addSubview(self.imageView)
        
        
    }
    
    func setValue(_ model: WPFIPModel) {
        let width = 54 * UIScreen.main.scale * 2
        DispatchQueue.global().async {
            _ = WPFIPManager.manager.requestImage(for: model.asset, size: CGSize(width: width, height: width)) { (restult, image, _) in
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}





