//
//  NetworkRetrier.swift
//  EiteiPLR
//
//  Created by damao on 2024/7/12.
//

import Alamofire

class NetworkRetrier: RequestInterceptor {
    
    private var retryLimit: Int = 3 // 重試次數限制
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetry) // 除非是401未授權錯誤，否則不重試
            return
        }
        
        if request.retryCount < retryLimit {
            completion(.retryWithDelay(1)) // 延遲1秒後重試
        } else {
            completion(.doNotRetry) // 已達到重試次數限制，不再重試
        }
    }
}
