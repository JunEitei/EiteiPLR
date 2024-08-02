import UIKit
import SnapKit
import Combine
import AVFoundation

class EiteiPlayerController: UIViewController {
    
    // 播放器模型
    var musicPlayerViewModel: MusicViewModel!
    
    // 标题标签
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "从此刻起"
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.textColor = .white
        return label
    }()
    
    // 副标题标签
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "布农孩子的传承与跨界"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.systemBackground
        return label
    }()
    
    // 时间滑杆
    let timeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        slider.isContinuous = true
        slider.tintColor = UIColor(red: 0.866, green: 0.689, blue: 0.932, alpha: 1)
        return slider
    }()
    
    // 播放/暂停按钮
    let playPauseImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "pause.fill"))
        imageView.tintColor = UIColor(red: 0.866, green: 0.689, blue: 0.932, alpha: 1)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    // 封面图像
    let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "third 1"))
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var subscriptions = Set<AnyCancellable>()
    private var isSeeking = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(timeSlider)
        view.addSubview(playPauseImageView)
        view.addSubview(imageView)
        
        // 添加点击手势识别器到播放/暂停图标
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playPauseTapped))
        playPauseImageView.addGestureRecognizer(tapGesture)
        
        // 添加滑杆事件
        timeSlider.addTarget(self, action: #selector(timeChange(_:)), for: .valueChanged)
        timeSlider.addTarget(self, action: #selector(seekStarted(_:)), for: .touchDown)
        timeSlider.addTarget(self, action: #selector(seekEnded(_:)), for: [.touchUpInside, .touchUpOutside])
        
        setupConstraints()
        
        // 监听播放器的进度更新
        musicPlayerViewModel.$currentDuration
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentDuration in
                guard let self = self else { return }
                let duration = self.musicPlayerViewModel.maxCurrentDuration
                if duration > 0 && !self.isSeeking {
                    self.timeSlider.maximumValue = Float(duration)
                    self.timeSlider.value = Float(currentDuration)
                }
            }
            .store(in: &subscriptions)
    }
    
    // 时间变更处理
    @objc func timeChange(_ sender: UISlider) {
        // 不更新音乐进度，等待拖动结束后再更新
        if isSeeking {
            return
        }
        let newTime = Double(sender.value)
        musicPlayerViewModel.seekToTime(time: newTime)
    }
    
    // 用户开始拖动滑杆
    @objc func seekStarted(_ sender: UISlider) {
        isSeeking = true
    }
    
    // 用户结束拖动滑杆
    @objc func seekEnded(_ sender: UISlider) {
        isSeeking = false
        let newTime = Double(sender.value)
        musicPlayerViewModel.seekToTime(time: newTime)
    }
    
    // 播放/暂停按钮点击处理
    @objc func playPauseTapped() {
        // 音乐暂停或继续播放
        musicPlayerViewModel.pauseTrack()
        
        if musicPlayerViewModel.isPlaying {
            // 如果正在播放，切换到暂停图标
            playPauseImageView.image = UIImage(systemName: "pause.fill")
        } else {
            // 如果暂停中，切换到播放图标
            playPauseImageView.image = UIImage(systemName: "play.fill")
        }
    }
    
    // 设置布局约束
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(421)
            make.leading.equalToSuperview().offset(54)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(11)
            make.leading.equalToSuperview().offset(54)
        }
        
        timeSlider.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
        }
        
        playPauseImageView.snp.makeConstraints { make in
            make.top.equalTo(timeSlider.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(80)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.height.equalTo(imageView.snp.width) // 保持正方形
        }
    }
}
