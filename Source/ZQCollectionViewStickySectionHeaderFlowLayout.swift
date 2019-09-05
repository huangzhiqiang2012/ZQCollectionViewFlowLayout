//
//  ZQCollectionViewStickySectionHeaderFlowLayout.swift
//  ZQCollectionViewFlowLayout
//
//  Created by Darren on 2019/9/5.
//  Copyright © 2019 Darren. All rights reserved.
//

import UIKit

// MARK: ZQCollectionViewStickySectionHeaderFlowLayout 分区头吸附
public class ZQCollectionViewStickySectionHeaderFlowLayout: UICollectionViewFlowLayout {
    
    /// 返回指定区域的cell布局对象
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard var superLayoutAttributesArr = super.layoutAttributesForElements(in: rect) else { return nil }
        
        /// 创建存索引的数组，无符号（正整数），无序（不能通过下标取值），不可重复（重复的话会自动过滤）
        let noneHeaderSections:NSMutableIndexSet = NSMutableIndexSet()
        
        /// 遍历superLayoutAttributesArr，得到一个当前屏幕中所有的section数组
        superLayoutAttributesArr.forEach({ (attributes) in
            
            /// 如果当前的元素分类是一个cell，将cell所在的分区section加入数组，重复的话会自动过滤
            if attributes.representedElementCategory == .cell {
                noneHeaderSections.add(attributes.indexPath.section)
            }
        })
        
        /// 遍历superArray，将当前屏幕中拥有的header的section从数组中移除，得到一个当前屏幕中没有header的section数组
        /// 正常情况下，随着手指往上移，header脱离屏幕会被系统回收而cell尚在，也会触发该方法
        superLayoutAttributesArr.forEach({ (attributes) in

            /// 如果当前的元素是一个header，将header所在的section从数组中移除
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                noneHeaderSections.remove(attributes.indexPath.section)
            }
        })
        
        /// 遍历当前屏幕中没有header的section数组
        for section in noneHeaderSections {
            
            /// 取到当前section中第一个item的indexPath
            let indexPath:IndexPath = IndexPath(item: 0, section: section)
            
            /// 获取当前section在正常情况下已经离开屏幕的header结构信息
            /// 如果当前分区确实有因为离开屏幕而被系统回收的header,将该header结构信息重新加入到superLayoutAttributesArr中去
            if let attributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
                superLayoutAttributesArr.append(attributes)
            }
        }
        
        /// 遍历superLayoutAttributesArr，改变header结构信息中的参数，使它可以在当前section还没完全离开屏幕的时候一直显示
        for attributes:UICollectionViewLayoutAttributes in superLayoutAttributesArr {
            if attributes.representedElementKind != UICollectionView.elementKindSectionHeader { continue }
            changeSectionHeaderAttributes(attributes: attributes)
        }
        return superLayoutAttributesArr
    }
    
    /// 表示一旦滑动就实时调用上面这个layoutAttributesForElements:方法
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

// MARK: private
extension ZQCollectionViewStickySectionHeaderFlowLayout {
    
    /// 调整分区头布局信息
    ///
    /// - Parameter attributes: 布局信息
    private func changeSectionHeaderAttributes(attributes:UICollectionViewLayoutAttributes) {
        guard let collectionView = collectionView else { return }
        let section:Int = attributes.indexPath.section
        
        /// 得到当前header所在分区的cell的数量
        let numberOfItemsInSection:Int = collectionView.numberOfItems(inSection: section)
        
        /// 得到第一个item的indexPath
        let firstItemIndexPath:IndexPath = IndexPath(item: 0, section: section)
        
        /// 得到最后一个item的indexPath
        let lastItemIndexPath:IndexPath = IndexPath(item: max(0, numberOfItemsInSection - 1), section: section)
        
        /// 得到第一个item和最后一个item的结构信息
        var firstItemAttributes:UICollectionViewLayoutAttributes?, lastItemAttributes:UICollectionViewLayoutAttributes?
        
        var frame = attributes.frame
        let sectionTopInset:CGFloat = sectionInset.top
        let sectionBottomInset:CGFloat = sectionInset.bottom
        
        /// cell有值，则获取第一个cell和最后一个cell的结构信息
        if numberOfItemsInSection > 0 {
            firstItemAttributes = layoutAttributesForItem(at: firstItemIndexPath)
            lastItemAttributes = layoutAttributesForItem(at: lastItemIndexPath)
        }
            
        else {
            
            /// cell没值,就新建一个UICollectionViewLayoutAttributes
            let newAttributes = UICollectionViewLayoutAttributes()
            
            /// 然后模拟出在当前分区中的唯一一个cell，cell在header的下面，高度为0，还与header隔着可能存在的sectionInset的top
            let y:CGFloat = frame.maxY + sectionTopInset
            newAttributes.frame = CGRect(x: 0, y: y, width: 0, height: 0)
            firstItemAttributes = newAttributes
            
            /// 因为只有一个cell，所以最后一个cell等于第一个cell
            lastItemAttributes = firstItemAttributes
        }
        
        guard let firstAttributes = firstItemAttributes, let lastAttributes = lastItemAttributes else { return }
        
        /// 当前的滑动距离
        let offset:CGFloat = collectionView.contentOffset.y
        
        /// 第一个cell的y值 - 当前header的高度 - 可能存在的sectionInset的top
        let headerY:CGFloat = firstAttributes.frame.origin.y - frame.size.height - sectionTopInset
        
        /// 哪个大取哪个，保证header悬停
        /// 针对当前header基本上都是offset更加大，针对下一个header则会是headerY大，各自处理
        let maxY:CGFloat = max(offset, headerY)
        
        /// 最后一个cell的y值 + 最后一个cell的高度 + 可能存在的sectionInset的bottom - 当前header的高度
        /// 当当前section的footer或者下一个section的header接触到当前header的底部，计算出的headerMissingY即为有效值
        let headerMissingY:CGFloat = lastAttributes.frame.maxY + sectionBottomInset - frame.size.height
        
        /// 给frame的y赋新值，因为在最后消失的临界点要跟随消失，所以取小
        frame.origin.y = min(maxY, headerMissingY)
        attributes.frame = frame
        
        /// 如果按照正常情况下,header离开屏幕被系统回收，而header的层次关系又与cell相等，如果不去理会，会出现cell在header上面的情况
        /// 通过打印可以知道cell的层次关系zIndex数值为0，我们可以将header的zIndex设置成1，如果不放心，也可以将它设置成非常大，这里随便填了个7
        attributes.zIndex = 7
    }
}

