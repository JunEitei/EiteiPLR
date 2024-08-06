

#if canImport(UIKit)
import UIKit
#endif

#if canImport(Foundation)
import Foundation
#endif

import MediaPlayer
import Combine

// 协议定义了基本的音乐播放控制方法
protocol EiteiMusicProtocol {
    func fetchTracks() // 获取曲目列表
    func startPlay(trackIndex: Int) // 开始播放指定索引的歌曲
    func pauseTrack() // 暂停当前播放的歌曲
}

// 播放模式枚举，定义了单曲循环和列表循环两种模式
enum PlayMode: String {
    case single = "single" // 单曲循环
    case loop = "loop" // 列表循环
}

    
// 音乐视图模型类，遵循 EiteiMusicProtocol 协议
final class EiteiMusicModel: EiteiMusicProtocol {
    
    // MARK: - 初始化方法
    // 使用依赖注入来初始化 githubAPI，并从用户默认设置中读取播放模式
    init(githubAPI: GithubAPI) {
        self.githubAPI = githubAPI
        self.playMode = PlayMode(rawValue: UserDefaults.standard.string(forKey: "playMode") ?? PlayMode.loop.rawValue) ?? .loop
    }
    
    // MARK: - 属性
    public let githubAPI: GithubAPI // GitHub API 实例，用于获取曲目列表
    
    // 使用 @Published 修饰的属性会自动触发视图更新
    @Published var isLoading = false // 是否正在加载中
    @Published var currentTrackIndex = 0 // 当前播放的歌曲索引
    @Published var maxCurrentDuration: Double = 0 // 当前歌曲的最大播放时长
    @Published var currentDuration: Double = 0 // 当前歌曲的当前播放时长
    @Published var isPlaying = false // 是否正在播放中
    @Published var currentTrackName: String = "" // 当前播放的歌曲名称
    @Published var currentTrackArtist: String = "" // 当前播放的歌手名称
    @Published var tracks: [GitHubFile] = [] // 歌曲列表
    @Published var playMode: PlayMode { // 播放模式
        didSet {
            // 当播放模式改变时，保存到用户默认设置中
            UserDefaults.standard.set(playMode.rawValue, forKey: "playMode")
        }
    }
    
    var subscriptions = Set<AnyCancellable>() // 用于管理 Combine 订阅的集合
    let musicPlayer = AVPlayer() // 音乐播放器实例
    
    // MARK: - 方法
    
    // 从 GitHub API 获取曲目列表
    func fetchTracks() {
        isLoading = true // 设置加载状态为 true
        githubAPI.fetchTracks()
            .sink(
                receiveCompletion: { status in
                    switch status {
                    case .finished:
                        self.isLoading = false // 数据加载完成，设置加载状态为 false
                        print("Completed")
                    case .failure(let error):
                        self.isLoading = false // 数据加载失败，设置加载状态为 false
                        print("Receiver error \(error)")
                    }
                },
                receiveValue: { tracks in
                    print("Data received")
                    self.tracks = tracks // 将接收到的曲目列表赋值给 tracks 属性
                    // 发送通知给界面刷新
                    NotificationCenter.default.post(name: Notification.Name("TracksUpdated"), object: nil)
                }
            )
            .store(in: &subscriptions) // 将订阅存储在 subscriptions 集合中，以便于管理
    }
    
    // 添加观察器，监听音乐播放器的状态和播放进度
    func addObservers() {
        // 监听播放结束事件
        NotificationCenter.default.addObserver(self, selector: #selector(trackDidEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: musicPlayer.currentItem)
        // 获取当前播放项目的时长，并赋值给 maxCurrentDuration
        if let duration = musicPlayer.currentItem?.asset.duration.seconds {
            self.maxCurrentDuration = duration
        }
        // 定期观察播放进度，每秒更新一次
        musicPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000), queue: DispatchQueue.main) { [weak self] (time) in
            self?.currentDuration = time.seconds // 更新当前播放时长
        }
    }
    
    // 音乐播放结束时的处理方法，根据播放模式选择下一步操作
    @objc func trackDidEnded() {
        if playMode == .single {
            // 单曲循环模式：将播放进度重置为初始位置，并继续播放
            musicPlayer.seek(to: CMTime.zero) { [weak self] _ in
                self?.musicPlayer.play()
            }
        } else {
            // 列表循环模式：播放下一首歌曲
            var newTrackIndex = currentTrackIndex
            if newTrackIndex == tracks.count - 1 {
                newTrackIndex = 0 // 如果当前是最后一首歌曲，切换到第一首
            } else {
                newTrackIndex += 1 // 否则切换到下一首
            }
            if tracks.isEmpty {
                pauseTrack() // 如果没有歌曲，暂停播放
            } else {
                startPlay(trackIndex: newTrackIndex) // 否则开始播放新的歌曲
            }
        }
    }
    
    // 继续播放当前暂停的歌曲
    func resumeTrack() {
        if musicPlayer.timeControlStatus == .paused {
            musicPlayer.play() // 如果当前是暂停状态，则继续播放
            isPlaying = true
        }
    }
    
    // 切换播放模式
    func togglePlayMode() {
        switch playMode {
        case .single:
            playMode = .loop // 从单曲循环切换到列表循环
        case .loop:
            playMode = .single // 从列表循环切换到单曲循环
        }
    }
    
    // 开始播放指定索引的歌曲
    func startPlay(trackIndex: Int) {
        if currentTrackIndex == trackIndex {
            // 如果当前索引与要播放的索引相同，不做任何操作
        } else {
            currentTrackIndex = trackIndex // 更新当前播放索引
            
            // 创建 URL 和 AVPlayerItem 实例，并开始播放
            let url = URL(string: tracks[trackIndex].download_url)
            let playerItem: AVPlayerItem = AVPlayerItem(url: url!)
            currentTrackName = tracks[trackIndex].name // 更新当前播放的歌曲名称
            currentTrackArtist = tracks[trackIndex].artist! // 更新当前播放的歌手名称
            musicPlayer.replaceCurrentItem(with: playerItem) // 替换当前播放项目
            musicPlayer.play() // 开始播放
            isPlaying = true
            addObservers() // 添加观察器
        }
    }
    
    // 暂停或继续播放当前歌曲
    func pauseTrack() {
        if musicPlayer.timeControlStatus == .playing {
            musicPlayer.pause() // 如果当前正在播放，则暂停
            isPlaying = false
        } else if musicPlayer.timeControlStatus == .paused {
            musicPlayer.play() // 如果当前是暂停状态，则继续播放
            isPlaying = true
        }
    }
    
    // 播放下一首歌曲
    func playNextTrack() {
        var newIndex = currentTrackIndex + 1
        if newIndex >= tracks.count {
            newIndex = 0 // 如果当前是最后一首歌曲，切换到第一首
        }
        startPlay(trackIndex: newIndex) // 开始播放新的歌曲
    }
    
    // 播放上一首歌曲
    func playPreviousTrack() {
        var newIndex = currentTrackIndex - 1
        if newIndex < 0 {
            newIndex = tracks.count - 1 // 如果当前是第一首歌曲，切换到最后一首
        }
        startPlay(trackIndex: newIndex) // 开始播放新的歌曲
    }
    
    // 跳转到指定时间，并在跳转后继续播放（如果当前正在播放）
    func seekToTime(time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 1000)
        musicPlayer.seek(to: cmTime) { [weak self] _ in
            if self?.isPlaying == true {
                self?.musicPlayer.play() // 跳转后继续播放
            }
        }
    }
    
    // 析构方法，清理订阅
    deinit {
        subscriptions.forEach { $0.cancel() }
    }
}
