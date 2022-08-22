//
//  WikiViewModel.swift
//  FillITheBlanksGame
//
//  Created by MacBook on 8/19/22.
//

import Foundation

class WikiViewModel: NSObject {
    
    private var wikiService: WikiService!
    
    override init() {
        super.init()
        self.wikiService =  WikiService()
    }
    
    func getData(with query: String?, completion: @escaping (_ results: Data?, _ response: URLResponse?, _ error: Error?) -> ()) {
        
        self.wikiService.getData(with: query) { data, response, error in
            
            completion(data, response, error)
        }
    }
}
