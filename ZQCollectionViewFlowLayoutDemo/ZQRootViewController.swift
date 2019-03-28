//
//  ZQRootViewController.swift
//  ZQCollectionViewFlowLayout
//
//  Created by Darren on 2019/3/27.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import ZQCollectionViewFlowLayout

class ZQRootViewController: UIViewController {
    
    fileprivate lazy var datasArr:[String] = {
        let datasArr:[String] = [
            "ZQCollectionViewDirectionFlowLayout",
            "ZQCollectionViewZoomFlowLayout",
            "ZQCollectionViewWaterFallsFlowLayout",
        ]
        return datasArr
    }()
    
    fileprivate lazy var tableView:UITableView = {
        let tableView:UITableView = UITableView(frame: view.bounds, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
    }
}

extension ZQRootViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self))!
        cell.textLabel?.text = datasArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var vc:UIViewController?
        switch indexPath.row {
        case 0:
            vc = ZQCollectionViewDirectionFlowLayoutController()
            
        case 1:
            vc = ZQCollectionViewZoomFlowLayoutController()
            
        case 2:
            vc = ZQCollectionViewWaterFallsFlowLayoutController()
            
        default:
            break
        }
        
        vc?.title = datasArr[indexPath.row]
        if vc != nil {
            navigationController?.pushViewController(vc!, animated: true)
        }
    }
}

