//
//  PartsOfSpeech.swift
//  FillITheBlanksGame
//
//  Created by MacBook on 8/22/22.
//

import Foundation

final class PartsOfSpeech {
    
    let partsOfSpeech: [String] = ["Noun", "Adjective", "Verb", "Preposition", "Conjuction", "Adverb"]
    static let sharedPartsOfSpeech = PartsOfSpeech()
    
    private init(){}
}
