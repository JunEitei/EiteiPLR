import UIKit
import SnapKit

class AlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var collectionView: UICollectionView!  // 定義 UICollectionView 屬性
    var albums: [AlbumFetcher.GitHubAlbum] = []  // 更新 albums 屬性來存儲從 API 獲得的數據
    
    // 定義顏色數組
    var colors: [UIColor]  = [
        UIColor(red: 237/255, green: 37/255, blue: 78/255, alpha: 1.0),   // 顏色 1
        UIColor(red: 249/255, green: 220/255, blue: 92/255, alpha: 1.0),   // 顏色 2
        UIColor(red: 194/255, green: 234/255, blue: 189/255, alpha: 1.0),  // 顏色 3
        UIColor(red: 1/255, green: 25/255, blue: 54/255, alpha: 1.0),      // 顏色 4
        UIColor(red: 255/255, green: 184/255, blue: 209/255, alpha: 1.0)   // 顏色 5
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 創建 UICollectionViewFlowLayout 佈局
        let layout = AlbumCollectionViewLayout()
        
        // 創建 UICollectionView 並設置佈局
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        
        // 設置數據源和代理
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 註冊 cell 類別
        collectionView.register(AlbumCell.self, forCellWithReuseIdentifier: "AlbumCell")
        
        // 配置其他屬性
        collectionView.isPagingEnabled = true  // 設置啟用分頁
        collectionView.showsHorizontalScrollIndicator = false  // 隱藏水平滾動指示器
        
        // 添加到主視圖
        view.addSubview(collectionView)
        
        // 設置 collectionView 的約束
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()  // 設置 collectionView 的邊緣等於超級視圖的邊緣
        }
        
        // 獲取專輯數據並更新 collectionView
        fetchAlbumData()
    }
    
    // 獲取專輯數據並更新 collectionView
    private func fetchAlbumData() {
        let fetcher = AlbumFetcher()
        fetcher.fetchGitHubAlbums { [weak self] fetchedAlbums in
            if let fetchedAlbums = fetchedAlbums {
                // 在主線程中處理結果
                DispatchQueue.main.async {
                    self?.albums = fetchedAlbums
                    self?.collectionView.reloadData()  // 重新加載 collectionView 的數據
                }
            } else {
                print("No albums found or error occurred")
            }
        }
    }
    
    // 提供每個 cell 的內容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCell
        cell.layer.cornerRadius = 7.0  // 設置 cell 的圓角半徑
        
        // 使用從 API 獲得的數據填充 cell
        let album = albums[indexPath.row]
        cell.backgroundColor = colors[indexPath.row % colors.count]  // 設置 cell 背景顏色
        cell.albumNameLabel.text = album.name  // 設置專輯名稱
        cell.artistNameLabel.text = album.url  // 設置藝術家名稱或 URL
        
        return cell
    }
    
    // 返回 section 中的項目數量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count  // 返回從 API 獲得的專輯數量
    }
    
    // 處理 cell 點擊事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let albumName = albums[indexPath.row].name  // 獲取選中專輯的名稱
        print("Selected album: \(albumName)")  // 輸出選中專輯的名稱
    }
}
