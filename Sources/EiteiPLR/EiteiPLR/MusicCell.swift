//
//  TrackViewCell.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/10.
//

#if canImport(UIKit)
import UIKit
#endif
import SnapKit

class MusicCell: UITableViewCell {
    
    // MARK: - View Model
    
    let musicPlayerViewModel = MusicViewModel()
    
    // MARK: - Views
    
    public lazy var trackNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .eiteiGray
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left // 文本居左對齊
        return label
    }()
    
    private lazy var trackArtistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .eiteiLightGray // 使用淺灰色作為文本顏色
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left // 文本居左對齊
        return label
    }()
    
    public lazy var waveformIcon: UIButton = {
        let button = UIButton()
        button.tintColor = .eiteiBlue
        let image = UIImage(systemName: "waveform", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 289)))
        button.setImage(image, for: .normal) //
        button.isHidden = true // 預設隱藏
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical // 垂直方向排列
        view.spacing = 4 // 間距
        view.addArrangedSubview(trackNameLabel) // 添加曲目名稱標籤
        view.addArrangedSubview(trackArtistLabel) // 添加藝術家標籤
        return view
    }()
    
    private lazy var stackCardView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal // 水平方向排列
        view.distribution = .fill // 填充
        view.alignment = .center // 中心對齊
        view.spacing = 18 // 間距
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addArrangedSubview(stackView) // 添加垂直堆疊視圖
        view.addArrangedSubview(waveformIcon) // 添加波形圖示按鈕
        
        waveformIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(28)
            make.width.equalTo(45)
        }
        
        return view
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup Views
    
    private func setupViews() {
        contentView.addSubview(stackCardView)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        
        stackCardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5) // 四边边距为多少
        }
    }
    
    // MARK: - Configure Cell
    
    func configureCell(track: GitHubFile) {
        self.trackNameLabel.text = track.name // 設置曲目名稱文本
        self.trackArtistLabel.text = track.artist // 設置藝術家名稱文本
        self.backgroundColor = .clear // 背景透明
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            trackNameLabel.textColor = .eiteiBlue
            waveformIcon.isHidden = false // 選中時顯示波形圖示
        } else {
            trackNameLabel.textColor = .eiteiGray
            waveformIcon.isHidden = true // 非選中時隱藏波形圖示
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil // 重用前清空曲目名稱文本
        trackArtistLabel.text = nil // 重用前清空藝術家名稱文本
    }
}
