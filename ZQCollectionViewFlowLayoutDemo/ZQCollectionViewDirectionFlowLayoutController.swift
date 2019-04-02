//
//  ZQCollectionViewDirectionFlowLayoutController.swift
//  ZQCollectionViewFlowLayoutDemo
//
//  Created by Darren on 2019/3/27.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import ZQCollectionViewFlowLayout

class ZQCollectionViewDirectionFlowLayoutController: UIViewController {
    
    fileprivate lazy var datasArr:[[String]] = {
        let datasArr:[[String]] = [
            ["1", "2", "3", "4", "5"],
            ["1", "2", "3", "4", "5", "6", "7", "8"],
            ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"],
        ]
        return datasArr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let horizontalLayout = getLayout(layoutDirection: .horizontal)
        horizontalLayout.scrollDirection = .horizontal
        let width:CGFloat = 200
        let horizontalCollectionView:UICollectionView = getCollectionView(frame: CGRect(x: (view.bounds.size.width - width) * 0.5, y: UIApplication.shared.statusBarFrame.size.height + (navigationController?.navigationBar.frame.size.height)! + 20, width: width, height: width), layout: horizontalLayout)
        view.addSubview(horizontalCollectionView)
        
        let horizontalLabel = getLabel(frame: CGRect(x: horizontalCollectionView.frame.origin.x, y: horizontalCollectionView.frame.maxY + 10, width: width, height: 30), title: "horizontalLayout")
        view.addSubview(horizontalLabel)
        
        let verticalLayout = getLayout(layoutDirection: .vertical)
        verticalLayout.scrollDirection = .vertical
        let verticalCollectionView:UICollectionView = getCollectionView(frame: CGRect(x: (view.bounds.size.width - width) * 0.5, y: horizontalCollectionView.frame.maxY + 50, width: width, height: width), layout: verticalLayout)
        view.addSubview(verticalCollectionView)
        let verticalLabel = getLabel(frame: CGRect(x: verticalCollectionView.frame.origin.x, y: verticalCollectionView.frame.maxY + 10, width: width, height: 30), title: "verticalLayout")
        view.addSubview(verticalLabel)
    }
}

extension ZQCollectionViewDirectionFlowLayoutController {
    fileprivate func getLayout(layoutDirection:ZQCollectionViewFlowLayoutDirection) -> ZQCollectionViewDirectionFlowLayout {
        let layout = ZQCollectionViewDirectionFlowLayout()
        layout.rowNum = 3
        layout.colNum = 3
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.layoutDirection = layoutDirection
        layout.itemSize = CGSize(width: 50, height: 50)
        return layout
    }
    
    fileprivate func getCollectionView(frame:CGRect, layout:ZQCollectionViewDirectionFlowLayout) -> UICollectionView {
        let collectionView:UICollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.blue
        collectionView.register(ZQCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ZQCollectionViewCell.self))
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        return collectionView
    }
    
    fileprivate func getLabel(frame:CGRect, title:String) -> UILabel {
        let label = UILabel(frame: frame)
        label.text = title
        label.textAlignment = .center
        label.textColor = UIColor.red
        return label
    }
}

extension ZQCollectionViewDirectionFlowLayoutController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasArr[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ZQCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ZQCollectionViewCell.self), for: indexPath) as! ZQCollectionViewCell
        cell.title = datasArr[indexPath.section][indexPath.row]
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return datasArr.count
    }
}


