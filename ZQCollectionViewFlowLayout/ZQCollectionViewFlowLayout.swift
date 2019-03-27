//
//  ZQCollectionViewFlowLayout.swift
//  ZQCollectionViewFlowLayout
//
//  Created by Darren on 2019/3/27.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: 布局方向
public enum ZQCollectionViewFlowLayoutDirection: Int {
    case horizontal    = 0     ///< 水平方向, 即item从左向右排列
    case vertical      = 1     ///< 垂直方向, 即item从上到下排列
}

// MARK: ZQCollectionViewFlowLayout
public class ZQCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    /// 行数, 默认 0
    public var rowNum:Int = 0
    
    /// 列数, 默认 0
    public var colNum:Int = 0
    
    /// 内容缩进, 默认 .zero
    public var contentInsets:UIEdgeInsets = .zero
    
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
                let layoutAttributes = layoutAttributesForItem(at: IndexPath(item: item, section: section))
                if let layout = layoutAttributes {
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
        guard let collectionView = collectionView else {
            return nil
        }
        let layoutAttribute = super.layoutAttributesForItem(at: indexPath)
        
        /// 数据源超过分区规定的数量,则不显示该数据
        if indexPath.row >= rowNum * colNum {
            layoutAttribute?.frame = CGRect.zero
            return layoutAttribute
        }
        
        let width:CGFloat = collectionView.bounds.size.width
        let height:CGFloat = collectionView.bounds.size.height
        
        let itemWidth:CGFloat = itemSize.width
        let itemHeight:CGFloat = itemSize.height
        
        let top:CGFloat = contentInsets.top
        let left:CGFloat = contentInsets.left
        let bottom:CGFloat = contentInsets.bottom
        let right:CGFloat = contentInsets.right
        
        let section:Int = indexPath.section
        let row:Int = indexPath.row
        
        assert((width - left - right) >= (itemWidth * CGFloat(rowNum)))
        assert((height - top - bottom) >= (itemHeight * CGFloat(colNum)))
        
        /// 计算水平距离
        let spaceHor:CGFloat = (width - CGFloat(rowNum) * itemWidth - left - right) / CGFloat(rowNum - 1)
        
        /// 计算垂直距离
        let spaceVer:CGFloat = (height - CGFloat(colNum) * itemHeight - top - bottom) / CGFloat(colNum - 1)
        
        var x:CGFloat = 0
        var y:CGFloat = 0
        
        switch layoutDirection {
        case .horizontal:
            x = CGFloat(section) * width + CGFloat(row % rowNum) * itemWidth + left
            x += (spaceHor * CGFloat(row % rowNum))
            
            y = CGFloat(row / rowNum) * itemHeight + top
            y += (spaceVer * CGFloat(row / rowNum))
            
        case .vertical:
            x = CGFloat(section) * width + CGFloat(row / colNum) * itemWidth + left
            x += (spaceHor * CGFloat(row / colNum))
            
            y = CGFloat(row % colNum) * itemHeight + top
            y += (spaceVer * CGFloat(row % colNum))
        }
        layoutAttribute?.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
        return layoutAttribute
    }
    
    public override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.size.width * CGFloat(collectionView.numberOfSections), height: collectionView.bounds.size.height)
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
