//
//  ZQCollectionViewEqualSpaceFlowLayoutController.swift
//  ZQCollectionViewFlowLayoutDemo
//
//  Created by Darren on 2019/3/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import ZQCollectionViewFlowLayout

class ZQCollectionViewEqualSpaceFlowLayoutController: UIViewController {

    fileprivate lazy var datasArr:[String] = {
        let datasArr:[String] = [
            "horizontalLayoutHorizontalScroll",
            "horizontalLayoutVerticalScroll",
            "verticalLayoutHorizontalScroll",
            "verticalLayoutVerticalScroll",
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
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
    }
}

extension ZQCollectionViewEqualSpaceFlowLayoutController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self))!
        cell.textLabel?.text = datasArr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let layout = ZQCollectionViewEqualSpaceFlowLayout()
        switch indexPath.row {
        case 0:
            layout.layoutDirection = .horizontal
            layout.scrollDirection = .horizontal
            
        case 1:
            layout.layoutDirection = .horizontal
            layout.scrollDirection = .vertical
            
        case 2:
            layout.layoutDirection = .vertical
            layout.scrollDirection = .horizontal
            
        case 3:
            layout.layoutDirection = .vertical
            layout.scrollDirection = .vertical
            
        default:
            break
        }
        
        let vc = ZQCollectionViewEqualSpaceFlowLayoutShowController()
        vc.layout = layout
        vc.title = datasArr[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

