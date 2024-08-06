//
//  AlbumViewController.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/10.
//

import UIKit

class AlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var collectionView: UICollectionView!  // 定義 UICollectionView 屬性
    
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
    }
    
    // 定義顏色數組
    var colors: [UIColor]  = [
        UIColor(red: 237, green: 37, blue: 78),   // 顏色 1
        UIColor(red: 249, green: 220, blue: 92),   // 顏色 2
        UIColor(red: 194, green: 234, blue: 189),  // 顏色 3
        UIColor(red: 1, green: 25, blue: 54),      // 顏色 4
        UIColor(red: 255, green: 184, blue: 209)   // 顏色 5
    ]
    
    // 定義專輯數據數組
    var albums: [(name: String, artist: String)] = [
        ("Album 1", "Artist A"),   // 專輯 1
        ("Album 2", "Artist B"),   // 專輯 2
        ("Album 3", "Artist C"),   // 專輯 3
        ("Album 4", "Artist D"),   // 專輯 4
        ("Album 5", "Artist E")    // 專輯 5
    ]
    
    // 提供每個 cell 的內容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCell
        cell.layer.cornerRadius = 7.0  // 設置 cell 的圓角半徑
        cell.backgroundColor = colors[indexPath.row]  // 設置 cell 背景顏色
        cell.albumNameLabel.text = albums[indexPath.row].name  // 設置專輯名稱
        cell.artistNameLabel.text = albums[indexPath.row].artist  // 設置藝術家名稱
        return cell
    }
    
    // 返回 section 中的項目數量
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count  // 返回顏色數組的數量
    }
    
    // 處理 cell 點擊事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let albumName = albums[indexPath.row].name  // 獲取選中專輯的名稱
        print("Selected album: \(albumName)")  // 輸出選中專輯的名稱
    }
}
