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
    
    /// 内容缩进, 默认 .zero
    /// 注: 如果设置了该属性,则 minimumLineSpacing 和 minimumInteritemSpacing设置无效,因为在布局计算时,会根据 rowNum colNum itemSize contentInsets 自动算出item之间的间隔
    public var contentInsets:UIEdgeInsets = .zero
    
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
            columHeightsArr.append(contentInsets.top)
        }
        
        /// 清除布局
        layoutAttributesArr.removeAll()
        let itemNum = collectionView.numberOfItems(inSection: 0)
        
        switch scrollDirection {
        case .horizontal:
            
            for i:Int in 0..<itemNum {
                
                if let layout = layoutAttributesForItem(at: IndexPath(item: i, section: 0)) {
                    
                    /// 找到最短列的下标
                    let shortestIndex:NSInteger = indexOfShortestColum()
                    
                    /// 计算Y 目标Y = 内边距上间距 + (高 + item间距) * 最短列下标
                    let detalY:CGFloat = contentInsets.top + CGFloat(shortestIndex) * (itemSize.height + rowMargin)
                    
                    /// 找到最短列的高度
                    let height:CGFloat = columHeightsArr[shortestIndex]
                    
                    /// 计算X
                    let detalX:CGFloat = height + colMargin
                    
                    /// 创建indexPath
                    let indexPath = IndexPath(item: i, section: 0)
                    
                    /// 调用代理方法计算高度
                    let itemWidth:CGFloat = delegate?.heightForItem(indexPath: indexPath) ?? 0
                    
                    /// 生成frame
                    layout.frame = CGRect(x: detalX, y: detalY, width: itemWidth, height: itemSize.height)
                    
                    /// 将位置信息添加到数组中
                    layoutAttributesArr.append(layout)
                    
                    /// 更新这一行的高度
                    columHeightsArr[shortestIndex] = (detalX + itemWidth)
                }
            }
            
        case .vertical:
            
            for i:Int in 0..<itemNum {
                
                if let layout = layoutAttributesForItem(at: IndexPath(item: i, section: 0)) {
                    
                    /// 找到最短列的下标
                    let shortestIndex:NSInteger = indexOfShortestColum()
                    
                    /// 计算X 目标X = 内边距左间距 + (宽 + item间距) * 最短列下标
                    let detalX:CGFloat = contentInsets.left + CGFloat(shortestIndex) * (itemSize.width + colMargin)
                    
                    /// 找到最短列的高度
                    let height:CGFloat = columHeightsArr[shortestIndex]
                    
                    /// 计算Y
                    let detalY:CGFloat = height + rowMargin
                    
                    /// 创建indexPath
                    let indexPath = IndexPath(item: i, section: 0)
                    
                    /// 调用代理方法计算高度
                    let itemHeight:CGFloat = delegate?.heightForItem(indexPath: indexPath) ?? 0
                    
                    /// 生成frame
                    layout.frame = CGRect(x: detalX, y: detalY, width: itemSize.width, height: itemHeight)
                    
                    /// 将位置信息添加到数组中
                    layoutAttributesArr.append(layout)
                    
                    /// 更新这一列的高度
                    columHeightsArr[shortestIndex] = (detalY + itemHeight)
                }
            }
            
        default:break
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
            size.width = height + contentInsets.right

        case .vertical:
            size.height = height + contentInsets.bottom

        default:break
        }
        return size
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributesArr
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
