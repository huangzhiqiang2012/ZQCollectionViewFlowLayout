//
//  ZQCollectionViewWaterFallsFlowLayoutController.swift
//  ZQCollectionViewFlowLayoutDemo
//
//  Created by Darren on 2019/3/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit
import ZQCollectionViewFlowLayout

class ZQCollectionViewWaterFallsFlowLayoutController: UIViewController {

    fileprivate lazy var datasArr:[String] = {
        var datasArr:[String] = [String]()
        for i:Int in 0..<50 {
            datasArr.append(i.description)
        }
        return datasArr
    }()
    
    fileprivate lazy var itemHeightsArr:[CGFloat] = {
        var itemHeightsArr:[CGFloat] = [CGFloat]()
        for _:Int in 0..<50 {
            itemHeightsArr.append(CGFloat(arc4random() % (120 - 10 + 1)))
        }
        return itemHeightsArr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let horizontalLayout = getLayout(scrollDirection: .horizontal)
        horizontalLayout.delegate = self
        let x:CGFloat = 25
        let horizontalCollectionView:UICollectionView = getCollectionView(frame: CGRect(x: x, y: UIApplication.shared.statusBarFrame.size.height + (navigationController?.navigationBar.frame.size.height)! + 20, width: view.bounds.size.width - 2 * x, height: 210), layout: horizontalLayout)
        view.addSubview(horizontalCollectionView)
        let horizontalLabel = getLabel(frame: CGRect(x: horizontalCollectionView.frame.origin.x, y: horizontalCollectionView.frame.maxY + 10, width: horizontalCollectionView.bounds.size.width, height: 30), title: "horizontalLayout")
        view.addSubview(horizontalLabel)
        
        let width:CGFloat = 200
        let verticalLayout = getLayout(scrollDirection: .vertical)
        verticalLayout.delegate = self
        let verticalCollectionView:UICollectionView = getCollectionView(frame: CGRect(x: (view.bounds.size.width - width) * 0.5, y: horizontalCollectionView.frame.maxY + 50, width: width, height: 280), layout: verticalLayout)
        view.addSubview(verticalCollectionView)
        let verticalLabel = getLabel(frame: CGRect(x: verticalCollectionView.frame.origin.x, y: verticalCollectionView.frame.maxY + 10, width: width, height: 30), title: "verticalLayout")
        view.addSubview(verticalLabel)
    }
}

extension ZQCollectionViewWaterFallsFlowLayoutController {
    fileprivate func getLayout(scrollDirection:UICollectionView.ScrollDirection) -> ZQCollectionViewWaterFallsFlowLayout {
        let layout = ZQCollectionViewWaterFallsFlowLayout()
        layout.colNum = 3
        layout.colMargin = 5
        layout.rowMargin = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        layout.scrollDirection = scrollDirection
        layout.itemSize = CGSize(width: 60, height: 60)
        return layout
    }
    
    fileprivate func getCollectionView(frame:CGRect, layout:ZQCollectionViewWaterFallsFlowLayout) -> UICollectionView {
        let collectionView:UICollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.blue
        collectionView.register(ZQCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ZQCollectionViewCell.self))
        collectionView.dataSource = self
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

extension ZQCollectionViewWaterFallsFlowLayoutController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ZQCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ZQCollectionViewCell.self), for: indexPath) as! ZQCollectionViewCell
        cell.title = datasArr[indexPath.row]
        return cell
    }
}

extension ZQCollectionViewWaterFallsFlowLayoutController : ZQCollectionViewWaterFallsFlowLayoutDelegate {
    func heightForItem(indexPath: IndexPath) -> CGFloat {
        return itemHeightsArr[indexPath.row]
    }
}
