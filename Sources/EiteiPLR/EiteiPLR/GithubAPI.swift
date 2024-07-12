//
//  githubAPI.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/11.
//

#if canImport(Foundation)
import Foundation
#endif

import Combine
import Alamofire
import Reachability

// MARK: - GitHubFile
struct GitHubFile: Codable {
    var id: Int?
    let name: String
    let path: String
    let sha: String
    let size: Int
    let url: String
    let html_url: String
    let git_url: String
    let download_url: String
    let type: String
    var title: String?
    var preview: String?
    var artist: String?
    var album: String?
}


public final class GithubAPI {
    
    // 網絡連接實例
    private let session: Session
    
    private let reachability = try! Reachability()
    

    // 定義一個全局變量來保存音樂的總數量
    var totalMusicCount: Int = 0
    
    // 單例實例
    static let shared = GithubAPI()
    
    // 基礎URL，用於獲取GitHub倉庫中的內容
    private let baseURL = "https://api.github.com/repos/JunEitei/EiteiPLR/contents/Music"
    
    // 初始化方法中配置 Alamofire 會話（Session）
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = Session(configuration: configuration, interceptor: NetworkRetrier())
        
        // 監聽網絡狀態變化
        reachability.whenReachable = { _ in
            print("網絡已連接，開始自動重試請求...")
            // 在此處理重試邏輯，例如重新調用需要重試的請求
            // 這裡可以做一些邏輯來觸發重新請求
        }
        
        reachability.whenUnreachable = { _ in
            print("網絡已斷開")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("無法啟動網絡狀態監聽器：\(error)")
        }
    }
    
    
    // 方法：fetchFiles
    func fetchFiles() -> AnyPublisher<[GitHubFile], Error> {
        let url = URL(string: baseURL)!
        return Future<[GitHubFile], Error> { promise in
            self.session.request(url)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let files = try JSONDecoder().decode([GitHubFile].self, from: data)
                            promise(.success(files))
                        } catch {
                            promise(.failure(error))
                        }
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    // 讀取全部音軌同時統計數量
    func fetchTracks() -> AnyPublisher<[GitHubFile], Error> {
        fetchFiles()
            .map { files in
                // 在這裡計算音樂的總數量
                self.totalMusicCount = files.count
                
                // 發送通知給 ViewController
                NotificationCenter.default.post(name: Notification.Name("MusicCountUpdated"), object: self.totalMusicCount)
                
                return self.filterAudioFiles(files)
            }
            .map { audioFiles in
                self.mapFilesToGitHubFile(audioFiles)
            }
            .eraseToAnyPublisher()
    }
    
    // 過濾音頻文件（支持.m4a和.mp3格式）
    private func filterAudioFiles(_ files: [GitHubFile]) -> [GitHubFile] {
        return files.filter { $0.type == "file" && ($0.name.hasSuffix(".m4a") || $0.name.hasSuffix(".mp3")) }
    }
    
    // 關聯到實體
    private func mapFilesToGitHubFile(_ files: [GitHubFile]) -> [GitHubFile] {
        return files.enumerated().map { index, file in
            var newFile = file
            newFile.id = index + 1
            newFile.title = file.name
            newFile.preview = file.download_url
            newFile.artist = "大毛"
            return newFile
        }
    }
}
