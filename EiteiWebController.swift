import UIKit
import WebKit
import SnapKit

class EiteiWebController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!

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
        let url = URL(string: "https://juneitei.github.io/")!
        let request = URLRequest(url: url)
        webView.load(request)

        // 設置 contentInsetAdjustmentBehavior 為 .never
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // 設置背景顏色為黑色
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black

        // 禁用 WebView 背景透明
        webView.isOpaque = false
    }
}
