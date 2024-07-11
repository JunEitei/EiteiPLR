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
    
    public lazy var trackNameLabel: EiteiPaddedLabel = {
        let label = EiteiPaddedLabel()
        label.textColor = .eiteiGray
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left // 文本居左對齊
        return label
    }()
    
    private lazy var trackArtistLabel: EiteiPaddedLabel = {
        let label = EiteiPaddedLabel()
        label.textColor = .eiteiLightGray // 使用淺灰色作為文本顏色
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textAlignment = .left // 文本居左對齊
        return label
    }()
    
    public lazy var eiteiWaveView: EiteiWaveView = {
        let eiteiWaveView = EiteiWaveView()
        eiteiWaveView.isHidden = false // 預設隱藏
        eiteiWaveView.backgroundColor = .clear
        return eiteiWaveView
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
        view.addSubview(eiteiWaveView) // 添加波形圖示按鈕
        
        // 波形圖示佈局
        eiteiWaveView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(28)
            make.width.equalTo(45)
            make.right.equalToSuperview().offset(-10) // 靠近右边缘，并设置偏移量
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
        
        // 外部
        contentView.addSubview(stackCardView)
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        // 內部
        stackCardView.backgroundColor = .white
        stackCardView.layer.cornerRadius = 8

        // 添加阴影效果
        stackCardView.layer.shadowColor = UIColor.eiteiBlue.cgColor
        stackCardView.layer.shadowOffset = CGSize(width: 0, height: 4) // 陰影偏移量
        stackCardView.layer.shadowOpacity = 0.81 // 陰影透明度
        stackCardView.layer.shadowRadius = 4 // 陰影半径
        stackCardView.layer.cornerRadius = 8 // 陰影的圓角
                
        stackCardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5) // 四边边距
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
            eiteiWaveView.isHidden = false // 選中時顯示波形圖示
        } else {
            trackNameLabel.textColor = .eiteiGray
            eiteiWaveView.isHidden = true // 非選中時隱藏波形圖示
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil // 重用前清空曲目名稱文本
        trackArtistLabel.text = nil // 重用前清空藝術家名稱文本
    }


}
