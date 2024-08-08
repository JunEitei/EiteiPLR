//
//  GitHubResponse.swift
//  EiteiPLR
//
//  Created by damao on 2024/8/8.
//

// MARK: - GitHubResponse

/// 代表 GitHub 文件上传 API 的响应结构
struct GitHubResponse: Codable {
    let content: Content?  // 上傳的文件內容資訊
    let commit: Commit?  // 提交資訊
    
    // MARK: - Content
    /// 代表上傳的文件內容資訊
    struct Content: Codable {
        let name: String  // 文件名稱
        let path: String  // 文件路徑
        let sha: String  // 文件的 SHA-1 哈希
        let size: Int  // 文件大小（以字節為單位）
        let url: String  // 文件在 GitHub API 中的 URL
        let html_url: String  // 文件在 GitHub 網站上的 HTML URL
        let git_url: String  // 文件在 GitHub Git 服務中的 URL
        let download_url: String?  // 文件的下載 URL（如果適用）
        let type: String  // 內容類型（通常是 "file" 或 "dir"）
        let _links: Links  // 相關連結
        
        // MARK: - Links
        /// 代表與上傳內容相關的連結
        struct Links: Codable {
            let git: String  // Git 服務的 URL
            let selfLink: String  // 自引用的 URL
            let html: String  // HTML 頁面的 URL
            
            // 用來指定自定義的鍵
            enum CodingKeys: String, CodingKey {
                case git
                case selfLink = "self"
                case html
            }
        }
    }
    
    // MARK: - Commit
    /// 代表提交資訊
    struct Commit: Codable {
        let sha: String  // 提交的 SHA-1 哈希
        let node_id: String  // 提交的 Node ID
        let url: String  // 提交在 GitHub API 中的 URL
        let html_url: String  // 提交在 GitHub 網站上的 HTML URL
        let author: Author  // 提交作者資訊
        let committer: Committer  // 提交者資訊
        let message: String  // 提交訊息
        let tree: Tree  // 提交樹資訊
        let parents: [Parent]  // 父提交資訊
        
        // MARK: - Author
        /// 代表提交作者資訊
        struct Author: Codable {
            let name: String  // 作者名稱
            let email: String  // 作者電子郵件
            let date: String  // 提交日期
        }
        
        // MARK: - Committer
        /// 代表提交者資訊
        struct Committer: Codable {
            let name: String  // 提交者名稱
            let email: String  // 提交者電子郵件
            let date: String  // 提交日期
        }
        
        // MARK: - Tree
        /// 代表提交樹資訊
        struct Tree: Codable {
            let sha: String  // 提交樹的 SHA-1 哈希
            let url: String  // 提交樹在 GitHub API 中的 URL
        }
        
        // MARK: - Parent
        /// 代表父提交資訊
        struct Parent: Codable {
            let sha: String  // 父提交的 SHA-1 哈希
            let url: String  // 父提交在 GitHub API 中的 URL
            let html_url: String  // 父提交在 GitHub 網站上的 HTML URL
        }
    }
}
