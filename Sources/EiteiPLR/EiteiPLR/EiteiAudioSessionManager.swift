//
//  AudioSessionManager.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/11.
//

#if canImport(Foundation)
import Foundation
#endif

import AVFAudio

public class EiteiAudioSessionManager {
    
    public static let shared = EiteiAudioSessionManager()
    
    private init() {}
    
    public func configureAudioSession() {
        // 在背景執行緒中配置音頻會話，避免在主執行緒進行I/O操作
        DispatchQueue.global(qos: .background).async {
            do {
                // 設置音頻會話類別和模式，並允許與其他音頻混合
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
                // 啟用音頻會話
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                // 如果配置失敗，打印錯誤訊息
                print("配置AVAudioSession失敗: \(error.localizedDescription)")
            }
        }
    }
}
