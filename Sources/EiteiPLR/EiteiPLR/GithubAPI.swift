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

final class githubAPI {
    
    // 定義一個全局變量來保存音樂的總數量
    var totalMusicCount: Int = 0
    
    // 单例实例
    static let shared = githubAPI()
    
    // 基础URL，用于获取GitHub仓库中的内容
    private let baseURL = "https://api.github.com/repos/JunEitei/EiteiPLR/contents/Music"
    
    // 私有初始化方法，防止外部实例化
    private init() {}
    
    // 方法：fetchFiles
    func fetchFiles() -> AnyPublisher<[GitHubFile], Error> {
        let url = URL(string: baseURL)!
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { element -> Data in
                guard let response = element.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: [GitHubFile].self, decoder: JSONDecoder())
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
