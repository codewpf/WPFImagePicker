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
    
    var dataSources: [WPFIPListModel] = []
    let cellIdentifier = "wpf_ip_list_vc_cell"
    let tableView: UITableView = {
        let tv = UITableView(frame: CGRect.zero, style: .plain)
        tv.tableFooterView = UIView()
        return tv
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // title
        self.wpfTitle = Bundle.localizeString(forkey: WPFIPConstants.keys.imagePickerListVCTitle)
        
        // cancel barbtn
        let cancle = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtionClick))
        self.navigationItem.setRightBarButton(cancle, animated: false)
        
        // table view
        self.tableView.frame = self.view.bounds
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
        let listModel = self.dataSources[indexPath.row]
        cell?.setValue(listModel)
        cell?.setCellHeight(WPFImagePicker.imagePicker.conf.listCellHeight)
        return cell!
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WPFImagePicker.imagePicker.conf.listCellHeight
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let listModel = self.dataSources[indexPath.row]
        WPFIPManager.manager.listModel = listModel
        let grid = WPFIPGridVC()
        grid.wpfTitle = listModel.title
        self.navigationController?.pushViewController(grid, animated: true)
    }
}










