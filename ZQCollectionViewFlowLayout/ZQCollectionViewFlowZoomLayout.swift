//
//  ZQCollectionViewFlowZoomLayout.swift
//  ZQCollectionViewFlowLayout
//
//  Created by Darren on 2019/3/27.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: ZQCollectionViewFlowZoomLayout 缩放布局
public class ZQCollectionViewFlowZoomLayout: UICollectionViewFlowLayout {
    
    /// 最大比例, 默认 1.2
    public var maxScale:CGFloat = 1.2
    
    /// 布局方向, 默认 .horizontal
    public var layoutDirection:ZQCollectionViewFlowLayoutDirection = .horizontal
    
    // MARK: override
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView, let attrsArr = super.layoutAttributesForElements(in: rect) else {
            return super.layoutAttributesForElements(in: rect)
        }

        switch layoutDirection {
        case .horizontal:
            
            /// 计算出collectionView的中心的位置
            let centerX = collectionView.contentOffset.x + collectionView.frame.size.width * 0.5
            
            /**
             * 1.一个cell对应一个UICollectionViewLayoutAttributes对象
             * 2.UICollectionViewLayoutAttributes对象决定了cell的frame
             */
            for attributes:UICollectionViewLayoutAttributes in attrsArr {
                
                /// cell的中心点距离collectionView的中心点的距离，注意ABS()表示绝对值
                let delta = abs(attributes.center.x - centerX)
                
                /// 设置缩放比例
                let scale = maxScale - delta / collectionView.frame.size.width
                
                /// 设置cell滚动时候缩放的比例
                attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            
        case .vertical:
            
            /// 计算出collectionView的中心的位置
            let centerY = collectionView.contentOffset.y + collectionView.frame.size.height * 0.5
            
            /**
             * 1.一个cell对应一个UICollectionViewLayoutAttributes对象
             * 2.UICollectionViewLayoutAttributes对象决定了cell的frame
             */
            for attributes:UICollectionViewLayoutAttributes in attrsArr {
                
                /// cell的中心点距离collectionView的中心点的距离，注意ABS()表示绝对值
                let delta = abs(attributes.center.y - centerY)
                
                /// 设置缩放比例
                let scale = maxScale - delta / collectionView.frame.size.height
                
                /// 设置cell滚动时候缩放的比例
                attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
        return attrsArr
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
     * 用户手指一松开就会调用
     * 这个方法的返回值，就决定了collectionView停止滚动时的偏移量
     */
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return CGPoint.zero
        }
        
        /// 最终偏移量
        var targetPoint = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        
        switch layoutDirection {
        case .horizontal:
            
            /// 计算出最终显示的矩形框
            let rect = CGRect(x: targetPoint.x, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
            
            /// 获得super已经计算好的布局的属性
            guard let attrsArr = super.layoutAttributesForElements(in: rect) else {
                return CGPoint.zero
            }
            
            /// 计算collectionView最中心点的x值
            let centerX = targetPoint.x + collectionView.frame.size.width * 0.5
            
            /// 获取最小间距
            var minDelta:CGFloat = CGFloat(MAXFLOAT)
            for attributes:UICollectionViewLayoutAttributes in attrsArr {
                let result:CGFloat = attributes.center.x - centerX
                if abs(CGFloat(minDelta)) > abs(result) {
                    minDelta = result
                }
            }
            
            /// 移动间距
            targetPoint.x += minDelta
            
            if targetPoint.x < 0 {
                targetPoint.x = 0
            }
            
        case .vertical:
            
            /// 计算出最终显示的矩形框
            let rect = CGRect(x: 0, y: targetPoint.y, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
            
            /// 获得super已经计算好的布局的属性
            guard let attrsArr = super.layoutAttributesForElements(in: rect) else {
                return CGPoint.zero
            }
            
            /// 计算collectionView最中心点的y值
            let centerY = targetPoint.y + collectionView.frame.size.height * 0.5
            
            /// 获取最小间距
            var minDelta:CGFloat = CGFloat(MAXFLOAT)
            for attributes:UICollectionViewLayoutAttributes in attrsArr {
                let result:CGFloat = attributes.center.y - centerY
                if abs(CGFloat(minDelta)) > abs(result) {
                    minDelta = result
                }
            }
            
            /// 移动间距
            targetPoint.y += minDelta
            
            if targetPoint.y < 0 {
                targetPoint.y = 0
            }
        }
        return targetPoint
    }
}
