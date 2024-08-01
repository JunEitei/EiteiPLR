import UIKit
import SnapKit

class EiteiPlayerController: UIViewController {
    
    // 播放器模型
    var musicPlayerViewModel : MusicViewModel!
    
    // 標題標籤
    let titleLabel1: UILabel = {
        let label = UILabel()
        label.text = "從此刻起"
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.textColor = .white
        return label
    }()
    
    // 副標題標籤
    let titleLabel2: UILabel = {
        let label = UILabel()
        label.text = "布農孩子的傳承與跨界"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.systemBackground
        return label
    }()
    
    // 開始時間標籤
    let startTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.systemBackground
        return label
    }()
    
    // 結束時間標籤
    let endTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "05:00"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.systemBackground
        return label
    }()
    
    // 時間滑桿
    let timeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = -1.5
        slider.maximumValue = 1
        slider.value = -1.5
        slider.tintColor = UIColor(red: 0.866, green: 0.689, blue: 0.932, alpha: 1)
        slider.addTarget(self, action: #selector(timeChange(_:)), for: .valueChanged)
        return slider
    }()
    
    // 播放/暫停按鈕
    let playPauseImageView: UIImageView = {
        
    let imageView = UIImageView(image: UIImage(systemName: "pause.fill"))
        imageView.tintColor = UIColor(red: 0.866, green: 0.689, blue: 0.932, alpha: 1)
        imageView.isUserInteractionEnabled = true // 啟用互動
        return imageView
    }()
    
    // 音量滑桿
    let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 1
        slider.tintColor = UIColor(red: 0.866, green: 0.689, blue: 0.932, alpha: 1)
        slider.addTarget(self, action: #selector(volumeChange(_:)), for: .valueChanged)
        return slider
    }()
    
    // 低音量圖標
    let volumeLowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "volume.1"))
        imageView.tintColor = UIColor(red: 0.883, green: 0.875, blue: 0.962, alpha: 1)
        return imageView
    }()
    
    // 高音量圖標
    let volumeHighImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "volume.3"))
        imageView.tintColor = UIColor(red: 0.883, green: 0.875, blue: 0.962, alpha: 1)
        return imageView
    }()
    
    // 封面圖像
    let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "third 1"))
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(titleLabel1)
        view.addSubview(titleLabel2)
        view.addSubview(startTimeLabel)
        view.addSubview(endTimeLabel)
        view.addSubview(timeSlider)
        view.addSubview(playPauseImageView)
        view.addSubview(volumeSlider)
        view.addSubview(volumeLowImageView)
        view.addSubview(volumeHighImageView)
        view.addSubview(imageView)
        
        // 添加點擊手勢識別器到播放/暫停圖標
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playPauseTapped))
        playPauseImageView.addGestureRecognizer(tapGesture)
        
        setupConstraints()
    }
    
    // 時間變更處理
    @objc func timeChange(_ sender: UISlider) {
        // 處理時間變更
    }

    // 音量變更處理
    @objc func volumeChange(_ sender: UISlider) {
        // 處理音量變更
    }
    
    // 播放/暫停按鈕點擊處理
    @objc func playPauseTapped() {

        // 音樂暫停或繼續播放
        musicPlayerViewModel.pauseTrack()
        
        if musicPlayerViewModel.isPlaying {
            // 如果正在播放，切換到暫停圖標
            playPauseImageView.image = UIImage(systemName: "pause.fill")
        } else {
            // 如果暫停中，切換到播放圖標
            playPauseImageView.image = UIImage(systemName: "play.fill")
        }
    }
    
    // 設置佈局約束
    func setupConstraints() {
        titleLabel1.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(421)
            make.leading.equalToSuperview().offset(54)
        }
        
        titleLabel2.snp.makeConstraints { make in
            make.top.equalTo(titleLabel1.snp.bottom).offset(11)
            make.leading.equalToSuperview().offset(54)
        }
        
        startTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(timeSlider.snp.bottom).offset(17)
            make.leading.equalToSuperview().offset(54)
        }
        
        endTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(timeSlider.snp.bottom).offset(17)
            make.trailing.equalToSuperview().offset(-54)
        }
        
        timeSlider.snp.makeConstraints { make in
            make.top.equalTo(titleLabel2.snp.bottom).offset(52)
            make.leading.equalToSuperview().offset(52)
            make.trailing.equalToSuperview().offset(-52)
            make.height.equalTo(30)
        }
        
        playPauseImageView.snp.makeConstraints { make in
            make.top.equalTo(timeSlider.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
            make.width.equalTo(29)
            make.height.equalTo(29)
        }
        
        volumeSlider.snp.makeConstraints { make in
            make.top.equalTo(playPauseImageView.snp.bottom).offset(30)
            make.leading.equalToSuperview().offset(72)
            make.trailing.equalToSuperview().offset(-72)
            make.height.equalTo(30)
        }
        
        volumeLowImageView.snp.makeConstraints { make in
            make.centerY.equalTo(volumeSlider)
            make.leading.equalToSuperview().offset(39)
            make.width.equalTo(27)
            make.height.equalTo(26)
        }
        
        volumeHighImageView.snp.makeConstraints { make in
            make.centerY.equalTo(volumeSlider)
            make.trailing.equalToSuperview().offset(-39)
            make.width.equalTo(27)
            make.height.equalTo(26)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(106)
            make.centerX.equalToSuperview()
            make.width.equalTo(314)
            make.height.equalTo(279)
        }
    }
}
