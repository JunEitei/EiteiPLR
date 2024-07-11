//
//  UITableViewExtension.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/12.
//

extension UITableView {
    
    // 設置空視圖，顯示自定義標題和消息，並隱藏分隔線
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(emptyView.snp.centerX)
            make.centerY.equalTo(emptyView.snp.centerY).offset(-80)
        }
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)

        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(32)
        }
        messageLabel.text = message
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 14, weight: .regular)
        
    }
    
    // 恢復正常視圖，移除空視圖並顯示分隔線
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
    
    // 获取一个 UITableView 所在的视图控制器
    func getOwningViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }

    
}
