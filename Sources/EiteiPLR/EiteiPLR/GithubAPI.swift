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

// MARK: - GitHubAlbum
struct GitHubAlbum: Codable {
    var id: Int?
    let name: String
    let url: String
}


public final class GithubAPI {
    
    // 網絡連接實例
    private var session: Session
    
    // 網路狀態監聽器
    private let reachability = try! Reachability()
    
    private var baseURL: String
    
    // 定義一個全局變量來保存音樂的總數量
    var totalMusicCount: Int = 0
    
    // 删除单例模式，允许外部创建实例
    public init(baseURL: String) {
        
        self.baseURL = baseURL
        
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = Session(configuration: configuration, interceptor: NetworkRetrier())
        
        // 監聽網絡狀態變化
        reachability.whenReachable = { _ in
            print("網絡已連接，開始自動重試請求...")
            
            // 發送通知給界面刷新
            NotificationCenter.default.post(name: Notification.Name("NetworkResume"), object: nil)
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
    
    
    
    // 檢索文件
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
    
    // 設置新的 baseURL
    public func setBaseURL(_ newBaseURL: String) {
        self.baseURL = newBaseURL
        
        // 重新配置 Session 实例
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = Session(configuration: configuration, interceptor: NetworkRetrier())
        
        print("Updated baseURL to \(newBaseURL)")
    }
    
    // 讀取全部音軌同時統計數量
    func fetchTracks() -> AnyPublisher<[GitHubFile], Error> {
        fetchFiles()
            .map { files in
                // 在這裡計算音樂的總數量
                self.totalMusicCount = files.count
                
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
