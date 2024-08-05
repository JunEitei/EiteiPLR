//
//  EiteiWaveView.swift
//  EiteiPLR
//
//  Created by damao on 2024/8/1.
//

import UIKit
import QuartzCore

// 計算公式，用於生成波形
fileprivate func gfn(x: CGFloat) -> CGFloat {
    return pow((8 / (8 + pow(x, 4))), 8)
}

// 生成波形線的函數
fileprivate func line(att: CGFloat, a: Int, b: CGFloat) -> (CGFloat) -> CGFloat {
    return {x in
        return gfn(x: x) * sin(CGFloat(a) * x - b) / att
    }
}

// 波形的結構體，用於描述波形的屬性
fileprivate struct Wave {
    var attenuation: CGFloat  // 衰減係數
    var lineWidth: CGFloat    // 線寬
    var opacity: CGFloat      // 不透明度
    
    init(att: CGFloat, lineWidth: CGFloat, opacity: CGFloat) {
        self.attenuation = att
        self.lineWidth = lineWidth
        self.opacity = opacity
    }
}

// 自訂的波形視圖
@IBDesignable
open class EiteiWaveView: UIView {
    
    fileprivate var phase: CGFloat = 0.0 // 波形相位
    fileprivate var displayLink: CADisplayLink? // 用於實現動畫效果
    fileprivate var animatingStart = false // 標記動畫是否開始
    fileprivate var animatingStop = false  // 標記動畫是否停止
    fileprivate var currentAmplitude: CGFloat = 0.0 // 當前振幅
    
    @IBInspectable
    public var speed: CGFloat = 0.1 // 波形速度
    @IBInspectable
    public var amplitude: CGFloat = 0.5 // 波形振幅
    @IBInspectable
    public var frequency: Int = 6 // 波形頻率
    @IBInspectable
    public var color: UIColor = .white // 波形顏色
    public private(set) var animating = false // 是否正在動畫中
    
    // 定義多條波形的屬性
    fileprivate let waves = [Wave(att: 1, lineWidth: 1.5, opacity: 1.0),
                             Wave(att: 2, lineWidth: 1.0, opacity: 0.6),
                             Wave(att: 4, lineWidth: 1.0, opacity: 0.4),
                             Wave(att: -6, lineWidth: 1.0, opacity: 0.2),
                             Wave(att: -2, lineWidth: 1.0, opacity: 0.1)
                            ]
    fileprivate let shapeLayers = [CAShapeLayer(),
                                   CAShapeLayer(),
                                   CAShapeLayer(),
                                   CAShapeLayer(),
                                   CAShapeLayer()]
    
    // MARK: Life Cycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        shapeLayers.forEach(layer.addSublayer) // 將所有CAShapeLayer添加到視圖的層中
        self.backgroundColor = .clear // 設置背景色為透明
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shapeLayers.forEach(layer.addSublayer) // 將所有CAShapeLayer添加到視圖的層中
        self.backgroundColor = .clear // 設置背景色為透明
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        drawLayers() // 設置層的屬性和路徑
    }
    
    // MARK: Public Methods
    
    // 開始動畫
    public func start() {
        if (animating) {
            return // 如果動畫已經開始，則不重複啟動
        }
        
        invalidate() // 停止任何現有的動畫
        animating = true
        animatingStop = false
        animatingStart = true
        displayLink = CADisplayLink(target: self, selector: #selector(EiteiWaveView.drawWaves))
        displayLink!.preferredFramesPerSecond = 60 // 設置幀率
        displayLink!.add(to: RunLoop.main, forMode: RunLoop.Mode.common) // 添加到主運行循環中
    }
    
    // 停止動畫
    public func stop() {
        animating = false
        animatingStart = false
        animatingStop = true
    }
    
    // MARK: Private Methods
    
    // 無效化動畫，停止計時器
    private func invalidate() {
        displayLink?.isPaused = true
        displayLink?.remove(from: RunLoop.main, forMode: RunLoop.Mode.common)
        displayLink = nil
    }
    
    // 繪製波形
    @objc private func drawWaves() {
        phase = (phase + CGFloat.pi * speed)
            .truncatingRemainder(dividingBy: 2 * CGFloat.pi)
        
        // 根據動畫狀態調整振幅
        if (animatingStart) {
            currentAmplitude = currentAmplitude + 0.02
            if (currentAmplitude >= amplitude) {
                currentAmplitude = amplitude
                animatingStart = false
            }
        } else if (animatingStop) {
            currentAmplitude = currentAmplitude - 0.02
            if (currentAmplitude <= 0.001) {
                currentAmplitude = 0
                animatingStop = false
                invalidate() // 停止動畫
            }
        }
        
        let count = waves.count
        
        for i in 0 ..< count {
            let shapLayer = shapeLayers[i]
            let wave = waves[i]
            shapLayer.path = bezierPath(for: wave).cgPath // 設置路徑
        }
    }
    
    // 設置每個層的屬性和路徑
    private func drawLayers() {
        let count = waves.count
        
        for i in 0 ..< count {
            let shapLayer = shapeLayers[i]
            let wave = waves[i]
            shapLayer.fillColor = UIColor.clear.cgColor // 填充顏色為透明
            shapLayer.lineWidth = wave.lineWidth // 設置線寬
            shapLayer.strokeColor = color.withAlphaComponent(wave.opacity).cgColor // 設置描邊顏色
            shapLayer.path = bezierPath(for: wave).cgPath // 設置路徑
        }
    }
    
    // 根據波形的屬性生成貝塞爾曲線路徑
    private func bezierPath(for wave: Wave) -> UIBezierPath {
        let path = UIBezierPath()
        
        let width = frame.width
        let height = frame.height
        let centerY = height / 2
        let scale = width / 4
        let centerX = width / 2
        let f = line(att: wave.attenuation, a: frequency, b: phase)
        path.move(to: CGPoint(x: 0, y: centerY))
        for i in 0...Int(width) {
            let x = (CGFloat(i) - centerX) / scale
            let y = f(x) * scale * currentAmplitude + centerY
            path.addLine(to: CGPoint(x: CGFloat(i), y: y))
        }
        
        return path
    }
}
