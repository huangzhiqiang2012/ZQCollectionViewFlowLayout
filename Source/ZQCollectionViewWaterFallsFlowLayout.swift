//
//  ZQCollectionViewWaterFallsFlowLayout.swift
//  ZQCollectionViewFlowLayout
//
//  Created by Darren on 2019/3/28.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: 协议
public protocol ZQCollectionViewWaterFallsFlowLayoutDelegate:AnyObject {
    func heightForItem(indexPath:IndexPath) -> CGFloat
}

// MARK: ZQCollectionViewWaterFallsFlowLayout 不规则瀑布流布局
public class ZQCollectionViewWaterFallsFlowLayout: UICollectionViewFlowLayout {
    
    /// 行数, 默认 0, layoutDirection = .horizontal 时设置才有效
    public var rowNum:Int = 0
    
    /// 列数, 默认 0, layoutDirection = .vertical 时设置才有效
    public var colNum:Int = 0
    
    /// 行间距, 默认 0
    public var rowMargin:CGFloat = 0
    
    /// 列间距, 默认 0
    public var colMargin:CGFloat = 0
    
    /// 代理
    public weak var delegate:ZQCollectionViewWaterFallsFlowLayoutDelegate?
    
    /// 所有cell布局
    fileprivate lazy var layoutAttributesArr:[UICollectionViewLayoutAttributes] = {
        let layoutAttributesArr:[UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
        return layoutAttributesArr
    }()
    
    /// 所有列高度
    fileprivate lazy var columHeightsArr:[CGFloat] = {
        let columHeightsArr:[CGFloat] = [CGFloat]()
        return columHeightsArr
    }()

    // MARK: override
    public override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }
        
        /// 清除高度
        columHeightsArr.removeAll()
        
        /// 每一列添加一个top高度
        for _:Int in 0..<colNum {
            columHeightsArr.append(sectionInset.top)
        }
        
        /// 清除布局
        layoutAttributesArr.removeAll()
        let itemNum = collectionView.numberOfItems(inSection: 0)
        for i:Int in 0..<itemNum {
            if let layout = layoutAttributesForItem(at: IndexPath(item: i, section: 0)) {
                layoutAttributesArr.append(layout)
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
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttribute = super.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        switch scrollDirection {
        case .horizontal:
            
            /// 找到最短列的下标
            let shortestIndex:NSInteger = indexOfShortestColum()
            
            /// 计算Y 目标Y = 内边距上间距 + (高 + item间距) * 最短列下标
            let detalY:CGFloat = sectionInset.top + CGFloat(shortestIndex) * (itemSize.height + rowMargin)
            
            /// 找到最短列的高度
            let height:CGFloat = columHeightsArr[shortestIndex]
            
            /// 计算X
            let detalX:CGFloat = height + colMargin
            
            /// 调用代理方法计算高度
            let itemWidth:CGFloat = delegate?.heightForItem(indexPath: indexPath) ?? 0
            
            /// 生成frame
            layoutAttribute.frame = CGRect(x: detalX, y: detalY, width: itemWidth, height: itemSize.height)
            
            /// 更新这一行的高度
            columHeightsArr[shortestIndex] = (detalX + itemWidth)
            
        case .vertical:
            
            /// 找到最短列的下标
            let shortestIndex:NSInteger = indexOfShortestColum()
            
            /// 计算X 目标X = 内边距左间距 + (宽 + item间距) * 最短列下标
            let detalX:CGFloat = sectionInset.left + CGFloat(shortestIndex) * (itemSize.width + colMargin)
            
            /// 找到最短列的高度
            let height:CGFloat = columHeightsArr[shortestIndex]
            
            /// 计算Y
            let detalY:CGFloat = height + rowMargin
            
            /// 调用代理方法计算高度
            let itemHeight:CGFloat = delegate?.heightForItem(indexPath: indexPath) ?? 0
            
            /// 生成frame
            layoutAttribute.frame = CGRect(x: detalX, y: detalY, width: itemSize.width, height: itemHeight)
            
            /// 更新这一列的高度
            columHeightsArr[shortestIndex] = (detalY + itemHeight)
            
        default:break
        }
        return layoutAttribute
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributesArr
    }
    
    public override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return CGSize.zero
        }
        
        /// 最高列的下标
        let index:NSInteger = indexOfHeightestColum()
        
        /// 最高列的高度
        let height:CGFloat = columHeightsArr[index]
        
        /// 拿到collectionView的原始大小
        var size = collectionView.frame.size
        
        switch scrollDirection {
        case .horizontal:
            size.width = height + sectionInset.right

        case .vertical:
            size.height = height + sectionInset.bottom

        default:break
        }
        return size
    }
}

extension ZQCollectionViewWaterFallsFlowLayout {
    /**
     当前最短列
     */
    fileprivate func indexOfShortestColum() -> NSInteger {
        var index:NSInteger = 0
        var length:CGFloat = CGFloat(MAXFLOAT)
        for i:NSInteger in 0..<columHeightsArr.count {
            let height:CGFloat = columHeightsArr[i]
            if height < length {
                length = height
                index = i
            }
        }
        return index
    }
    
    /**
     当前最长列
     */
    fileprivate func indexOfHeightestColum() -> NSInteger {
        var index:NSInteger = 0
        var length:CGFloat = 0
        for i:NSInteger in 0..<columHeightsArr.count {
            let height:CGFloat = columHeightsArr[i]
            if height > length {
                length = height
                index = i
            }
        }
        return index
    }
}
