//
//  ZQCollectionViewEqualSpaceFlowLayoutShowController.swift
//  ZQCollectionViewFlowLayoutDemo
//
//  Created by Darren on 2019/4/2.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

import UIKit
import ZQCollectionViewFlowLayout

class ZQCollectionViewEqualSpaceFlowLayoutShowController: UIViewController {
    
    var layout:ZQCollectionViewEqualSpaceFlowLayout?
    
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
    
    fileprivate let defaultButtonTag = 10000
    
    fileprivate var collectionView:UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        guard let layout = layout else {
            return
        }
        layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        layout.alignType = .center
        layout.itemSize = CGSize(width: 60, height: 30)
        
        let x:CGFloat = 30
        collectionView = UICollectionView(frame: CGRect(x: x, y: UIApplication.shared.statusBarFrame.size.height + (navigationController?.navigationBar.frame.size.height)! + 10, width: view.bounds.size.width - 2 * x, height: 220), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.blue
        collectionView.register(ZQCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ZQCollectionViewCell.self))
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        let buttonWidth:CGFloat = 60
        let buttonHeight:CGFloat = 30
        let buttonGap:CGFloat = 30
        let centerButton = getButton(frame: CGRect(x: (view.bounds.size.width - buttonWidth) * 0.5, y: collectionView.frame.maxY + 50, width: buttonWidth, height: buttonHeight), tag: defaultButtonTag + ZQCollectionViewEqualSpaceAlignType.center.rawValue)
        view.addSubview(centerButton)
        
        let leftButton = getButton(frame: CGRect(x: centerButton.frame.minX - buttonGap - buttonWidth, y: centerButton.frame.minY, width: buttonWidth, height: buttonHeight), tag: defaultButtonTag + ZQCollectionViewEqualSpaceAlignType.left.rawValue)
        view.addSubview(leftButton)
        
        let rightButton = getButton(frame: CGRect(x: centerButton.frame.maxX + buttonGap, y: centerButton.frame.minY, width: buttonWidth, height: buttonHeight), tag: defaultButtonTag + ZQCollectionViewEqualSpaceAlignType.right.rawValue)
        view.addSubview(rightButton)
    }
}

extension ZQCollectionViewEqualSpaceFlowLayoutShowController {
    fileprivate func getButton(frame:CGRect, tag:Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.frame = frame
        button.backgroundColor = UIColor.blue
        var title = ""
        switch ZQCollectionViewEqualSpaceAlignType(rawValue: tag - defaultButtonTag)! {
        case .left:
            title = "left"
            
        case .right:
            title = "right"
            
        case .center:
            title = "center"
        }
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.tag = tag
        button.addTarget(self, action: #selector(actionForButton(sender:)), for: .touchUpInside)
        return button
    }
}

extension ZQCollectionViewEqualSpaceFlowLayoutShowController {
    @objc fileprivate func actionForButton(sender:UIButton) {
        guard let layout = layout, let alignType = ZQCollectionViewEqualSpaceAlignType(rawValue: sender.tag - defaultButtonTag) else {
            return
        }
        layout.alignType = alignType
        collectionView.reloadData()
    }
}

extension ZQCollectionViewEqualSpaceFlowLayoutShowController : UICollectionViewDataSource {
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
}
