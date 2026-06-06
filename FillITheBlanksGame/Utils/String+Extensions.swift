//
//  String+Extensions.swift
//  FillITheBlanksGame
//
//  Created by MacBook on 8/22/22.
//

import Foundation

extension String {
    var decodingUnicodeCharacters: String { applyingTransform(.init("Hex-Any"), reverse: false) ?? "" }
    
    func checkPartsOfSpeech(partOfSpeech: String) -> Bool {
        
        var isFound: Bool = false
        
        let options: NSLinguisticTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
        let schemes = NSLinguisticTagger.availableTagSchemes(forLanguage: "en-in")
        let range = NSRange(location: 0, length: self.count)
        let tagger = NSLinguisticTagger(tagSchemes: schemes, options: Int(options.rawValue))
        tagger.string = self
        tagger.enumerateTags(in: range, scheme: .nameTypeOrLexicalClass, options: options) { (tag, tokenRange, _, _) in
            if let tag = tag {
                
                if tag.rawValue == partOfSpeech {
                    
                    isFound = true
                    return
                }
            }
        }
        
        return isFound
    }
    
    func split(usingRegex pattern: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: pattern, options: .allowCommentsAndWhitespace)
        let matches = regex.matches(in: self, range: NSRange(startIndex..., in: self))
        
        let splits = [startIndex]
            + matches
                .map { Range($0.range, in: self)! }
                .flatMap { [ $0.lowerBound, $0.upperBound ] }
            + [endIndex]

        return zip(splits, splits.dropFirst())
            .map {
                String(self[$0 ..< $1])
            }
    }
}
