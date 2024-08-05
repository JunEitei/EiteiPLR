//
//  EiteiDrawerViewController.swift
//  EiteiPLR
//
//  Created by damao on 2024/8/2.
//
import UIKit

// 抽屜方向枚舉
public enum EiteiDrawerDirection {
    case left  // 左側
    case right // 右側
}

// 抽屜模式枚舉
public enum EiteiDrawerMode {
    case left  // 僅左側抽屜
    case right // 僅右側抽屜
    case all   // 左右側都顯示抽屜
}

// 抽屜拖動狀態枚舉
enum EiteiDrawerDragState {
    case leftOpen   // 左側打開
    case leftClose  // 左側關閉
    case rightOpen  // 右側打開
    case rightClose // 右側關閉
}

// 抽屜視圖控制器
public class EiteiDrawerViewController: UIViewController {
    
    public var leftViewController: UIViewController? // 左側視圖控制器
    public var rightViewController: UIViewController? // 右側視圖控制器
    public var homeViewController: UIViewController? // 主視圖控制器
    
    static let shared = EiteiDrawerViewController() // 單例實例
    
    // public properties
    public var drawerWidth: CGFloat = 0.0 // 抽屜寬度
    public var isPanEnabled: Bool = true // 是否啟用滑動手勢
    
    public var drawerShadowColor: UIColor = .black {
        didSet {
            EiteiDrawerViewController.shared.homeViewController?.view.layer.shadowColor = self.drawerShadowColor.cgColor
        }
    } // 抽屜陰影顏色
    
    public var drawerMode: EiteiDrawerMode = .all // 抽屜模式
    
    var isRightView: Bool = false // 是否顯示右側抽屜
    
    // internal properties
    var touchStartPoint: CGPoint = .zero // 滑動開始點
    var touchEndPoint: CGPoint = .zero // 滑動結束點
    var touchHoldPoint: CGPoint = .zero // 滑動持續點
    var isClosing: Bool = false // 是否在關閉抽屜
    
