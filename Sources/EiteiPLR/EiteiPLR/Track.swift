//
//  Track.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/10.
//

import Foundation

// MARK: - Track
/// 跟踪類型，表示從 Deezer API 中獲取的音樂曲目列表。
struct Track: Codable {
  let data: [Datum]    // 包含音樂曲目數據的數組
  let total: Int       // 總共的曲目數量
  let next: String?    // 下一頁數據的 URL
  
  enum CodingKeys: String, CodingKey {
    case data, total, next
  }
}

// MARK: - Datum
/// 數據類型，表示每個音樂曲目的具體數據。
struct Datum: Codable {
  let id: Int           // 曲目的唯一 ID
  let title: String     // 曲目的標題
  let preview: String   // 曲目的預覽音頻 URL
  let artist: Artist    // 曲目的藝術家信息
  let album: Album      // 曲目所屬的專輯信息
}

// MARK: - Album
/// 專輯類型，表示每個曲目所屬的專輯信息。
struct Album: Codable {
  let id: Int?          // 專輯的唯一 ID
  let title: String?    // 專輯的標題
  let cover: String?    // 專輯的封面圖片 URL
}

// MARK: - Artist
/// 藝術家類型，表示每個曲目的藝術家信息。
struct Artist: Codable {
  let id: Int?          // 藝術家的唯一 ID
  let name: String?     // 藝術家的名稱
  let picture: String?  // 藝術家的圖片 URL
}
