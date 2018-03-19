//
//  WPFIPPreviewSubview.swift
//  WPFImagePicker
//
//  Created by Alex on 2018/3/11.
//  Copyright © 2018年 alex. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

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
        
        if model.type == .gif && WPFImagePicker.imagePicker.conf.autoPlayGif == true {
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
    
    ///
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
                if WPFImagePicker.imagePicker.conf.autoPlayLivePhoto == true {
                    self.livePhotoView.startPlayback(with: .full)
                }
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
    
    /// 图像
    let imageView: UIImageView
    
    /// 标志
    let temp: UIView
    
    
    override init(frame: CGRect) {
        self.imageView = UIImageView()
        self.temp = UIView()
        super.init(frame: frame)
        
        self.imageView.frame = self.contentView.bounds
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.contentView.addSubview(self.imageView)
        
        
        self.temp.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        self.contentView.addSubview(self.temp)
        self.temp.isHidden = true
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
    
    func setHightlighted(_ isHightlighted: Bool) {
        self.temp.isHidden = !isHightlighted
        if isSelected == true {
//            self.imageView.layer.borderColor = WPFIPConstants.colors.themeGreen.cgColor
//            self.imageView.layer.borderWidth = 0.5
            
        } else {
//            self.imageView.layer.borderColor = nil
//            self.imageView.layer.borderWidth = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

