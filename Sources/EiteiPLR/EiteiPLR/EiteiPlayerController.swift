import UIKit
import SnapKit

class EiteiPlayerController: UIViewController {
    
    let titleLabel1: UILabel = {
        let label = UILabel()
        label.text = "從此刻起"
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.textColor = .white
        return label
    }()
    
    let titleLabel2: UILabel = {
        let label = UILabel()
        label.text = "布農孩子的傳承與跨界"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.systemBackground
        return label
    }()
    
    let startTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.systemBackground
        return label
    }()
    
    let endTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "05:00"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.systemBackground
        return label
    }()
    

    let timeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = -1.5
        slider.maximumValue = 1
        slider.value = -1.5
        slider.tintColor = UIColor(red: 0.866, green: 0.689, blue: 0.932, alpha: 1)
        slider.addTarget(EiteiPlayerController.self, action: #selector(timeChange(_:)), for: .valueChanged)
        return slider
    }()
    

    let playPauseImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "play.fill"))
        imageView.tintColor = UIColor(red: 0.866, green: 0.689, blue: 0.932, alpha: 1)
        imageView.isUserInteractionEnabled = true // Enable interaction
        return imageView
    }()
    
    let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 1
        slider.tintColor = UIColor(red: 0.866, green: 0.689, blue: 0.932, alpha: 1)
        slider.addTarget(EiteiPlayerController.self, action: #selector(volumeChange(_:)), for: .valueChanged)
        return slider
    }()
    
    let volumeLowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "volume.1"))
        imageView.tintColor = UIColor(red: 0.883, green: 0.875, blue: 0.962, alpha: 1)
        return imageView
    }()
    
    let volumeHighImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "volume.3"))
        imageView.tintColor = UIColor(red: 0.883, green: 0.875, blue: 0.962, alpha: 1)
        return imageView
    }()
    
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
        
        // Add tap gesture recognizer to playPauseImageView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playPauseTapped))
        playPauseImageView.addGestureRecognizer(tapGesture)
        
        setupConstraints()
    }
    
    @objc func timeChange(_ sender: UISlider) {
        // Handle time change
    }

    
    @objc func volumeChange(_ sender: UISlider) {
        // Handle volume change
    }
    
    @objc func playPauseTapped() {
        // Handle play/pause button tapped
        if playPauseImageView.image == UIImage(systemName: "play.fill") {
            playPauseImageView.image = UIImage(systemName: "pause.fill")
        } else {
            playPauseImageView.image = UIImage(systemName: "play.fill")
        }
    }
    
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
