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

final class DeezerAPI {
  
  
  // 從 Deezer API 中獲取指定藝術家的前 15 首熱門歌曲列表。
  func fetchTracks() -> AnyPublisher<[Datum], Error> {
    let url = URL(string: "https://api.deezer.com/artist/6241820/top?limit=15")!
    
    return URLSession.shared.dataTaskPublisher(for: url)
      .tryMap { element -> Data in
        guard let response = element.response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
          throw URLError(.badServerResponse)
        }
        return element.data
      }
      .decode(type: Track.self, decoder: JSONDecoder())
      .map { $0.data }
      .eraseToAnyPublisher()
  }
  
  // 通過藝術家名稱搜索 Deezer API 中的歌曲。
  func searchTracksByArtist(name: String) -> AnyPublisher<[Datum], Error> {
    let url = URL(string: "https://api.deezer.com/search?q=\(name)")!
    
    return URLSession.shared.dataTaskPublisher(for: url)
      .tryMap { element -> Data in
        guard let response = element.response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
          throw URLError(.badServerResponse)
        }
        return element.data
      }
      .decode(type: Track.self, decoder: JSONDecoder())
      .map { $0.data }
      .eraseToAnyPublisher()
  }
}
