//
//  ViewModel.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/10.
//

#if canImport(UIKit)
import UIKit
#endif

#if canImport(Foundation)
import Foundation
#endif
import MediaPlayer
import Combine

protocol ViewModelProtocol {
  func fetchTracks()
  func startPlay(trackIndex: Int)
  func pauseTrack()
}

final class ViewModel: ViewModelProtocol {
  
  // MARK: - Properties
  
  /// Deezer API 服務實例
  let deezerAPI = DeezerAPI()
  
  /// 是否正在加載中
  @Published var isLoading = false
  
  /// 當前播放的歌曲索引
  @Published var currentTrackIndex = 0
  
  /// 當前歌曲的最大播放時長
  @Published var maxCurrentDuration: Double = 0
  
  /// 當前歌曲的當前播放時長
  @Published var currentDuration: Double = 0
  
  /// 是否正在播放中
  @Published var isPlaying = false
  
  /// 當前播放的歌曲名稱
  @Published var currentTrackName: String = ""
  
  /// 當前播放的歌手名稱
  @Published var currentTrackArtist: String = ""
  
  /// 歌曲列表
  @Published var tracks: [Datum] = []
  
  /// 訂閱集合，用於管理 Combine 訂閱
  var subscriptions = Set<AnyCancellable>()
  
  /// 音樂播放器實例
  let musicPlayer = AVPlayer()
  
  // MARK: - Functions
  
  /// 從 Deezer API 中獲取歌曲列表。
  ///
  /// 調用該方法後，使用 Combine 機制來處理異步數據流。
  func fetchTracks() {
    isLoading = true
    deezerAPI.fetchTracks()
      .sink(
        receiveCompletion: { status in
          switch status {
          case .finished:
            self.isLoading = false
            print("Completed")
            break
          case .failure(let error):
            self.isLoading = false
            print("Receiver error \(error)")
            break
          }
        },
        receiveValue: { tracks in
          print("Data received")
          self.tracks = tracks
        }
      )
      .store(in: &subscriptions)
  }
  
  /// 根據藝術家名稱從 Deezer API 中搜索歌曲。
  ///
  /// - Parameter name: 要搜索的藝術家名稱
  /// 調用該方法後，使用 Combine 機制來處理異步數據流。
  func searchArtistName(name: String) {
    isLoading = true
    deezerAPI.searchTracksByArtist(name: name)
      .sink(
        receiveCompletion: { status in
          switch status {
          case .finished:
            self.isLoading = false
            print("Completed")
            break
          case .failure(let error):
            self.isLoading = false
            print("Receiver error \(error)")
            break
          }
        },
        receiveValue: { tracks in
          print("Data received")
          self.tracks = tracks
        }
      )
      .store(in: &subscriptions)
  }
  
  /// 添加觀察器，監聽音樂播放器的狀態和播放進度。
  ///
  /// 該方法將觀察音樂播放結束事件和播放進度的變化。
  func addObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(trackDidEnded), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: musicPlayer.currentItem)
    if let duration = musicPlayer.currentItem?.asset.duration.seconds {
      self.maxCurrentDuration = duration
    }
    musicPlayer.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000), queue: DispatchQueue.main) { (time) in
      self.currentDuration = time.seconds
    }
  }
  
  /// 音樂播放結束時的處理方法。
  ///
  /// 該方法將自動切換到下一首歌曲或者暫停播放。
  @objc func trackDidEnded() {
    NotificationCenter.default.removeObserver(self)
    var newTrackIndex = currentTrackIndex
    if newTrackIndex == tracks.count - 1 {
      newTrackIndex = 0
    } else {
      newTrackIndex += 1
    }
    if tracks.count == 0 {
      pauseTrack()
    } else {
      startPlay(trackIndex: newTrackIndex)
    }
  }
  
  /// 開始播放指定索引的歌曲。
  ///
  /// - Parameter trackIndex: 要播放的歌曲索引
  func startPlay(trackIndex: Int) {
    if currentTrackIndex == trackIndex && isPlaying == true {
      pauseTrack()
    } else {
      currentTrackIndex = trackIndex
      
      let url = URL(string: tracks[trackIndex].preview)
      let playerItem: AVPlayerItem = AVPlayerItem(url: url!)
      currentTrackName = tracks[trackIndex].title
      currentTrackArtist = tracks[trackIndex].artist.name ?? "-"
      musicPlayer.replaceCurrentItem(with: playerItem)
      musicPlayer.play()
      isPlaying = true
      addObservers()
    }
  }
  
  /// 暫停當前播放的歌曲。
  ///
  /// 調用該方法後，音樂將暫停播放或者恢復播放。
  func pauseTrack() {
    if musicPlayer.timeControlStatus == .playing {
      musicPlayer.pause()
      isPlaying = false
    } else if musicPlayer.timeControlStatus == .paused {
      musicPlayer.play()
      isPlaying = true
    }
  }
}