//
//  ZQCollectionViewEqualSpaceFlowLayout.swift
//  ZQCollectionViewFlowLayout
//
//  Created by Darren on 2019/3/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: 对齐方式
public enum ZQCollectionViewEqualSpaceAlignType:Int {
    case left     = 0      ///< 左对齐
    case center   = 1      ///< 居中对齐
    case right    = 2      ///< 右对齐
}

// MARK: ZQCollectionViewEqualSpaceFlowLayout 等间距对齐布局
public class ZQCollectionViewEqualSpaceFlowLayout: UICollectionViewFlowLayout {

    /// 对齐方式, 默认 .left
    public var alignType:ZQCollectionViewEqualSpaceAlignType = .left
    
    /// 两个cell之间的距离
    public var spaceBetweenCell:CGFloat = 5
    
    /// 布局方向, 默认 .horizontal
    public var layoutDirection:ZQCollectionViewFlowLayoutDirection = .horizontal
    
    /// 前一个布局信息
    fileprivate var previousAttr:UICollectionViewLayoutAttributes?
    
    /// 总宽 = cell宽 + spaceBetweenCell
    fileprivate var totalWidth:CGFloat = 0
    
    /// 当前所在行
    fileprivate var row:Int = 0
    
    /// 当前所在分区
    fileprivate var section:Int = 0
    
    /// 所有cell布局
    fileprivate lazy var layoutAttributesArr:[UICollectionViewLayoutAttributes] = {
        let layoutAttributesArr:[UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
        return layoutAttributesArr
    }()
    
    /// 临时布局信息数组,用于存放每一行或者每一列布局信息
    fileprivate lazy var layoutAttributesTempArr:[UICollectionViewLayoutAttributes] = {
        let layoutAttributesTempArr:[UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
        return layoutAttributesTempArr
    }()
    
    // MARK: override
    public override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }
        reset()
        let sectionNum = collectionView.numberOfSections
        for section in 0..<sectionNum {
            let itemNum = collectionView.numberOfItems(inSection: section)
            for item in 0..<itemNum {
                if let layout = layoutAttributesForItem(at: IndexPath(item: item, section: section)) {
                    layoutAttributesArr.append(layout)
                }
            }
        }
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let currentAttr = super.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        switch layoutDirection {
        case .horizontal:
            
            /// 横向布局
            fixLayoutAttributesToAdjustHorizontalLayout(currentAttr: currentAttr)
            
        case .vertical:
            
            /// 纵向布局
            fixLayoutAttributesToAdjustVerticalLayout(currentAttr: currentAttr)
        }
        previousAttr = currentAttr
        return currentAttr
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributesArr
    }
    
    public override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return CGSize.zero
        }
        
        switch scrollDirection {
        case .horizontal:
            return CGSize(width: collectionView.bounds.size.width * CGFloat(collectionView.numberOfSections), height: collectionView.bounds.size.height)
            
        case .vertical:
            return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height * CGFloat(collectionView.numberOfSections))
            
        default:
            return CGSize.zero
        }
    }
}

// MARK: private
extension ZQCollectionViewEqualSpaceFlowLayout {
    
    /// 重置
    fileprivate func reset() {
        layoutAttributesArr.removeAll()
        totalWidth = 0
        row = 0
        section = 0
        previousAttr = nil
        layoutAttributesTempArr.removeAll()
    }
    
