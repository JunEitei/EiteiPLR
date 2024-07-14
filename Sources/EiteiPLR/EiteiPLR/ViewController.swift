//
//  ViewController.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/10.
//

#if canImport(UIKit)
import UIKit
#endif

import SnapKit
import Combine

public class ViewController: UIViewController, UISearchBarDelegate ,UIViewControllerTransitioningDelegate {
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>() // 訂閱集合，用於管理Combine框架的訂閱
    
    let musicPlayerViewModel = MusicViewModel() // 音樂播放器的視圖模型
    
    

    
    let listTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)        // 設置表格視圖
        
        tableView.backgroundColor = .eiteiGray
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        return tableView
    }()
    
    
    
    private lazy var trackNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .eiteiGray // 文字顏色設置
        label.font = .systemFont(ofSize: 19, weight: .bold) // 字體和粗細設置
        label.textAlignment = .left // 文字對齊方式
        
        return label
    }()
    
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical // 垂直排列的堆疊視圖
        view.spacing = 0 // 子視圖間距
        
        view.addArrangedSubview(trackNameLabel) // 將歌曲名稱標籤添加到堆疊視圖
        
        return view
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.tintColor = .eiteiBackground // 圖示顏色設置
        let image = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 28))) // 設置播放/暫停按鈕圖示
        button.setImage(image, for: .normal) // 設置按鈕的圖示
        
        return button
    }()
    
    private let trackDurationSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .eiteiBlue // 設置滑塊的顏色
        slider.thumbTintColor = .clear // 設置滑塊的拇指顏色為透明
        slider.maximumTrackTintColor = .white // 設置滑塊的最大軌道顏色為白色
        slider.isUserInteractionEnabled = false // 禁用滑塊的交互功能
        slider.minimumValue = 0 // 設置滑塊的最小值
        slider.value = 0 // 設置滑塊的當前值
        
        return slider
    }()
    
    private lazy var stackCardView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal // 水平排列的堆疊視圖
        view.distribution = .equalSpacing // 均等間距的分佈方式
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addArrangedSubview(stackView) // 將堆疊視圖添加到堆疊視圖
        view.addArrangedSubview(playPauseButton) // 將播放/暫停按鈕添加到堆疊視圖
        
        return view
    }()
    
    
    
    lazy var musicPlayerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white // 設置卡片視圖的背景色為白色
        view.layer.cornerRadius = 12 // 設置卡片視圖的圓角半徑
        
        view.addSubview(stackCardView) // 將堆疊卡片視圖添加到卡片視圖
        stackCardView.snp.makeConstraints { make in
            
            // 卡片寬度在這設
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 22, bottom: 12, right: 22)) // 設置堆疊卡片視圖的邊界約束
        }
        
        view.addSubview(trackDurationSlider) // 將歌曲持續時間滑塊添加到卡片視圖
        trackDurationSlider.snp.makeConstraints { make in
            make.top.equalTo(stackCardView.snp.bottom).offset(-6) // 設置滑塊與堆疊卡片視圖的底部對齊
            make.left.right.equalToSuperview() // 設置滑塊與卡片視圖的左右對齊
        }
        
        view.clipsToBounds = true // 裁剪超出邊界的內容
        
        let container = UIView()
        container.layer.shadowColor = UIColor.eiteiBlue.cgColor // 設置容器視圖的陰影顏色
        container.layer.shadowOpacity = 0.7 // 設置容器視圖的陰影不透明度
        container.layer.shadowOffset = .zero // 設置容器視圖的陰影偏移量
        container.layer.shadowRadius = 10 // 設置容器視圖的陰影半徑
        
        container.addSubview(view) // 將卡片視圖添加到容器視圖
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview() // 設置卡片視圖與容器視圖的邊界約束
        }
        
        container.isHidden = true // 設置容器視圖初始為隱藏狀態
        
        return container // 返回容器視圖
    }()
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUI() // 設置界面元素
        
        listTableView.register(MusicCell.self, forCellReuseIdentifier: "cell") // 註冊自定義的音軌視圖單元格
        listTableView.dataSource = self // 設置表格視圖的數據源
        listTableView.delegate = self // 設置表格視圖的委託
        
        musicPlayerViewModel.fetchTracks() // 加載音軌數據
        addTargets() // 添加按鈕點擊事件
        bindToViewModel() // 將視圖模型綁定到視圖上
        
        // 设置远程控制事件监听器
        UIApplication.shared.beginReceivingRemoteControlEvents()
        becomeFirstResponder()
        
        // 註冊下一曲通知觀察者
        NotificationCenter.default.addObserver(self, selector: #selector(updateCurrentlyPlayingTrack(notification:)), name: NSNotification.Name("TrackDidEndNotification"), object: nil)
        
        // 註冊曲目數量計算通知觀察者
        NotificationCenter.default.addObserver(self, selector: #selector(handleMusicCountUpdate(_:)), name: Notification.Name("MusicCountUpdated"), object: nil)
        
        // 網絡恢復重試
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: Notification.Name("NetworkResume"), object: nil)
        
    }
    
    
    
    // 接收通知並處理音樂總數量更新
    @objc func handleMusicCountUpdate(_ notification: Notification) {
//        if let totalMusicCount = notification.object as? Int {
//            // 回到主線程更新接收到的音樂總數量
//            DispatchQueue.main.async { [self] in
//                titleTopLabel.text = "大毛\(totalMusicCount)曲"
//                
//                // 同時刷新表格
//                listTableView.reloadData()
//            }
//        }
    }
    
    
    @objc func reload() {
        
        // 加載音軌數據
        musicPlayerViewModel.fetchTracks()
        
    }
    
    
    // 觸法下一曲的時候
    @objc func updateCurrentlyPlayingTrack(notification: Notification) {
        
        // 列表選擇下一曲
        selectNextSong()
    }
    
    deinit {
        
        // 移除通知觀察者
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("TrackDidEndNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("MusicCountUpdated"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("NetworkResume"), object: nil)
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 停止接收远程控制事件
        UIApplication.shared.endReceivingRemoteControlEvents()
        resignFirstResponder()
    }
    
    // 处理远程控制事件
    public override func remoteControlReceived(with event: UIEvent?) {
        guard let event = event else { return }
        
        if event.type == .remoteControl {
            switch event.subtype {
            case .remoteControlPlay:
                // 处理播放事件
                break
            case .remoteControlPause:
                // 处理暂停事件
                break
            case .remoteControlNextTrack:
                // 处理下一曲事件
                selectNextSong()
                break
            case .remoteControlPreviousTrack:
                // 处理上一曲事件
                break
            default:
                break
            }
        }
    }
    
    // 自動播放下一曲的效果
    private func selectNextSong(){
        // 確定索引路徑
        let rowIndex = musicPlayerViewModel.currentTrackIndex
        
        // 取消上一曲的選擇
        listTableView.cellForRow(at: IndexPath(row: rowIndex-1, section: 0) )?.setSelected(false, animated: false)
        // 選中當前這首
        listTableView.cellForRow(at: IndexPath(row: rowIndex, section: 0) )?.setSelected(true, animated: false)
    }
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    // MARK: - Private Methods
    private func setUI() {
        view.backgroundColor = .eiteiBackground
        
        // 创建三个按钮，并设置不同的浅色背景颜色
        let liveButton = UIButton(type: .system)
        liveButton.setTitle("ライブ", for: .normal)
        liveButton.backgroundColor = .eiteiYellow
        liveButton.setTitleColor(.white, for: .normal)
        liveButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        liveButton.heightAnchor.constraint(equalToConstant: 45).isActive = true // 设置按钮高度
        // 添加按钮点击事件
        liveButton.addTarget(self, action: #selector(liveButtonTapped), for: .touchUpInside)


        let bookButton = UIButton(type: .system)
        bookButton.setTitle("本", for: .normal)
        bookButton.backgroundColor = .eiteiSuperOrange
        bookButton.setTitleColor(.white, for: .normal)
        bookButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        bookButton.heightAnchor.constraint(equalToConstant: 45).isActive = true // 设置按钮高度
        // 添加按钮点击事件
        bookButton.addTarget(self, action: #selector(bookButtonTapped), for: .touchUpInside)
        
        let catButton = UIButton(type: .system)
        catButton.setTitle("野良猫救出", for: .normal)
        catButton.backgroundColor = .eiteiRed
        catButton.setTitleColor(.white, for: .normal)
        catButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        catButton.heightAnchor.constraint(equalToConstant: 45).isActive = true // 设置按钮高度
        // 添加按钮点击事件
        catButton.addTarget(self, action: #selector(catButtonTapped), for: .touchUpInside)

        
        // 创建UIStackView并添加按钮
        let topMenuStack = UIStackView(arrangedSubviews: [liveButton, bookButton, catButton])
        topMenuStack.axis = .horizontal
        topMenuStack.distribution = .fillEqually
        topMenuStack.spacing = 0 // 减小间距
        topMenuStack.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加UIStackView到主视图
        view.addSubview(topMenuStack)

        topMenuStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        // 添加和配置播放器
        view.addSubview(musicPlayerView)
        musicPlayerView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.left.equalToSuperview().offset(13)
            make.right.equalToSuperview().offset(-13)
        }
        
        // 添加和配置 listTableView
        view.addSubview(listTableView)
        listTableView.snp.makeConstraints { make in
            
            //距離標題20px
            make.top.equalTo(topMenuStack.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            // 表格底部距離，關乎被遮擋多少（重要）
            make.bottom.equalTo(self.view).offset(-90)
        }
    }
    
    
    private func showLoading() {
        // 隱藏表格視圖以顯示加載加載動畫
        listTableView.isHidden = true
        
        // 創建帶有活動指示器的加載動畫
        let alertController = UIAlertController(title: nil, message: "読み込み中...", preferredStyle: .alert)
        
        // 創建並配置活動指示器
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicator.isUserInteractionEnabled = false
        
        // 設置加載動畫高度約束
        alertController.view.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        // 添加活動指示器到加載動畫視圖
        alertController.view.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.centerX.equalTo(alertController.view)
            make.top.equalTo(alertController.view.snp.centerY).offset(5)
        }
        


        
    }
    
    private func showError(message: String) {
        // 創建一個加載動畫，顯示錯誤消息
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        // 添加“OK”按鈕動作，點擊後關閉加載動畫
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        
        // 顯示加載動畫
        present(alertController, animated: true, completion: nil)
    }
    
    private func dismissLoading() {
        // 顯示表格視圖，並關閉正在顯示的加載動畫
        listTableView.isHidden = false
        dismiss(animated: true, completion: nil)
    }
    
    private func bindToViewModel() {
        // 監聽音樂播放狀態，根據狀態設置播放/暫停按鈕圖片
        musicPlayerViewModel.$isPlaying
            .sink { [weak self] state in
                let imageName = state ? "pause.fill" : "play.fill"  // 根據播放狀態選擇不同的圖片名稱
                let image = UIImage(systemName: imageName, withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 28)))  // 使用系統符號圖標配置創建圖片
                self?.playPauseButton.setImage(image, for: .normal)  // 設置播放/暫停按鈕的圖片
            }
            .store(in: &subscriptions)  // 將訂閱存入訂閱集合中，以便管理生命周期
        
        // 監聽最大播放時長，更新播放進度條的最大值
        musicPlayerViewModel.$maxCurrentDuration
            .sink { [weak self] duration in
                self?.trackDurationSlider.maximumValue = Float(duration)  // 將最大播放時長轉換為浮點數並設置為進度條的最大值
            }
            .store(in: &subscriptions)  // 將訂閱存入訂閱集合中
        
        // 監聽當前播放時長，更新播放進度條的當前值
        musicPlayerViewModel.$currentDuration
            .sink { [weak self] duration in
                self?.trackDurationSlider.value = Float(duration)  // 將當前播放時長轉換為浮點數並設置為進度條的當前值
            }
            .store(in: &subscriptions)  // 將訂閱存入訂閱集合中
        
        // 監聽當前音軌名稱變化，更新音軌名稱標籤
        musicPlayerViewModel.$currentTrackName
            .sink { [weak self] trackName in
                self?.trackNameLabel.text = trackName  // 設置音軌名稱標籤的文本
            }
            .store(in: &subscriptions)  // 將訂閱存入訂閱集合中
        
        
        // 監聽音軌列表變化，在主線程上重新加載表格視圖
        musicPlayerViewModel.$tracks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.listTableView.reloadData()  // 重新加載表格視圖以反映新的音軌列表
            }
            .store(in: &subscriptions)  // 將訂閱存入訂閱集合中
        
        // 監聽加載狀態變化，在主線程上顯示或隱藏加載指示器
        musicPlayerViewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()  // 如果正在加載，顯示加載指示器
                } else {
                    self?.dismissLoading()  // 如果加載完成，隱藏加載指示器
                }
            }
            .store(in: &subscriptions)  // 將訂閱存入訂閱集合中
    }
    
    private func addTargets() {
        // 將播放/暫停按鈕的觸發目標設置為當前視圖控制器，點擊事件為 playPauseButtonTapped 方法
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        
    }
    
    
    
    @objc private func playPauseButtonTapped() {
        
        // 音樂暫停或繼續播放
        musicPlayerViewModel.pauseTrack()
        
    }
    
    // 點擊Live事件
    @objc public func liveButtonTapped() {
        
        presentWebViewController(urlString: "https://live-club.github.io/")
    }
    // 點擊Book事件
    @objc public func bookButtonTapped() {
        presentWebViewController(urlString: "https://dm-o.netlify.app/")
    }
    // 點擊Cat事件
    @objc public func catButtonTapped() {
        presentWebViewController(urlString: "https://roccce.github.io/")
    }
    
}



// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 返回表格視圖中的行數，如果音軌列表為空，顯示空視圖提示
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if musicPlayerViewModel.tracks.count == 0 {
            tableView.setEmptyView(title: "沒有找到音樂", message: "...")
        } else {
            tableView.restore()
        }
        return musicPlayerViewModel.tracks.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let trackCell = listTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MusicCell else {
            return UITableViewCell()
        }
        let trackList = musicPlayerViewModel.tracks
        trackCell.configureCell(track: trackList[indexPath.row])
        // 取消選中時的高亮效果
        trackCell.selectionStyle = .none
        
        return trackCell
    }
    
    // 返回指定行的行高
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    // 點擊表格視圖中的行時，顯示卡片視圖並開始播放音軌
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 確定索引路徑
        let rowIndex = musicPlayerViewModel.currentTrackIndex
        
        // 取消上一曲的選擇
        listTableView.cellForRow(at: IndexPath(row: rowIndex, section: 0) )?.setSelected(false, animated: false)
        
        // 顯示播放器
        musicPlayerView.isHidden = false
        
        // 播放當前選中的一曲
        musicPlayerViewModel.startPlay(trackIndex: indexPath.row)
    }
    
    // 取消標頭的顯示
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // 設置表頭高度
        return 0
    }
    
    func presentWebViewController(urlString: String) {

        // 將URL字符串轉換為 URL 對象
        guard let url = URL(string: urlString) else {
            // 如果URL字符串無效，可以進行錯誤處理或者返回
            print("Invalid URL string: \(urlString)")
            return
        }
        
        // 創建瀏覽器的實例，並傳入 URL
        let webViewController = EiteiWebController(url: url)
        webViewController.modalPresentationStyle = .custom
        webViewController.transitioningDelegate = self
        present(webViewController, animated: true, completion: nil)
    }
    
    // 自定義轉場
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return EiteiPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

