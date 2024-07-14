//
//  EiteiWebController.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/11.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(WebKit)
import WebKit
#endif

import SnapKit

class EiteiWebController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var url: URL!

    // 初始化方法，接受一個 URL 對象作為參數
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // 創建 WebView
        webView = WKWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)

        // 設置 WebView 的 Frame，考慮狀態欄高度和安全區域
        webView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top) // 緊貼安全區域頂部
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom) // 緊貼安全區域底部
        }

        // 加載網頁
        let request = URLRequest(url: self.url)
        webView.load(request)

        // 設置 contentInsetAdjustmentBehavior 為 .never
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // 設置背景顏色為黑色
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black

        // 禁用 WebView 背景透明
        webView.isOpaque = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 停止加載網頁
        webView.stopLoading()
        
        // 從父視圖移除並釋放引用
        webView.removeFromSuperview()
    }
}
