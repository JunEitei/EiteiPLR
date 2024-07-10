//
//  TrackViewCell.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/10.
//

#if canImport(UIKit)
import UIKit
// 在这里使用 UIKit
#endif

class MusicCell: UITableViewCell {
  
  // MARK: - View Model
  
  /// ViewModel 實例，用於處理音樂播放相關邏輯。
  let musicPlayerViewModel = MusicViewModel()
  
  // MARK: - Views
  
  /// 顯示曲目名稱的標籤。
  public lazy var trackNameLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor(cgColor: .init(red: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1)) // 使用深灰色作為文本顏色
    label.font = .systemFont(ofSize: 16, weight: .medium) // 設置字體為系統 16 号中等粗體
    label.textAlignment = .left // 文本居左對齊
    
    return label
  }()
  
  /// 顯示曲目藝術家的標籤。
  private lazy var trackArtistLabel: UILabel = {
    let label = UILabel()
    label.textColor = .lightGray // 使用淺灰色作為文本顏色
    label.font = .systemFont(ofSize: 14, weight: .medium) // 設置字體為系統 14 号中等粗體
    label.textAlignment = .left // 文本居左對齊
    
    return label
  }()
  
  /// 波形圖示按鈕，用於顯示音樂波形。
  public lazy var waveformIcon: UIButton = {
    let button = UIButton()
    button.tintColor = .systemBlue // 使用系統藍色作為圖示顏色
    let image = UIImage(systemName: "waveform", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 24))) // 使用系統波形圖示，大小為 24
    button.setImage(image, for: .normal) // 設置圖示為正常狀態的波形圖示
    button.isHidden = true // 預設隱藏
    
    return button
  }()
  
  /// 包含曲目名稱和藝術家標籤的垂直堆疊視圖。
  private lazy var stackView: UIStackView = {
    let view = UIStackView()
    view.axis = .vertical // 垂直方向排列
    view.spacing = 0 // 間距為 0
    view.addArrangedSubview(trackNameLabel) // 添加曲目名稱標籤
    view.addArrangedSubview(trackArtistLabel) // 添加藝術家標籤
    
    return view
  }()
  
  /// 包含堆疊視圖和波形圖示按鈕的水平堆疊視圖。
  private lazy var stackCardView: UIStackView = {
    let view = UIStackView()
    view.axis = .horizontal // 水平方向排列
    view.distribution = .equalSpacing // 等間距分佈
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addArrangedSubview(stackView) // 添加垂直堆疊視圖
    view.addArrangedSubview(waveformIcon) // 添加波形圖示按鈕
    
    return view
  }()
  
  // MARK: - Functions
  
  /// 配置 cell，設置曲目顯示的數據。
  func configureCell(track: GitHubFile) {
    self.trackNameLabel.text = track.name // 設置曲目名稱文本
      self.trackArtistLabel.text = track.artist// 設置藝術家名稱文本
    
    self.addSubview(stackCardView) // 添加堆疊視圖到 cell
    stackCardView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 10, right: 16)) // 設置堆疊視圖的邊距
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // 根據選中狀態設置文本顏色和波形圖示顯示狀態
    if selected {
      trackNameLabel.textColor = .systemBlue // 選中時文本顏色設置為系統藍色
      waveformIcon.isHidden = false // 選中時顯示波形圖示
    } else {
      trackNameLabel.textColor = UIColor(cgColor: .init(red: 34/255.0, green: 34/255.0, blue: 34/255.0, alpha: 1)) // 非選中時文本顏色設置為深灰色
      waveformIcon.isHidden = true // 非選中時隱藏波形圖示
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    trackNameLabel.text = nil // 重用前清空曲目名稱文本
    trackArtistLabel.text = nil // 重用前清空藝術家名稱文本
  }
}
