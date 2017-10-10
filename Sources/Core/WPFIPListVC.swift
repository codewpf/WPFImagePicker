//
//  WPFIPListVC.swift
//  WPFImagePicker
//
//  Created by alex on 2017/8/24.
//  Copyright © 2017年 alex. All rights reserved.
//
//  WPF Image Collection List View

import UIKit
import Photos

public class WPFIPListVC: WPFIPBaseVC {
    
    var cellHeight: CGFloat = 0
    
    var dataSources: [PHAssetCollection] = []
    let cellIdentifier = "wpf_ip_list_vc_cell"
    let tableView: UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: .plain)
        tv.tableFooterView = UIView()
        return tv
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // title
        self.navigationItem.title = Bundle.localizeString(forkey: WPFIPConstants.keys.imagePickerListVCTitle)
        
        // cancel barbtn
        let cancle = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtionClick))
        self.navigationItem.setRightBarButton(cancle, animated: false)

        // table view
        self.tableView.frame = self.view.bounds
        self.tableView.contentInset = UIEdgeInsets(top: self.contentInsetTop(), left: 0, bottom: 0, right: 0)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        // data source
        self.dataSources = WPFIPManager.manager.fetchAssetCollection()
        self.tableView.reloadData()
        
        
        
    }
    
}

extension WPFIPListVC {
    func cancelButtionClick() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}


extension WPFIPListVC {
    override public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            
        }
    }
    
}

extension WPFIPListVC: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSources.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: WPFIPListCell? = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) as! WPFIPListCell?
        if cell == nil {
            cell = WPFIPListCell(style: .default, reuseIdentifier: self.cellIdentifier)
        }
        let collection = self.dataSources[indexPath.row]
        cell?.setValue(collection)
        cell?.setCellHeight(WPFImagePicker.imagePicker.ipListCellHeight)
        return cell!
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WPFImagePicker.imagePicker.ipListCellHeight
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let collection = self.dataSources[indexPath.row]
        let assets =  PHAsset.fetchAssets(in: collection, options: nil)
        let grid = WPFIPGridVC(assets)
        grid.navigationItem.title = collection.localizedTitle
        self.navigationController?.pushViewController(grid, animated: true)
        
    }
}


class WPFIPListCell: UITableViewCell {
    let ipImageView: UIImageView
    let titleLabel: UILabel
    let countLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        ipImageView = UIImageView()
        titleLabel = UILabel()
        countLabel = UILabel()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.ipImageView.clipsToBounds = true
        self.countLabel.textColor = UIColor.lightGray
        
        self.addSubview(ipImageView)
        self.addSubview(titleLabel)
        self.addSubview(countLabel)
        
    }
    
    func setValue(_ collection: PHAssetCollection) {
        
        let assets = PHAsset.fetchAssets(in: collection, options: nil)
        if assets.count > 0 {
            self.ipImageView.contentMode = .scaleAspectFill

            PHImageManager.default().requestImage(for: assets.lastObject!, targetSize: CGSize(width: self.height*2, height: self.height*2), contentMode: .default, options: nil) { (image, _) in
                self.ipImageView.image = image
            }
        } else {
            self.ipImageView.contentMode = .scaleAspectFit

            self.ipImageView.image = UIImage(named: "image_default", in: Bundle.wpf(), compatibleWith: nil)
        }
        
        self.titleLabel.text = collection.localizedTitle
        self.titleLabel.sizeToFit()
        
        self.countLabel.text = "（\(assets.count)）"
        self.countLabel.sizeToFit()
        
    }
    
    func setCellHeight(_ height: CGFloat) {
        assert(self.countLabel.text != nil, "Please set value firstly")
        
        self.ipImageView.frame = CGRect(x: 0, y: 0, width: height, height: height)
        self.titleLabel.frame = CGRect(origin: CGPoint(x: self.ipImageView.trailing + 3, y: (height-self.titleLabel.height)/2), size: self.titleLabel.size)
        self.countLabel.frame = CGRect(origin: CGPoint(x: self.titleLabel.trailing + 3, y: (height-self.countLabel.height)/2), size: self.countLabel.size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}