    var viewStartDragPoint: CGFloat = 0.0 // 視圖開始拖動點
    var currentDragState: EiteiDrawerDragState = .leftOpen // 當前拖動狀態
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // 進行額外設置
        isRightView = self.rightViewController != nil // 判斷是否有右側視圖控制器
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureDrawer() // 配置抽屜
    }
    
    // 配置抽屜
    func configureDrawer() {
        // 配置主視圖控制器的陰影效果
        self.homeViewController?.view.layer.masksToBounds = false
        self.homeViewController?.view.layer.shadowColor = self.drawerShadowColor.cgColor
        self.homeViewController?.view.layer.shadowOpacity = 0.3
        self.homeViewController?.view.layer.shadowOffset = .zero
        self.homeViewController?.view.layer.shadowRadius = 2
        self.homeViewController?.view.layer.shouldRasterize = true
        self.homeViewController?.view.layer.rasterizationScale = 1
        
        // 配置左側視圖控制器
        if let leftVC = self.leftViewController {
            self.configureController(controller: leftVC)
            EiteiDrawerViewController.shared.leftViewController = leftVC
        } else {
            // assertionFailure("Please set left view controller") // 需要設置左側視圖控制器
        }
        
        // 配置右側視圖控制器
        if let rightVC = self.rightViewController {
            self.configureController(controller: rightVC)
            EiteiDrawerViewController.shared.rightViewController = rightVC
        }
        
        // 配置主視圖控制器
        if let homeVC = self.homeViewController {
            self.configureController(controller: homeVC)
            EiteiDrawerViewController.shared.homeViewController = homeVC
            
            if self.drawerWidth == 0 {
                self.configureDrawerWidth() // 配置抽屜寬度
            }
            
            EiteiDrawerViewController.shared.drawerWidth = self.drawerWidth
            
            // 添加滑動手勢識別器
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(pan:)))
            EiteiDrawerViewController.shared.homeViewController?.view.addGestureRecognizer(panGesture)
            
            // 添加點擊手勢識別器
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(tap:)))
            EiteiDrawerViewController.shared.homeViewController?.view.addGestureRecognizer(tapGesture)
        } else {
            // assertionFailure("Please set home view controller") // 需要設置主視圖控制器
        }
    }
    
    // 切換抽屜
    public func toggleDrawer(mode: EiteiDrawerDirection) {
        var drawerRatio: CGFloat = 0 // 抽屜位置比例
        var touchEnable = false // 是否啟用觸摸
        
        var isDrawerOpen = EiteiDrawerViewController.shared.homeViewController!.view.frame.origin.x == self.drawerWidth
        
        if mode == .right {
            isDrawerOpen = EiteiDrawerViewController.shared.homeViewController!.view.frame.origin.x == (-self.drawerWidth)
        }
        
        if mode == .left && self.leftViewController != nil {
            if !isDrawerOpen && self.leftViewController!.responds(to: #selector(self.viewWillAppear(_:))) {
                self.leftViewController?.viewWillAppear(true)
            }
            
            if EiteiDrawerViewController.shared.homeViewController!.view.frame.origin.x == 0 {
                EiteiDrawerViewController.shared.rightViewController?.view.isHidden = true
                drawerRatio = self.drawerWidth
                touchEnable = false
                currentDragState = .leftClose
            } else {
                drawerRatio = 0
                touchEnable = true
            }
        } else {
            if self.rightViewController != nil {
                if !isDrawerOpen && self.rightViewController!.responds(to: #selector(self.viewWillAppear(_:))) {
                    self.rightViewController?.viewWillAppear(true)
                }
                
                if EiteiDrawerViewController.shared.homeViewController!.view.frame.origin.x == 0 {
                    EiteiDrawerViewController.shared.rightViewController?.view.isHidden = false
                    drawerRatio = -self.drawerWidth
                    touchEnable = false
                    currentDragState = .rightClose
                } else {
                    drawerRatio = 0
                    touchEnable = true
                }
            } else {
                touchEnable = true
            }
        }
        
        self.doSlideAnimation(xVariation: drawerRatio, isEnableInteraction: touchEnable) // 執行滑動動畫
    }
    
    // 配置視圖控制器
    private func configureController(controller: UIViewController) {
        self.addChild(controller) // 添加子視圖控制器
        controller.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.view.addSubview(controller.view) // 添加視圖
        controller.didMove(toParent: self) // 通知子視圖控制器
    }
    
    // 配置抽屜寬度
    private func configureDrawerWidth() {
        if self.homeViewController!.view.frame.size.width < self.homeViewController!.view.frame.size.height {
            self.drawerWidth = self.homeViewController!.view.frame.size.width / 2 + 50
        } else {
            self.drawerWidth = self.homeViewController!.view.frame.size.height / 2 + 50
        }
    }
    
    // 處理滑動手勢
    @objc private func handlePanGesture(pan: UIPanGestureRecognizer) {
        let touchPoint = pan.location(in: pan.view) // 獲取觸摸點
        let velocity = pan.velocity(in: pan.view) // 獲取滑動速度
        
        if !EiteiDrawerViewController.shared.isPanEnabled {
            return // 如果未啟用滑動手勢，則返回
        }
        
        if pan.state == .began {
            touchStartPoint = touchPoint // 記錄觸摸開始點
            touchHoldPoint = touchPoint // 記錄觸摸持續點
            viewStartDragPoint = pan.view?.frame.origin.x ?? 0.0 // 記錄視圖開始拖動點
        } else if pan.state == .changed {
            touchEndPoint = touchPoint // 記錄觸摸結束點
            let dx = touchEndPoint.x - touchStartPoint.x // 計算水平位移
            let dy = touchEndPoint.y - touchStartPoint.y // 計算垂直位移
            
            if dx > 0 && self.homeViewController!.view.frame.origin.x <= self.drawerWidth {
                guard EiteiDrawerViewController.shared.drawerMode == .left || EiteiDrawerViewController.shared.drawerMode == .all else {
                    return
                }
                
                self.homeViewController?.view.frame.origin.x = min(dx, drawerWidth) // 更新主視圖位置
            } else if dx < 0 && viewStartDragPoint == 0 && self.homeViewController!.view.frame.origin.x <= 0 {
                guard EiteiDrawerViewController.shared.drawerMode == .right || EiteiDrawerViewController.shared.drawerMode == .all else {
                    return
                }
                
                self.homeViewController?.view.frame.origin.x = max(dx, -drawerWidth) // 更新主視圖位置
            }
        } else if pan.state == .ended {
            let finalPoint = pan.location(in: pan.view) // 獲取最終觸摸點
            let dx = finalPoint.x - touchStartPoint.x // 計算最終水平位移
            
            if dx > drawerWidth / 2 {
                self.toggleDrawer(mode: .left) // 打開左側抽屜
            } else if dx < -drawerWidth / 2 {
                self.toggleDrawer(mode: .right) // 打開右側抽屜
            } else {
                self.toggleDrawer(mode: .left) // 關閉抽屜
            }
        }
    }
    
    // 處理點擊手勢
    @objc private func handleTapGesture(tap: UITapGestureRecognizer) {
        let touchPoint = tap.location(in: tap.view) // 獲取點擊點
        
        if self.homeViewController?.view.frame.origin.x != 0 {
            let leftDrawerFrame = CGRect(x: 0, y: 0, width: drawerWidth, height: UIScreen.main.bounds.height)
            let rightDrawerFrame = CGRect(x: -drawerWidth, y: 0, width: drawerWidth, height: UIScreen.main.bounds.height)
            
            if !leftDrawerFrame.contains(touchPoint) && !rightDrawerFrame.contains(touchPoint) {
                self.toggleDrawer(mode: .left) // 關閉抽屜
            }
        }
    }
    
    // 執行抽屜滑動動畫
    private func doSlideAnimation(xVariation: CGFloat, isEnableInteraction: Bool) {
        let animationDuration = 0.3 // 動畫持續時間
        UIView.animate(withDuration: animationDuration, animations: {
            self.homeViewController?.view.frame.origin.x = xVariation // 更新主視圖位置
        }) { _ in
            EiteiDrawerViewController.shared.isPanEnabled = isEnableInteraction // 設置滑動手勢啟用狀態
        }
    }
    
    // 顯示左側抽屜
    public func showLeftDrawer() {
        self.toggleDrawer(mode: .left)
    }
    
    // 顯示右側抽屜
    public func showRightDrawer() {
        self.toggleDrawer(mode: .right)
    }
    
    // 隱藏抽屜
    public func hideDrawer() {
        self.toggleDrawer(mode: .left)
    }
    
}