    /// 改变布局,适应 横向布局
    ///
    /// - Parameter currentAttr: 布局信息
    fileprivate func fixLayoutAttributesToAdjustHorizontalLayout(currentAttr:UICollectionViewLayoutAttributes) {
        guard let collectionView = collectionView else {
            return
        }
        let layoutWidth:CGFloat = collectionView.bounds.size.width - sectionInset.left - sectionInset.right
        var currentAttrFrame = currentAttr.frame
        totalWidth += (currentAttrFrame.size.width + spaceBetweenCell)
        
        /// 下一个分区的第一个
        if currentAttr.indexPath.section > section {
            totalWidth -= (currentAttrFrame.size.width + spaceBetweenCell)
            resetCellFrame()
            section = currentAttr.indexPath.section
            row = 0
            totalWidth = currentAttrFrame.size.width + spaceBetweenCell
            
            switch scrollDirection {
                
            /// 横向布局, 横向滚动
            case .horizontal:
                currentAttrFrame.origin.x = sectionInset.left + CGFloat(section) * collectionView.bounds.size.width
                currentAttrFrame.origin.y = sectionInset.top
                
            /// 横向布局, 纵向滚动
            case .vertical:
                currentAttrFrame.origin.x = sectionInset.left
                currentAttrFrame.origin.y = sectionInset.top + CGFloat(section) * collectionView.bounds.size.height
            default:break
            }
            currentAttr.frame = currentAttrFrame
            layoutAttributesTempArr.append(currentAttr)
            return
        }
        
        /// 同一行
        if totalWidth < layoutWidth {
            
            /// 不是第一个
            if let previous = previousAttr {
                currentAttrFrame.origin.x = previous.frame.maxX + spaceBetweenCell
                currentAttrFrame.origin.y = previous.frame.origin.y
                currentAttr.frame = currentAttrFrame
                layoutAttributesTempArr.append(currentAttr)
            }
                
            /// 第一个分区的第一个
            else {
                currentAttrFrame.origin.x = sectionInset.left
                currentAttrFrame.origin.y = sectionInset.top
                currentAttr.frame = currentAttrFrame
                layoutAttributesTempArr.append(currentAttr)
            }
        }
            
        /// 换行
        else {
            totalWidth -= (currentAttrFrame.size.width + spaceBetweenCell)
            resetCellFrame()
            totalWidth = currentAttrFrame.size.width + spaceBetweenCell
            row += 1
            switch scrollDirection {
                
            /// 横向布局, 横向滚动
            case .horizontal:
                currentAttrFrame.origin.x = sectionInset.left + CGFloat(section) * collectionView.bounds.size.width
                currentAttrFrame.origin.y = sectionInset.top + CGFloat(row) * (currentAttrFrame.size.height + spaceBetweenCell)
                
            /// 横向布局, 纵向滚动
            case .vertical:
                currentAttrFrame.origin.x = sectionInset.left
                currentAttrFrame.origin.y = sectionInset.top + CGFloat(row) * (currentAttrFrame.size.height + spaceBetweenCell) + CGFloat(section) * collectionView.bounds.size.height
            default:break
            }

            currentAttr.frame = currentAttrFrame
            layoutAttributesTempArr.append(currentAttr)
        }
        
        /// 最后一行的最后一个,这时layoutAttributesTempArr还有最后一行所有cell的布局信息,需更新这写cell布局信息
        if section == collectionView.numberOfSections - 1 && currentAttr.indexPath.row == collectionView.numberOfItems(inSection: section) - 1 {
            resetCellFrame()
        }
    }
    
