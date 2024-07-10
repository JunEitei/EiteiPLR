//
//  Eitei.swift
//  EiteiPLR
//
//  Created by damao on 2024/6/17.
//


import UIKit

// 這個類用來做一些關乎全局的事情
class Eitei {
    static let shared = Eitei()
    
    private init() { }
    
    // 封裝從Bundle中讀取圖片
    func loadImage(named name: String) -> UIImage? {
        
        
#if SWIFT_PACKAGE
        // 嘗試從文件夾裡直接讀取 （SPM）
        let bundle = Bundle.module
        
        // 圖片名稱
        let imageName = name
        
        // 這裡假設圖片是 PNG 格式，可以根據實際情況調整 withExtension 的參數
        if let imageUrl = bundle.url(forResource: name, withExtension: "png", subdirectory: "Resource"),
           let image = UIImage(contentsOfFile: imageUrl.path) {
            // 使用 image
            return image
        } else {
            // 使用 Bundle.module 訪問 SPM 中的資源
            let bundle = Bundle.module
            // 讀取
            return UIImage(named: name, in: bundle, with: nil)
        }
#else
        let bundle = Bundle(for: Eitei.self)
#endif
        // 构建资源文件的相对路径
        let resourcePath = "\(name)"
        
        // 使用 bundle 加载资源
        if let imageUrl = bundle.url(forResource: resourcePath, withExtension: "png") {
            if let image = UIImage(contentsOfFile: imageUrl.path) {
                // 成功加载图片
                return image
            } else {
                print("Failed to load image from path:", imageUrl.path)
            }
        } else {
            print("Resource file not found:", resourcePath)
        }
        // 加载失败时返回默认图片或处理其他逻辑
        return UIImage(named: name)
    }
}
