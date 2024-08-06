//
//  AlbumCollectionViewLayout.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/10.
//

#if canImport(UIKit)
import UIKit
#endif

open class AlbumCollectionViewLayout: UICollectionViewLayout {
    
    // MARK: - 佈局配置
    
    // 卡片大小，設定時會重新計算佈局
    public var itemSize: CGSize = CGSize(width: 200, height: 300) {
        didSet{
            invalidateLayout()
        }
    }
    
    // 卡片間距，設定時會重新計算佈局
    public var spacing: CGFloat = 10.0 {
        didSet{
            invalidateLayout()
        }
    }
    
    // 最大可見卡片數量，設定時會重新計算佈局
    public var maximumVisibleItems: Int = 4 {
        didSet{
            invalidateLayout()
        }
    }
    
    // MARK: UICollectionViewLayout
    
    // 返回集合視圖
    override open var collectionView: UICollectionView {
        return super.collectionView!
    }
    
    // 返回集合視圖內容的大小
    override open var collectionViewContentSize: CGSize {
        let itemsCount = CGFloat(collectionView.numberOfItems(inSection: 0))
        return CGSize(width: collectionView.bounds.width * itemsCount,
                      height: collectionView.bounds.height)
    }
    
    // 準備佈局
    override open func prepare() {
        super.prepare()
        // 確保集合視圖只有一個分區
        assert(collectionView.numberOfSections == 1, "Multiple sections aren't supported!")
    }
    
    // 返回指定矩形範圍內所有項目的佈局屬性
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let totalItemsCount = collectionView.numberOfItems(inSection: 0)
        
        // 計算可見的最小和最大索引
        let minVisibleIndex = max(Int(collectionView.contentOffset.x) / Int(collectionView.bounds.width), 0)
        let maxVisibleIndex = min(minVisibleIndex + maximumVisibleItems, totalItemsCount)
        
        // 計算內容的中心點X座標
        let contentCenterX = collectionView.contentOffset.x + (collectionView.bounds.width / 2.0)
        
        // 計算滾動偏移量
        let deltaOffset = Int(collectionView.contentOffset.x) % Int(collectionView.bounds.width)
        
        // 計算滾動偏移量的百分比
        let percentageDeltaOffset = CGFloat(deltaOffset) / collectionView.bounds.width
        
        // 生成可見索引範圍內的佈局屬性
        let visibleIndices = stride(from: minVisibleIndex, to: maxVisibleIndex, by: 1)
        
        // 為每個可見項目計算佈局屬性
        let attributes: [UICollectionViewLayoutAttributes] = visibleIndices.map { index in
            let indexPath = IndexPath(item: index, section: 0)
            return computeLayoutAttributesForItem(indexPath: indexPath,
                                                  minVisibleIndex: minVisibleIndex,
                                                  contentCenterX: contentCenterX,
                                                  deltaOffset: CGFloat(deltaOffset),
                                                  percentageDeltaOffset: percentageDeltaOffset)
        }
        
        return attributes
    }
    
    // 返回指定項目的佈局屬性
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let contentCenterX = collectionView.contentOffset.x + (collectionView.bounds.width / 2.0)
        let minVisibleIndex = Int(collectionView.contentOffset.x) / Int(collectionView.bounds.width)
        let deltaOffset = Int(collectionView.contentOffset.x) % Int(collectionView.bounds.width)
        let percentageDeltaOffset = CGFloat(deltaOffset) / collectionView.bounds.width
        return computeLayoutAttributesForItem(indexPath: indexPath,
                                              minVisibleIndex: minVisibleIndex,
                                              contentCenterX: contentCenterX,
                                              deltaOffset: CGFloat(deltaOffset),
                                              percentageDeltaOffset: percentageDeltaOffset)
    }
    
    // 判斷佈局是否因為邊界改變而無效
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}


// MARK: - 佈局計算

fileprivate extension AlbumCollectionViewLayout {
    
    // 計算指定索引處的縮放比例
    private func scale(at index: Int) -> CGFloat {
        let translatedCoefficient = CGFloat(index) - CGFloat(self.maximumVisibleItems) / 2
        return CGFloat(pow(0.95, translatedCoefficient))
    }
    
    // 計算當前可見索引處的變換
    private func transform(atCurrentVisibleIndex visibleIndex: Int, percentageOffset: CGFloat) -> CGAffineTransform {
        var rawScale = visibleIndex < maximumVisibleItems ? scale(at: visibleIndex) : 1.0
        
        if visibleIndex != 0 {
            let previousScale = scale(at: visibleIndex - 1)
            let delta = (previousScale - rawScale) * percentageOffset
            rawScale += delta
        }
        return CGAffineTransform(scaleX: rawScale, y: rawScale)
    }
    
    // 計算指定項目的佈局屬性
    func computeLayoutAttributesForItem(indexPath: IndexPath,
                                        minVisibleIndex: Int,
                                        contentCenterX: CGFloat,
                                        deltaOffset: CGFloat,
                                        percentageDeltaOffset: CGFloat) -> UICollectionViewLayoutAttributes {
        // 創建一個 UICollectionViewLayoutAttributes 對象，該對象包含指定 indexPath 的單元格的佈局屬性
        let attributes = UICollectionViewLayoutAttributes(forCellWith:indexPath)
        
        // 計算該項目的可見索引，從最小可見索引開始
        let visibleIndex = indexPath.row - minVisibleIndex
        
        // 設置單元格的大小
        attributes.size = itemSize
        
        // 獲取 collectionView 的中心點的 y 值
        let midY = self.collectionView.bounds.midY
        
        // 設置單元格的中心位置，x 值根據可見索引和間距進行偏移
        attributes.center = CGPoint(x: contentCenterX + spacing * CGFloat(visibleIndex),
                                    y: midY + spacing * CGFloat(visibleIndex))
        
        // 設置單元格的 zIndex，確保最前面的單元格具有最高的 zIndex
        attributes.zIndex = maximumVisibleItems - visibleIndex
        
        // 設置單元格的變換屬性，用於縮放效果
        attributes.transform = transform(atCurrentVisibleIndex: visibleIndex,
                                         percentageOffset: percentageDeltaOffset)
        
        // 根據可見索引進行不同的佈局調整
        switch visibleIndex {
        case 0:
            // 最前面的單元格，x 值進行偏移以顯示滑動效果
            attributes.center.x -= deltaOffset
            break
        case 1..<maximumVisibleItems:
            // 其餘可見單元格，x 和 y 值根據百分比偏移量進行偏移
            attributes.center.x -= spacing * percentageDeltaOffset
            attributes.center.y -= spacing * percentageDeltaOffset
            
            // 如果是最後一個可見單元格，根據百分比偏移量設置透明度
            if visibleIndex == maximumVisibleItems - 1 {
                attributes.alpha = percentageDeltaOffset
            }
            break
        default:
            // 其他單元格設置為完全透明
            attributes.alpha = 0
            break
        }
        return attributes
    }
}