    /// 改变布局,适应 纵向布局
    ///
    /// - Parameter currentAttr: 布局信息
    fileprivate func fixLayoutAttributesToAdjustVerticalLayout(currentAttr:UICollectionViewLayoutAttributes) {
        guard let collectionView = collectionView else {
            return
        }
        let layoutHeight:CGFloat = collectionView.bounds.size.height - sectionInset.top - sectionInset.bottom
        var currentAttrFrame = currentAttr.frame
        totalWidth += (currentAttrFrame.size.height + spaceBetweenCell)
        
        /// 下一个分区的第一个
        if currentAttr.indexPath.section > section {
            totalWidth -= (currentAttrFrame.size.height + spaceBetweenCell)
            resetCellFrame()
            section = currentAttr.indexPath.section
            row = 0
            totalWidth = currentAttrFrame.size.height + spaceBetweenCell
            
            switch scrollDirection {
                
            /// 纵向布局, 横向滚动
            case .horizontal:
                currentAttrFrame.origin.x = sectionInset.left + CGFloat(section) * collectionView.bounds.size.width
                currentAttrFrame.origin.y = sectionInset.top
                
            /// 纵向布局, 纵向滚动
            case .vertical:
                currentAttrFrame.origin.x = sectionInset.left
                currentAttrFrame.origin.y = sectionInset.top + CGFloat(section) * collectionView.bounds.size.height
            default:break
            }

            currentAttr.frame = currentAttrFrame
            layoutAttributesTempArr.append(currentAttr)
            return
        }
        
        /// 同一列
        if totalWidth < layoutHeight {
            
            /// 不是第一个
            if let previous = previousAttr {
                currentAttrFrame.origin.x = previous.frame.origin.x
                currentAttrFrame.origin.y = previous.frame.maxY + spaceBetweenCell
                currentAttr.frame = currentAttrFrame
                layoutAttributesTempArr.append(currentAttr)
            }
                
            /// 第一个分区的第一个
            else {
                currentAttrFrame.origin.x = sectionInset.left
                currentAttrFrame.origin.y = sectionInset.top
                currentAttr.frame = currentAttrFrame
                layoutAttributesTempArr.append(currentAttr)
            }
        }
            
        /// 换列
        else {
            totalWidth -= (currentAttrFrame.size.height + spaceBetweenCell)
            resetCellFrame()
            totalWidth = currentAttrFrame.size.height + spaceBetweenCell
            row += 1
            switch scrollDirection {
                
            /// 纵向布局, 横向滚动
            case .horizontal:
                currentAttrFrame.origin.x = sectionInset.left + CGFloat(row) * (currentAttrFrame.size.width + spaceBetweenCell) + CGFloat(section) * collectionView.bounds.size.width
                currentAttrFrame.origin.y = sectionInset.top
                
            /// 纵向布局, 纵向滚动
            case .vertical:
                currentAttrFrame.origin.x = sectionInset.left + CGFloat(row) * (currentAttrFrame.size.width + spaceBetweenCell)
                currentAttrFrame.origin.y = sectionInset.top + CGFloat(section) * collectionView.bounds.size.height
            default:break
            }

            currentAttr.frame = currentAttrFrame
            layoutAttributesTempArr.append(currentAttr)
        }
        
        /// 最后一行的最后一个,这时layoutAttributesTempArr还有最后一行所有cell的布局信息,需更新这写cell布局信息
        if section == collectionView.numberOfSections - 1 && currentAttr.indexPath.row == collectionView.numberOfItems(inSection: section) - 1 {
            resetCellFrame()
        }
    }
    
