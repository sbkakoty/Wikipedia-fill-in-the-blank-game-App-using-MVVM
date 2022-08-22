//
//  WikiDTO.swift
//  FillITheBlanksGame
//
//  Created by MacBook on 8/19/22.
//

import Foundation

struct WikiDTO: Codable {
  let batchcomplete: String?
  let query: Query?
}

struct Query: Codable {
  let normalized: [Normalized]?
  let pages: [String:Pages]? // <- I can get to here
}

struct Normalized: Codable {
  let from, to: String?
}

struct Pages: Codable {
  let pageid, ns: Int?
  let title: String?
  let extract: String?
}

struct Thumbnail: Codable {
  let source: String? // <- But I want to grab this
  let width, height: Int?
}
