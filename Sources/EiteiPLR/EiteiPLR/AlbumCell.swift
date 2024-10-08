//
//  AlbumCell.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/10.
//

#if canImport(UIKit)
import UIKit
#endif
import SnapKit

class AlbumCell: UICollectionViewCell {
    
    // 定義專輯名稱標籤
    let albumNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 23)  // 設置字體為粗體，字號為 23
        label.textColor = .white  // 設置文字顏色為白色
        label.textAlignment = .center  // 設置文字對齊方式為居中
        return label
    }()
    
    // 定義藝術家名稱標籤
    let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)  // 設置字體為粗體，字號為 14
        label.textColor = UIColor(white: 1.0, alpha: 0.7)  // 設置文字顏色為白色，透明度為 0.7
        label.textAlignment = .center  // 設置文字對齊方式為居中
        return label
    }()
    
    // 新增 URL 屬性
    var albumURL: String? {
        didSet {
            // 可以在這裡處理 URL，例如加載圖片或其他操作
        }
    }
    
    // 初始化 cell
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 添加專輯名稱標籤和藝術家名稱標籤到 contentView
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(artistNameLabel)
        
        // 使用 SnapKit 設置專輯名稱標籤的約束
        albumNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()  // 將專輯名稱標籤的 X 軸中心對齊到超級視圖
            make.centerY.equalToSuperview().offset(-10)  // 將專輯名稱標籤的 Y 軸中心對齊到超級視圖，並向上偏移 10 點
        }
        
        // 使用 SnapKit 設置藝術家名稱標籤的約束
        artistNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()  // 將藝術家名稱標籤的 X 軸中心對齊到超級視圖
            make.top.equalTo(albumNameLabel.snp.bottom).offset(8)  // 將藝術家名稱標籤的頂部對齊到專輯名稱標籤的底部，並向下偏移 8 點
        }
        
        // 針對固定專輯添加灰度斜線紋理
        addGrayStripes()
    }
    
    // 當使用 Interface Builder 時，需要實現此初始化方法
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")  // 此初始化方法未實現
    }
    
    // 專輯封面紋理
    private func addGrayStripes() {
        let stripeLayer = CAShapeLayer()
        let path = UIBezierPath()
        let numberOfStripes = 6  // 設置直線數量
        let stripeWidth: CGFloat = 1 // 寬
        let stripeColor = UIColor.black
        
        for i in 0..<numberOfStripes {
            let xOffset = CGFloat(i) * (stripeWidth * 2)
            path.move(to: CGPoint(x: xOffset, y: 0))
            path.addLine(to: CGPoint(x: xOffset + stripeWidth, y: bounds.height))
        }
        
        stripeLayer.path = path.cgPath
        stripeLayer.strokeColor = stripeColor.cgColor
        stripeLayer.lineWidth = stripeWidth
        stripeLayer.fillColor = UIColor.clear.cgColor
        stripeLayer.frame = contentView.bounds
        stripeLayer.opacity = 0.5  // 設置透明度以避免遮擋標題
        contentView.layer.addSublayer(stripeLayer)
    }
}
