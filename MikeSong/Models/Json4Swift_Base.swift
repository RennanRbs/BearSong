//
//  Json4Swift_Base.swift
//  BearSong
//
//  Model for Mixcloud API "new" feed response.
//

import Foundation

struct Json4Swift_Base: Decodable {
    let data: [CloudcastItem]?
}

struct CloudcastItem: Decodable {
    let pictures: Pictures?
    let url: String
    let name: String
}

struct Pictures: Decodable {
    let _640wx640h: String?

    private enum CodingKeys: String, CodingKey {
        case _640wx640h = "640wx640h"
    }
}
