//
//  EiteiPresentationController.swift
//  EiteiQR
//
//  Created by damao on 2024/7/12.
//

#if canImport(UIKit)
import UIKit
#endif
// 升級版
class EiteiPresentationController: UIPresentationController {

    private var dimmingView: UIView!

    // 計算展示視圖的邊界，設置為容器視圖中心的半屏大小
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return .zero
        }
        let width = containerView.bounds.width
        let height = containerView.bounds.height * 0.7
        let originX = (containerView.bounds.width - width) / 2
        let originY = (containerView.bounds.height - height) / 2
        return CGRect(x: originX, y: originY, width: width, height: height)
    }

    // 即將開始展示過渡動畫時調用
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }

        // 創建一個遮罩視圖，背景色為半透明黑色
        dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(1)
        dimmingView.alpha = 0
        containerView.addSubview(dimmingView)

        // 添加點擊手勢識別器
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDimmingViewTap))
        dimmingView.addGestureRecognizer(tapGesture)

        // 過渡協調器，動畫顯示遮罩視圖
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        }, completion: nil)
    }

    // 即將開始隱藏過渡動畫時調用
    override func dismissalTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }

        // 過渡協調器，動畫隱藏遮罩視圖
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView?.alpha = 0
        }, completion: { _ in
            self.dimmingView?.removeFromSuperview()
        })
    }

    // 點擊遮罩視圖時調用
    @objc private func handleDimmingViewTap() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
