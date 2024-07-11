//
//  EiteiPaddedLabel.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/11.
//

#if canImport(Foundation)
import Foundation
#endif

// 可以設置文字邊距的自定義UILabel
class EiteiPaddedLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)))
    }
}
