import UIKit
import WebKit
import SnapKit

class EiteiWebController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 创建 WebView
        webView = WKWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)

        // 设置 WebView 的 Frame，考虑状态栏高度和安全区域
        webView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top) // 紧贴安全区域顶部
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom) // 紧贴安全区域底部
        }

        // 加载网页
        let url = URL(string: "https://juneitei.github.io/")!
        let request = URLRequest(url: url)
        webView.load(request)

        // 设置 contentInsetAdjustmentBehavior 为 .never
        webView.scrollView.contentInsetAdjustmentBehavior = .never
    }
}
