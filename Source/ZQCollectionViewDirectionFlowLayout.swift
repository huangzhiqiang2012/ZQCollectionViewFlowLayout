//
//  ZQCollectionViewDirectionFlowLayout.swift
//  ZQCollectionViewFlowDirectionLayout
//
//  Created by Darren on 2019/3/27.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: ZQCollectionViewFlowLayoutDirection 布局方向
public enum ZQCollectionViewFlowLayoutDirection: Int {
    
    /// 水平方向, 即item从左向右排列
    case horizontal    = 0
    
    /// 垂直方向, 即item从上到下排列
    case vertical      = 1
}

// MARK: ZQCollectionViewDirectionFlowLayout 方向布局
public class ZQCollectionViewDirectionFlowLayout: UICollectionViewFlowLayout {
    
    /// 行数, 默认 0
    public var rowNum:Int = 0
    
    /// 列数, 默认 0
    public var colNum:Int = 0
    
    /// 布局方向, 默认 .horizontal
    public var layoutDirection:ZQCollectionViewFlowLayoutDirection = .horizontal
    
    /// 所有cell布局
    fileprivate lazy var layoutAttributesArr:[UICollectionViewLayoutAttributes] = {
        let layoutAttributesArr:[UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
        return layoutAttributesArr
    }()
    
    // MARK: override
    public override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }
        layoutAttributesArr.removeAll()
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
    
    /**
     返回true只要显示的边界发生改变就重新布局:(默认是false)
     内部会重新调用prepareLayout和调用
     layoutAttributesForElementsInRect方法获得部分cell的布局属性
     */
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    /**
     根据indexPath去对应的UICollectionViewLayoutAttributes
     这个是取值的，要重写，在移动删除的时候系统会调用该方法重新去UICollectionViewLayoutAttributes然后布局
     */
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView, let layoutAttribute = super.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        
        /// 数据源超过分区规定的数量,则不显示该数据
        if indexPath.row >= rowNum * colNum {
            layoutAttribute.frame = CGRect.zero
            return layoutAttribute
        }
        
        let width:CGFloat = collectionView.bounds.size.width
        let height:CGFloat = collectionView.bounds.size.height
        
        let itemWidth:CGFloat = itemSize.width
        let itemHeight:CGFloat = itemSize.height
        
        let top:CGFloat = sectionInset.top
        let left:CGFloat = sectionInset.left
        let bottom:CGFloat = sectionInset.bottom
        let right:CGFloat = sectionInset.right
        
        let section:Int = indexPath.section
        let row:Int = indexPath.row
        
        assert((width - left - right) >= (itemWidth * CGFloat(colNum)))
        assert((height - top - bottom) >= (itemHeight * CGFloat(rowNum)))
        
        /// 计算水平距离
        var spaceHor:CGFloat = 0
        if colNum > 1 {
            spaceHor = (width - CGFloat(colNum) * itemWidth - left - right) / CGFloat(colNum - 1)
        }
        
        /// 计算垂直距离
        var spaceVer:CGFloat = 0
        if rowNum > 1 {
            spaceVer = (height - CGFloat(rowNum) * itemHeight - top - bottom) / CGFloat(rowNum - 1)
        }
        
        var x:CGFloat = 0
        var y:CGFloat = 0
        
        switch layoutDirection {
        case .horizontal:
            switch scrollDirection {
            
            /// 横向布局,横向滚动
            case .horizontal:
                x = CGFloat(section) * width + CGFloat(row % colNum) * itemWidth + left
                x += (spaceHor * CGFloat(row % colNum))
                
                y = CGFloat(row / colNum) * itemHeight + top
                y += (spaceVer * CGFloat(row / colNum))
                
            /// 横向布局, 纵向滚动
            case .vertical:
                x = CGFloat(row % colNum) * itemWidth + left
                x += (spaceHor * CGFloat(row % colNum))
                
                y = CGFloat(section) * height + CGFloat(row / colNum) * itemHeight + top
                y += (spaceVer * CGFloat(row / colNum))
                
            default:break
            }
            
        case .vertical:
            switch scrollDirection {
            
            /// 纵向布局,横向滚动
            case .horizontal:
                x = CGFloat(section) * width + CGFloat(row / rowNum) * itemWidth + left
                x += (spaceHor * CGFloat(row / rowNum))
                
                y = CGFloat(row % rowNum) * itemHeight + top
                y += (spaceVer * CGFloat(row % rowNum))
                
            /// 纵向布局,纵向滚动
            case .vertical:
                x = CGFloat(row / rowNum) * itemWidth + left
                x += (spaceHor * CGFloat(row / rowNum))
                
                y = CGFloat(section) * height + CGFloat(row % rowNum) * itemHeight + top
                y += (spaceVer * CGFloat(row % rowNum))
            default:break
            }
        }
        layoutAttribute.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
        return layoutAttribute
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
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributesArr
    }
}

// MARK: UICollectionViewFlowLayout + Extension
extension UICollectionViewFlowLayout {
    
    /// 解决RTL语言布局下(比如阿语环境),UICollection滚动异常的问题
    open override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return true
    }
}
