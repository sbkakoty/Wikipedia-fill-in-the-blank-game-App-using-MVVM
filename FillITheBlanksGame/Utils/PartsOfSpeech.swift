//
//  PartsOfSpeech.swift
//  FillITheBlanksGame
//
//  Created by MacBook on 8/22/22.
//

import Foundation

final class PartsOfSpeech {
    
    let partsOfSpeech: [String] = ["Adjective", "Verb", "Preposition", "Conjuction", "Adverb", "Other"]
    static let sharedPartsOfSpeech = PartsOfSpeech()
    
    private init(){}
}
