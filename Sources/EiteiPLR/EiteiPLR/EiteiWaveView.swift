//
//  EiteiWaveView.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/11.
//

#if canImport(UIKit)
import UIKit
#endif

class EiteiWaveView: UIView {
    
    private let replicatorLayer = CAReplicatorLayer() // CAReplicatorLayer 用于创建和管理多个相同的 CALayer 实例的图层
    private var flameLayers = [CALayer]() // 存储火焰 CALayer 的数组
    
    private let flameWidth: CGFloat = 9.0 // 火焰宽度
    private let flameHeight: CGFloat = 30.0 // 火焰高度，调整后的值，确保火焰不超出视图底部
    private let flameColor = UIColor.eiteiBlue.cgColor // 火焰颜色，使用自定义颜色 eiteiBlue
    private let animationDuration: CFTimeInterval = 0.5 // 火焰动画持续时间
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFlames()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupFlames()
    }
    
    private func setupFlames() {
        backgroundColor = .clear
        replicatorLayer.frame = bounds // 设置 replicatorLayer 的 frame 为当前视图的 bounds
        layer.addSublayer(replicatorLayer) // 将 replicatorLayer 添加到当前视图的 layer 中
        
        let flameCount = 2 // 火焰数量为 2
        let totalFlameWidth = CGFloat(flameCount) * flameWidth * 2 // 计算火焰总宽度
        let startX = (bounds.width - totalFlameWidth) / 2 // 计算火焰起始 X 坐标
        
        // 创建火焰图层并添加到 replicatorLayer 中
        for i in 0..<flameCount {
            let flameLayer = CALayer()
            flameLayer.backgroundColor = flameColor
            flameLayer.frame = CGRect(x: startX + CGFloat(i) * flameWidth * 2, y: bounds.height - flameHeight, width: flameWidth, height: flameHeight)
            replicatorLayer.addSublayer(flameLayer)
            flameLayers.append(flameLayer)
            
            // 添加火焰的缩放动画
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.y")
            scaleAnimation.fromValue = 1.0
            scaleAnimation.toValue = 0.1
            scaleAnimation.duration = animationDuration
            scaleAnimation.autoreverses = true
            scaleAnimation.repeatCount = Float.infinity
            flameLayer.add(scaleAnimation, forKey: "flameAnimation\(i)")
        }
        
        replicatorLayer.instanceCount = flameCount // 设置 replicatorLayer 的实例数量
        replicatorLayer.instanceTransform = CATransform3DMakeTranslation(flameWidth * 2, 0, 0) // 设置 replicatorLayer 的实例间隔
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        replicatorLayer.frame = bounds // 在视图布局变化时更新 replicatorLayer 的 frame
        
        let flameCount = 3 // 调整为 3 条火焰
        let totalFlameWidth = CGFloat(flameCount) * flameWidth * 2 // 计算调整后的火焰总宽度
        let startX = (bounds.width - totalFlameWidth) / 2 // 计算调整后的火焰起始 X 坐标
        
        // 更新火焰图层的位置
        for (index, flameLayer) in flameLayers.enumerated() {
            flameLayer.frame = CGRect(x: startX + CGFloat(index) * flameWidth * 2, y: bounds.height - flameHeight, width: flameWidth, height: flameHeight)
        }
    }
}
