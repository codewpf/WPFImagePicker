//
//  WPFIPDeniedVC.swift
//  WPFImagePicker
//
//  Created by alex on 2017/9/22.
//  Copyright © 2017年 alex. All rights reserved.
//

import UIKit

class WPFIPDeniedVC: WPFIPBaseVC {

    let defaultFrame = CGRect(x: 30, y: 30, width: UIScreen.screenW-30*2, height: 200)
    let defaultFont = UIFont.systemFont(ofSize: 15)
    let defaultTextColor = UIColor.darkGray

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let label: UILabel = UILabel(frame: self.defaultFrame)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = self.defaultFont
        label.textColor = self.defaultTextColor
        let placeholder = Bundle.localizeString(forkey: WPFIPConstants.keys.imagePickerDeniedText)
        label.text = String(format: placeholder, arguments: [Bundle.main.bundleName])
        self.view.addSubview(label)
        
        
        let cancle = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtionClick))
        self.navigationItem.setRightBarButton(cancle, animated: false)

    }
}


extension WPFIPDeniedVC {
    @objc func cancelButtionClick() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

