//
//  ZQCollectionViewStickySectionHeaderFlowLayoutController.swift
//  ZQCollectionViewFlowLayoutDemo
//
//  Created by Darren on 2019/9/5.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import ZQCollectionViewFlowLayout

class ZQCollectionViewStickySectionHeaderFlowLayoutController: UIViewController {
    
    fileprivate lazy var datasArr:[[String]] = {
        var datasArr:[[String]] = [[String]]()
        for i:Int in 0..<2 {
            var arr:[String] = [String]()
            for i:Int in 0..<17 {
                arr.append(i.description)
            }
            datasArr.append(arr)
        }
        return datasArr
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let layout:ZQCollectionViewStickySectionHeaderFlowLayout = ZQCollectionViewStickySectionHeaderFlowLayout()
        let width:CGFloat = view.bounds.size.width
        layout.itemSize = CGSize(width: width, height: 44)
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: width, height: 30)
        layout.minimumLineSpacing = 0
        let collectionView:UICollectionView = UICollectionView(frame: CGRect(x: 0, y: 100, width: width, height: view.bounds.size.height - 200), collectionViewLayout: layout)
        collectionView.backgroundColor = .yellow
        collectionView.register(ZQCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NSStringFromClass(ZQCollectionReusableView.self))
        collectionView.register(ZQCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ZQCollectionViewCell.self))
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
}

extension ZQCollectionViewStickySectionHeaderFlowLayoutController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return datasArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasArr[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ZQCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ZQCollectionViewCell.self), for: indexPath) as! ZQCollectionViewCell
        cell.title = datasArr[indexPath.section][indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header:ZQCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NSStringFromClass(ZQCollectionReusableView.self), for: indexPath) as! ZQCollectionReusableView
            header.backgroundColor = indexPath.section % 2 == 0 ? UIColor.red : UIColor.blue
            return header
        }
        return UICollectionReusableView()
    }
}
