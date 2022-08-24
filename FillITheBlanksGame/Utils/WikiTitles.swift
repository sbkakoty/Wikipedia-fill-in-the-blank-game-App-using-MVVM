//
//  WikiTitles.swift
//  FillITheBlanksGame
//
//  Created by MacBook on 8/22/22.
//

import Foundation

final class WikiTitles {
    
    let wikiTitles: [String] = ["Lion", "Tiger", "Elephant", "Wolf", "Dinosaur", "Peacock", "Horse"]
    static let sharedWikiTitles = WikiTitles()
    
    private init(){}
}
