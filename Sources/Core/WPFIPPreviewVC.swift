//
//  WPFIPPreviewVC.swift
//  WPFImagePicker
//
//  Created by alex on 2017/10/11.
//  Copyright © 2017年 alex. All rights reserved.
//
/*
 1、返回按钮
 2、pre转场动画
 
 */

import UIKit

class WPFIPPreviewVC: WPFIPBaseVC {
    
    var isStatusBarHidden: Bool = true

    var backBlock: WPFIPVoidBlock? = nil
    
    let navigationBar: UIView = {
        let nav = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.screenW, height: 64))
        nav.backgroundColor = UIColor(patternImage: UIImage(named: "nav_bg", in: Bundle.wpf(), compatibleWith: nil)!)
        return nav
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.screenW, height: UIScreen.screenH)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        return cv
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        self.navigationController?.navigationBar.isHidden = true

        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.screenW, height: UIScreen.screenH))
        view.backgroundColor = UIColor.blue
        self.view.addSubview(view)
        
//        self.view.addSubview(self.collectionView)
        
        self.view.addSubview(self.navigationBar)
        self.initNavBar()
        
    }
    
    func initNavBar() {
        let back = UIButton(type: .custom)
        back.frame = CGRect(x: 12, y: 20, width: 44, height: 44)
        back.setImage(UIImage(named: "btn_back", in: Bundle.wpf(), compatibleWith: nil), for: .normal)
        back.addTarget(self, action: #selector(self.navBackClick), for: .touchUpInside)
        self.navigationBar.addSubview(back)
        
    }
    
    func updateNavAndStatus(_ state: Bool) {
//        self.isStatusBarHidden = state
//        self.setNeedsStatusBarAppearanceUpdate()
//        self.navigationController?.navigationBar.isHidden = state
        
    }


    
    
}

extension WPFIPPreviewVC {
    override var prefersStatusBarHidden: Bool {
        return self.isStatusBarHidden
    }
}

extension WPFIPPreviewVC {
    func navBackClick() {
        guard let block = self.backBlock else {
            return
        }
        block()
        self.navigationController?.popViewController(animated: true)
    }
    
}







