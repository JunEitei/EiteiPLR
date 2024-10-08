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
import ProgressHUD

// MARK: - GitHubFile
// GitHubFile 結構體，用來表示從 GitHub 獲取的文件資訊
struct GitHubFile: Codable {
    var id: Int? // 文件的 ID，可選
    let name: String // 文件名
    let path: String // 文件路徑
    let sha: String // 文件的 SHA-1 哈希值
    let size: Int // 文件大小（以字節為單位）
    let url: String // 文件的原始 URL
    let html_url: String // 文件的 HTML 頁面 URL
    let git_url: String // 文件的 Git URL
    let download_url: String // 文件的下載 URL
    let type: String // 文件類型
    var title: String? // 文件標題，可選
    var preview: String? // 文件預覽 URL，可選
    var artist: String? // 文件的藝術家名，可選
    var album: String? // 文件的專輯名，可選
}

// 定義 GitHubAlbum 結構體，用來表示專輯資訊
struct GitHubAlbum: Codable {
    var id: Int? // 專輯的 ID，可選
    let name: String // 專輯名稱
    let url: String // 專輯的 URL
}


// 用於刪除
struct FileInfo: Decodable {
    let sha: String
}


public final class GithubAPI {
    // 網絡連接實例
    private var session: Session
    
    public let token = "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"
    
    
    // 網路狀態監聽器
    private let reachability = try! Reachability()
    
    public var baseURL: String!
    
    // 初始化方法，設定 baseURL 並設置網絡連接配置
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
    
