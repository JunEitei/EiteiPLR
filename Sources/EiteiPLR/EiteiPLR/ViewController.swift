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

public class ViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>() // 訂閱集合，用於管理Combine框架的訂閱
    private var timer: Timer? // 定時器，用於延遲搜索輸入
    
    let musicPlayerViewModel = MusicViewModel() // 音樂播放器的視圖模型

    
    private let titleTopLabel: UILabel = {
        let label = UILabel()
        label.text = "Listen Now" // 標題標籤文字內容
        label.textColor = .black // 文字顏色
        label.font = .systemFont(ofSize: 26, weight: .bold) // 字體和粗細設置
        
        return label
    }()
    
    let listTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear // 設置表格視圖的背景色為透明
        tableView.contentInset.bottom = 70 // 設置表格視圖內容底部的內邊距
        
        return tableView
    }()
    
    private lazy var trackNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray // 文字顏色設置
        label.font = .systemFont(ofSize: 16, weight: .medium) // 字體和粗細設置
        label.textAlignment = .left // 文字對齊方式
        
        return label
    }()
    
    private lazy var trackArtistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray // 文字顏色設置
        label.font = .systemFont(ofSize: 14, weight: .medium) // 字體和粗細設置
        label.textAlignment = .left // 文字對齊方式
        
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical // 垂直排列的堆疊視圖
        view.spacing = 0 // 子視圖間距
        
        view.addArrangedSubview(trackNameLabel) // 將歌曲名稱標籤添加到堆疊視圖
        view.addArrangedSubview(trackArtistLabel) // 將歌手名稱標籤添加到堆疊視圖
        
        return view
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black // 圖示顏色設置為黑色
        let image = UIImage(systemName: "pause.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 28))) // 設置播放/暫停按鈕圖示
        button.setImage(image, for: .normal) // 設置按鈕的圖示
        
        return button
    }()
    
    private let trackDurationSlider: UISlider = {
        let slider = UISlider()
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
    
    lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white // 設置卡片視圖的背景色為白色
        view.layer.cornerRadius = 12 // 設置卡片視圖的圓角半徑
        
        view.addSubview(stackCardView) // 將堆疊卡片視圖添加到卡片視圖
        stackCardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 16, bottom: 12, right: 16)) // 設置堆疊卡片視圖的邊界約束
        }
        
        view.addSubview(trackDurationSlider) // 將歌曲持續時間滑塊添加到卡片視圖
        trackDurationSlider.snp.makeConstraints { make in
            make.top.equalTo(stackCardView.snp.bottom).offset(-6) // 設置滑塊與堆疊卡片視圖的底部對齊
            make.left.right.equalToSuperview() // 設置滑塊與卡片視圖的左右對齊
        }
        
        view.clipsToBounds = true // 裁剪超出邊界的內容
        
        let container = UIView()
        container.layer.shadowColor = UIColor.lightGray.cgColor // 設置容器視圖的陰影顏色
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
    }
    
    // MARK: - Private Methods
    private func setUI() {
        view.backgroundColor = .systemBackground
        

        // 添加和配置 titleTopLabel
        view.addSubview(titleTopLabel)
        titleTopLabel.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(18)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // 添加和配置 listTableView
        view.addSubview(listTableView)
        listTableView.snp.makeConstraints { make in
            make.top.equalTo(titleTopLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        // 添加和配置 cardView
        view.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    private func showLoading() {
        // 隱藏表格視圖以顯示加載警報框
        listTableView.isHidden = true
        
        // 創建帶有活動指示器的警報框
        let alertController = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
        
        // 創建並配置活動指示器
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicator.isUserInteractionEnabled = false
        
        // 設置警報框高度約束
        alertController.view.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        // 添加活動指示器到警報框視圖
        alertController.view.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.centerX.equalTo(alertController.view)
            make.top.equalTo(alertController.view.snp.centerY).offset(5)
        }
        
        // 顯示警報框
        present(alertController, animated: true, completion: nil)
    }
    
    private func showError(message: String) {
        // 創建一個警報框，顯示錯誤消息
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        // 添加“OK”按鈕動作，點擊後關閉警報框
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        
        // 顯示警報框
        present(alertController, animated: true, completion: nil)
    }
    
    private func dismissLoading() {
        // 顯示表格視圖，並關閉正在顯示的警報框
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
        
        // 監聽當前音軌藝術家變化，更新音軌藝術家標籤
        musicPlayerViewModel.$currentTrackArtist
            .sink { [weak self] trackArtist in
                self?.trackArtistLabel.text = trackArtist  // 設置音軌藝術家標籤的文本
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
        musicPlayerViewModel.pauseTrack()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 返回表格視圖中的行數，如果音軌列表為空，顯示空視圖提示
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if musicPlayerViewModel.tracks.count == 0 {
            tableView.setEmptyView(title: "Song not available", message: "Try searching again using a different spelling or keyword")
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
        
        // 兩種橙色交替
        let alternatingColors: [UIColor] = [
            .eiteiOrange,
            .eiteiSuperOrange
        ]
        
        // 根据 indexPath.row 的值选择相间的颜色
        let colorIndex = indexPath.row % alternatingColors.count
        trackCell.backgroundColor = alternatingColors[colorIndex]
        
        return trackCell
    }
    
    // 返回指定行的行高
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // 點擊表格視圖中的行時，顯示卡片視圖並開始播放音軌
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cardView.isHidden = false
        musicPlayerViewModel.startPlay(trackIndex: indexPath.row)
    }
    
}

// MARK: - UITableView
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
        self.separatorStyle = .singleLine
    }
}
