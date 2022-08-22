//
//  WikiTitles.swift
//  FillITheBlanksGame
//
//  Created by MacBook on 8/22/22.
//

import Foundation

final class WikiTitles {
    
    //"Lion", "Tiger", "Elephant", "Wolf", "Dinosaur", "Peacock", 
    let wikiTitles: [String] = ["Horse"]
    static let sharedWikiTitles = WikiTitles()
    
    private init(){}
}