    // 檢索音樂文件，支持自動重試
    func fetchFiles() -> AnyPublisher<[GitHubFile], Error> {
        let url = URL(string: baseURL)!
        
        return Future<[GitHubFile], Error> { promise in
            self.session.request(url)
                .validate()
                .responseDecodable(of: [GitHubFile].self) { response in
                    switch response.result {
                    case .success(let files):
                        promise(.success(files))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .retry(3) // 最多重試3次（立即重試）
        .catch { error -> AnyPublisher<[GitHubFile], Error> in
            return Future<[GitHubFile], Error> { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    // 在5秒後重試一次
                    self.fetchFiles().sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let retryError):
                            promise(.failure(retryError))
                        }
                    }, receiveValue: { files in
                        promise(.success(files))
                    }).cancel()
                }
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    // 設置新的 baseURL
    public func setBaseURL(_ newBaseURL: String) {
        self.baseURL = newBaseURL
        
        // 重新配置 Session 實例
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = Session(configuration: configuration, interceptor: NetworkRetrier())
        
        print("Updated baseURL to \(newBaseURL)")
    }
    
    // 讀取全部音軌
    func fetchTracks() -> AnyPublisher<[GitHubFile], Error> {
        // 顯示 ProgressHUD
        ProgressHUD.colorHUD = .white // 背景色白色
        ProgressHUD.colorAnimation = .eiteiPurple // 動畫為紫色
        ProgressHUD.fontStatus = .systemFont(ofSize: 18, weight: .ultraLight) // 專輯名稱字體
        ProgressHUD.animate(GithubAPI.extractSubstring(from: baseURL), .triangleDotShift) //　專輯名稱
        
        
        return fetchFiles()
            .map { files in
                return self.filterAudioFiles(files)
            }
            .map { audioFiles in
                self.mapFilesToGitHubFile(audioFiles)
            }
            .handleEvents(receiveCompletion: { _ in
                // 無論成功還是失敗，都隱藏 ProgressHUD
                ProgressHUD.dismiss()
            }, receiveCancel: {
                // 如果請求被取消，也隱藏 ProgressHUD
                ProgressHUD.dismiss()
            })
            .eraseToAnyPublisher()
    }
    
    // 過濾音頻文件（支持 .m4a 和 .mp3 格式）
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
    
    
    // 上傳文件方法
    func uploadFile(filePath: String, fileContent: Data, token: String, completion: @escaping (Result<GitHubResponse, Error>) -> Void) {
        // 將文件內容進行 Base64 編碼
        let base64Content = fileContent.base64EncodedString()
        
        // 設定提交消息，包括文件路徑
        let message = "Add new file at \(filePath)"
        
        // 調用實際上傳文件的方法，傳遞必要的參數，包括擁有者、儲存庫、文件路徑、提交消息、文件內容和 token
        uploadFile(path: filePath, message: message, content: base64Content, token: token, completion: completion)
    }
    
    private func uploadFile(path: String, message: String, content: String, token: String, completion: @escaping (Result<GitHubResponse, Error>) -> Void) {
        // 構造 GitHub API 的 URL，包括擁有者、儲存庫名和文件路徑，並進行URL編碼
        let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? path
        let url = baseURL + "/\(encodedPath)"
        
        // 設定 HTTP 請求的標頭，包括授權 token 和接受的內容類型
        let headers: HTTPHeaders = [
            "Authorization": "token \(token)",  // 設定授權標頭，包含個人訪問 token
            "Accept": "application/vnd.github.v3+json"  // 設定接受的內容類型為 GitHub API v3 的 JSON 格式
        ]
        
        // 設定要上傳的參數，包括提交消息、文件內容和提交者資訊
        let parameters: [String: Any] = [
            "message": message,  // 提交消息，用於描述此次更改
            "content": content,  // 文件內容，進行 Base64 編碼後上傳
            "committer": [  // 提交者的詳細資訊
                "name": "大毛",  // 提交者的名稱
                "email": "dadada.maomaomao@gmail.com"  // 提交者的電子郵件
                         ]
        ]
        
        // 使用 Alamofire 發送 PUT 請求來上傳文件
        AF.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(contentType: ["application/vnd.github.v3+json", "application/json"])  // 验证响应的内容类型
            .responseDecodable(of: GitHubResponse.self) { response in  // 解析響應為 GitHubResponse 類型
                switch response.result {
                case .success(let value):
                    // 請求成功，將結果傳遞給 completion 處理
                    completion(.success(value))
                case .failure(let error):
                    // 請求失敗，將錯誤傳遞給 completion 處理
                    completion(.failure(error))
                }
            }
    }
    
    // 定義函數來獲取和解析專輯數據2
    func fetchGitHubAlbums(completion: @escaping ([GitHubAlbum]?) -> Void) {
        // 設定 API URL
        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        // 使用 Alamofire 發送請求
        AF.request(url).validate().responseDecodable(of: [GitHubAlbum].self) { response in
            switch response.result {
            case .success(let albums):
                completion(albums)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    // 获取文件 SHA 值的方法
    func getFileSHA(from filePath: String, token: String, completion: @escaping (Result<String, Error>) -> Void) {
        // 编码文件路径
        guard let encodedPath = filePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            completion(.failure(NSError(domain: "Invalid file path", code: -1, userInfo: nil)))
            return
        }
        
        let url = removeRefQuery(from: baseURL) + "/\(encodedPath)"
        
        // 设置请求头
        let headers: HTTPHeaders = [
            "Authorization": "token \(token)",
            "Accept": "application/json"
        ]
        
        // 发送 GET 请求以获取文件的 SHA 值
        AF.request(url, method: .get, headers: headers)
            .validate()  // Validate status code to be 200-299
            .responseDecodable(of: FileInfo.self) { response in
                switch response.result {
                case .success(let fileInfo):
                    completion(.success(fileInfo.sha))
                case .failure(let error):
                    // Provide more detailed error information
                    if let data = response.data {
                        let responseString = String(data: data, encoding: .utf8) ?? "No response data"
                        print("Response data: \(responseString)")
                    }
                    completion(.failure(error))
                }
            }
    }
    
    
    // 从 URL 中截取专辑名称
    static func extractSubstring(from urlString: String) -> String? {
        // 查找 "contents" 的结尾位置
        guard let contentsRange = urlString.range(of: "contents") else {
            print("Unable to find 'contents' in the URL")
            return nil
        }
        
        // "contents" 的结尾位置
        let contentsEndIndex = urlString.index(contentsRange.upperBound, offsetBy: 0)
        
        // 查找问号的位置
        guard let questionMarkRange = urlString.range(of: "?", range: contentsEndIndex..<urlString.endIndex) else {
            print("Unable to find '?' after 'contents' in the URL")
            return nil
        }
        
        // 截取 "contents" 后到问号之间的字符
        let substring = urlString[contentsEndIndex..<questionMarkRange.lowerBound]
        
        // 转义和去掉最前面的斜杠
        let decodedString = substring.removingPercentEncoding?.trimmingCharacters(in: .init(charactersIn: "/"))
        
        return decodedString
    }
    
    // 清洗URL
    func removeRefQuery(from urlString: String) -> String {
        // 使用 URL 组件解析 URL 字符串
        guard var urlComponents = URLComponents(string: urlString) else {
            return urlString
        }
        
        // 移除 query 部分
        urlComponents.query = nil
        
        // 返回更新后的 URL 字符串
        return urlComponents.url?.absoluteString ?? urlString
    }
    
    
    // 删除文件的方法
    func deleteFile(from filePath: String, sha: String, message: String, token: String, completion: @escaping (Result<String, Error>) -> Void) {
        // 编码文件路径
        guard let encodedPath = filePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            completion(.failure(NSError(domain: "Invalid file path", code: -1, userInfo: nil)))
            return
        }
        
        let url = removeRefQuery(from: baseURL) + "/\(encodedPath)"
        
        // 设置请求头
        let headers: HTTPHeaders = [
            "Authorization": "token \(token)",
            "Accept": "application/vnd.github.v3+json"
        ]
        
        // 请求体
        let parameters: [String: Any] = [
            "message": message,
            "sha": sha
        ]
        
        // 发送 DELETE 请求
        AF.request(url, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200...204) // 验证状态码
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let responseString = String(data: data, encoding: .utf8) ?? "No response data"
                    completion(.success(responseString))
                case .failure(let error):
                    print("File delete failed: \(error.localizedDescription)")
                    if let data = response.data {
                        let responseString = String(data: data, encoding: .utf8) ?? "No response data"
                        print("Response data: \(responseString)")
                    }
                    completion(.failure(error))
                }
            }
    }
    
}
