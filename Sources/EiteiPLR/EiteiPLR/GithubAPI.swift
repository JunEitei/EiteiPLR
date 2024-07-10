//
//  DeezerAPI.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/10.
//
#if canImport(Foundation)
import Foundation
#endif

import Combine

// MARK: - GitHubFile
// 负责解析GitHub API以获取音乐文件
struct GitHubFile: Codable {
    var id: Int?
    let name: String
    let path: String
    let sha: String
    let size: Int
    let url: String
    let html_url: String
    let git_url: String
    let download_url: String?
    let type: String
    var title: String?
    var preview: String?
    var artist: String?
    var album: String?
}


final class githubAPI {
    
    // 基础URL，用于获取GitHub仓库中的内容
    private let baseURL = "https://api.github.com/repos/JunEitei/EiteiPLR/contents/Music"
    
    // 方法：fetchFiles
    // 从GitHub仓库中获取所有文件
    // 返回类型：AnyPublisher<[GitHubFile], Error>
    // 使用Combine框架异步处理网络请求和数据解析
    func fetchFiles() -> AnyPublisher<[GitHubFile], Error> {
        // 创建URL实例
        let url = URL(string: baseURL)!
        
        // 使用URLSession创建数据任务发布者
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { element -> Data in
                // 检查HTTP响应状态码是否在200到299之间
                guard let response = element.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                // 返回数据
                return element.data
            }
            // 使用JSONDecoder解码数据为[GitHubFile]类型
            .decode(type: [GitHubFile].self, decoder: JSONDecoder())
            // 将发布者类型转换为AnyPublisher
            .eraseToAnyPublisher()
    }
    
    // 方法：fetchTracks
    // 获取所有 .m4a 文件并将它们映射到 GitHubFile 结构
    // 返回类型：AnyPublisher<[GitHubFile], Error>
    func fetchTracks() -> AnyPublisher<[GitHubFile], Error> {
        fetchFiles()
            // 过滤出所有 .m4a 文件
            .map { files in
                self.filterM4AFiles(files)
            }
            // 将 .m4a 文件映射到 GitHubFile 结构
            .map { m4aFiles in
                self.mapFilesToGitHubFile(m4aFiles)
            }
            // 将发布者类型转换为AnyPublisher
            .eraseToAnyPublisher()
    }
    
    // 私有方法：filterM4AFiles
    // 过滤出所有类型为文件且扩展名为 .m4a 的文件
    // 参数：files - [GitHubFile] - 要过滤的文件列表
    // 返回类型：[GitHubFile] - 过滤后的文件列表
    private func filterM4AFiles(_ files: [GitHubFile]) -> [GitHubFile] {
        return files.filter { $0.type == "file" && $0.name.hasSuffix(".m4a") }
    }
    
    // 私有方法：mapFilesToGitHubFile
    // 将 .m4a 文件映射到带有自定义属性的 GitHubFile 结构
    // 参数：files - [GitHubFile] - 要映射的文件列表
    // 返回类型：[GitHubFile] - 映射后的文件列表
    private func mapFilesToGitHubFile(_ files: [GitHubFile]) -> [GitHubFile] {
        return files.enumerated().map { index, file in
            // 创建文件副本并设置自定义属性
            var newFile = file
            newFile.id = index + 1 // 为每个文件分配唯一ID
            newFile.title = file.name // 使用文件名作为标题
            newFile.preview = file.download_url ?? "" // 使用下载URL作为预览URL
            newFile.artist = "大毛" // 设置艺术家名称
            newFile.album = "わたしも" // 设置专辑名称
            return newFile
        }
    }
}
