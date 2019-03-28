//
//  ZQCollectionViewZoomFlowLayoutController.swift
//  ZQCollectionViewFlowLayoutDemo
//
//  Created by Darren on 2019/3/27.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import ZQCollectionViewFlowLayout

class ZQCollectionViewZoomFlowLayoutController: UIViewController {

    fileprivate lazy var datasArr:[String] = {
        let datasArr:[String] = [
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10"
        ]
        return datasArr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let horizontalLayout = getLayout(scrollDirection:.horizontal)
        let x:CGFloat = 25
        let horizontalCollectionView:UICollectionView = getCollectionView(frame: CGRect(x: x, y: UIApplication.shared.statusBarFrame.size.height + (navigationController?.navigationBar.frame.size.height)! + 20, width: view.bounds.size.width - 2 * x, height: 180), layout: horizontalLayout)
        view.addSubview(horizontalCollectionView)
        
        let width:CGFloat = 150
        let verticalLayout = getLayout(scrollDirection: .vertical)
        let verticalCollectionView:UICollectionView = getCollectionView(frame: CGRect(x: (view.bounds.size.width - width) * 0.5, y: horizontalCollectionView.frame.maxY + 20, width: width, height: 280), layout: verticalLayout)
        view.addSubview(verticalCollectionView)
    }
}

extension ZQCollectionViewZoomFlowLayoutController {
    fileprivate func getLayout(scrollDirection:UICollectionView.ScrollDirection) -> ZQCollectionViewZoomFlowLayout {
        let layout = ZQCollectionViewZoomFlowLayout()
        layout.maxScale = 1.2
        layout.scrollDirection = scrollDirection
        layout.itemSize = CGSize(width: 100, height: 100)
        return layout
    }
    
    fileprivate func getCollectionView(frame:CGRect, layout:ZQCollectionViewZoomFlowLayout) -> UICollectionView {
        let collectionView:UICollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.blue
        collectionView.register(ZQCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ZQCollectionViewCell.self))
        collectionView.dataSource = self
        return collectionView
    }
}

extension ZQCollectionViewZoomFlowLayoutController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ZQCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ZQCollectionViewCell.self), for: indexPath) as! ZQCollectionViewCell
        cell.title = datasArr[indexPath.row]
        return cell
    }
}
