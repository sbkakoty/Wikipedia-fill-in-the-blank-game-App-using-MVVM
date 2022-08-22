//
//  WikiService.swift
//  FillITheBlanksGame
//
//  Created by MacBook on 8/19/22.
//

import Foundation
import Alamofire

class WikiService: NSObject {
    
    func getData(with query: String?, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        
        let appConfig = AppConfig()
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = appConfig.apiBaseURL
        components.path = "/w/api.php"
        components.query = query

        Alamofire.request(components.url!).responseJSON(completionHandler: {
            response in
            
            DispatchQueue.main.async {
                
                guard let data = response.data else { return }
                completion(data, response.response, response.result.error)
            }
        })
    }
}
