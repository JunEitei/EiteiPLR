//
//  NetworkRetrier.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/12.
//

import Alamofire

class NetworkRetrier: RequestInterceptor {
    
    private var retryLimit: Int = 3 // 重試次數限制
    
    // 處理請求失敗後的重試邏輯
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        var retries = 0
        
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 || response.statusCode == 403 else {
            return completion(.doNotRetry)
        }
        
        retries += 1
        
        if retries <= retryLimit {
            completion(.retryWithDelay(2))  // 嘗試重試，延遲 2 秒
        } else {
            completion(.doNotRetry)  // 超過重試次數限制，不再重試
        }
    }
}