    /// 重置cell的frame
    fileprivate func resetCellFrame() {
        guard let collectionView = collectionView else {
            return
        }
        var nowWidth:CGFloat = 0
        switch alignType {
            
        case .left:
            
            switch layoutDirection {
            case .horizontal:
                
                nowWidth = sectionInset.left
                for attributes in layoutAttributesTempArr {
                    var nowFrame = attributes.frame
                    
                    switch scrollDirection {
                        
                    /// 左对齐, 横向布局, 横向滚动
                    case .horizontal:
                        nowFrame.origin.x = nowWidth + CGFloat(attributes.indexPath.section) * collectionView.bounds.size.width
                        
                    /// 左对齐, 横向布局, 纵向滚动
                    case .vertical:
                        nowFrame.origin.x = nowWidth
                        
                    default:break
                    }
                    attributes.frame = nowFrame
                    nowWidth += (nowFrame.size.width + spaceBetweenCell)
                }
                
            case .vertical:
                
                nowWidth = sectionInset.top
                for attributes in layoutAttributesTempArr {
                    var nowFrame = attributes.frame
                    
                    switch scrollDirection {
                        
                    /// 左对齐, 纵向布局, 横向滚动
                    case .horizontal:
                        nowFrame.origin.y = nowWidth
                        
                    /// 左对齐, 纵向布局, 纵向滚动
                    case .vertical:
                        nowFrame.origin.y = nowWidth + CGFloat(attributes.indexPath.section) * collectionView.bounds.size.height
                        
                    default:break
                    }
                    attributes.frame = nowFrame
                    nowWidth += (nowFrame.size.height + spaceBetweenCell)
                }
            }

        case .center:
            
            switch layoutDirection {
            case .horizontal:
                nowWidth = (collectionView.frame.size.width - totalWidth) / 2
                for attributes in layoutAttributesTempArr {
                    var nowFrame = attributes.frame
                    
                    switch scrollDirection {
                        
                    /// 居中对齐, 横向布局, 横向滚动
                    case .horizontal:
                        nowFrame.origin.x = nowWidth + CGFloat(attributes.indexPath.section) * collectionView.bounds.size.width
                        
                    /// 居中对齐, 横向布局, 纵向滚动
                    case .vertical:
                        nowFrame.origin.x = nowWidth
                        
                    default:break
                    }
                    attributes.frame = nowFrame
                    nowWidth += (nowFrame.size.width + spaceBetweenCell)
                }
                
            case .vertical:
                nowWidth = (collectionView.frame.size.height - totalWidth) / 2
                for attributes in layoutAttributesTempArr {
                    var nowFrame = attributes.frame
                    switch scrollDirection {
                        
                    /// 居中对齐, 纵向布局, 横向滚动
                    case .horizontal:
                        nowFrame.origin.x = sectionInset.left + CGFloat(row) * (attributes.frame.width + spaceBetweenCell) + CGFloat(attributes.indexPath.section) * collectionView.bounds.size.width
                        nowFrame.origin.y = nowWidth
                        
                    /// 居中对齐, 纵向布局, 纵向滚动
                    case .vertical:
                        nowFrame.origin.x = sectionInset.left + CGFloat(row) * (attributes.frame.width + spaceBetweenCell)
                        nowFrame.origin.y = nowWidth + CGFloat(attributes.indexPath.section) * collectionView.bounds.size.height
                    default:break
                    }
                    attributes.frame = nowFrame
                    nowWidth += (nowFrame.size.height + spaceBetweenCell)
                }
            }
            
        case .right:
            
            switch layoutDirection {
            case .horizontal:
                nowWidth = collectionView.frame.size.width - sectionInset.right
                for var index in 0..<layoutAttributesTempArr.count {
                    index = layoutAttributesTempArr.count - 1 - index
                    let attributes = layoutAttributesTempArr[index]
                    var nowFrame = attributes.frame
                    
                    switch scrollDirection {
                        
                    /// 右对齐, 横向布局, 横向滚动
                    case .horizontal:
                        nowFrame.origin.x = nowWidth + CGFloat(attributes.indexPath.section) * collectionView.bounds.size.width - nowFrame.size.width
                        
                    /// 右对齐, 横向布局, 纵向滚动
                    case .vertical:
                        nowFrame.origin.x = nowWidth - nowFrame.size.width
                        
                    default:break
                    }
                    attributes.frame = nowFrame
                    nowWidth -= (nowFrame.size.width + spaceBetweenCell)
                }
                
            case .vertical:
                nowWidth = sectionInset.top
                let nowX = collectionView.bounds.size.width - sectionInset.right - CGFloat(row) * spaceBetweenCell
                for index:Int in 0..<layoutAttributesTempArr.count {
                    let attributes = layoutAttributesTempArr[index]
                    var nowFrame = attributes.frame
                    
                    switch scrollDirection {
                        
                    /// 右对齐, 纵向布局, 横向滚动
                    case .horizontal:
                        nowFrame.origin.x = nowX - CGFloat(row + 1) * attributes.frame.width + CGFloat(attributes.indexPath.section) * collectionView.bounds.size.width
                        nowFrame.origin.y = nowWidth
                        
                    /// 右对齐, 纵向布局, 纵向滚动
                    case .vertical:
                        nowFrame.origin.x = nowX - CGFloat(row + 1) * attributes.frame.width
                        nowFrame.origin.y = nowWidth + CGFloat(attributes.indexPath.section) * collectionView.bounds.size.height
                        
                    default:break
                    }
                    attributes.frame = nowFrame
                    nowWidth += (nowFrame.size.height + spaceBetweenCell)
                }
            }
        }
        layoutAttributesTempArr.removeAll()
    }
}
