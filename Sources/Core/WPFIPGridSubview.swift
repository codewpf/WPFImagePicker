//
//  WPFIPGridSubview.swift
//  WPFImagePicker
//
//  Created by Alex on 2018/3/11.
//  Copyright © 2018年 alex. All rights reserved.
//

import UIKit
import Photos

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


