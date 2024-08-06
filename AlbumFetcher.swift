//
//  AlbumFetcher.swift
//  EiteiPLR
//
//  Created by damao on 2024/8/6.
//

import Foundation


class AlbumFetcher {
    
    // 定義 GitHubAlbum 結構體
    struct GitHubAlbum: Codable {
        var id: Int?
        let name: String
        let url: String
    }
    
    // 定義函數來獲取和解析數據
    func fetchGitHubAlbums(completion: @escaping ([GitHubAlbum]?) -> Void) {
        // 設定 API URL
        guard let url = URL(string: "https://api.github.com/repos/JunEitei/Music/contents") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        // 創建 URL 請求
        let request = URLRequest(url: url)
        
        // 使用 URLSession 發送請求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // 檢查是否有錯誤
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // 確保數據不為 nil
            guard let data = data else {
                print("No data")
                completion(nil)
                return
            }
            
            // 解析數據
            do {
                let decoder = JSONDecoder()
                let albums = try decoder.decode([GitHubAlbum].self, from: data)
                completion(albums)
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        // 啟動任務
        task.resume()
    }
}

