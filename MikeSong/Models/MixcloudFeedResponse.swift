//
//  MixcloudFeedResponse.swift
//  BearSong
//
//  Model for Mixcloud API "new" feed response.
//

import Foundation

struct MixcloudFeedResponse: Decodable {
    let data: [CloudcastItem]?

    private enum CodingKeys: String, CodingKey {
        case data
        case results
        case feed
        case cloudcasts
    }

    init(data: [CloudcastItem]?) {
        self.data = data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var items: [CloudcastItem]? = try container.decodeIfPresent([CloudcastItem].self, forKey: .data)
        if items == nil, let decoded = try? container.decodeIfPresent([CloudcastItem].self, forKey: .results), let list = decoded { items = list }
        if items == nil, let decoded = try? container.decodeIfPresent([CloudcastItem].self, forKey: .feed), let list = decoded { items = list }
        if items == nil, let decoded = try? container.decodeIfPresent([CloudcastItem].self, forKey: .cloudcasts), let list = decoded { items = list }
        data = items
    }

    /// Tenta decodificar o feed tentando várias estruturas possíveis da API Mixcloud.
    static func decode(from data: Data) throws -> MixcloudFeedResponse {
        let decoder = JSONDecoder()

        // 1) Objeto com chave data/results/feed/cloudcasts
        do {
            return try decoder.decode(MixcloudFeedResponse.self, from: data)
        } catch {}

        // 2) Raiz é um array direto [ {...}, {...} ]
        if let items = try? decoder.decode([CloudcastItem].self, from: data) {
            return MixcloudFeedResponse(data: items)
        }

        // 3) Objeto com "data" (ou similar) sendo array de { "cloudcast": {...} }
        do {
            let wrapped = try decoder.decode(MixcloudFeedResponseWrapped.self, from: data)
            if let list = wrapped.data, !list.isEmpty {
                return MixcloudFeedResponse(data: list.compactMap(\.cloudcast))
            }
        } catch {}

        // 4) Array direto [ { "cloudcast": { ... } } ]
        if let wrapped = try? decoder.decode([CloudcastWrapper].self, from: data) {
            return MixcloudFeedResponse(data: wrapped.compactMap(\.cloudcast))
        }

        // 5) Objeto com uma chave que é array; cada elemento pode ser { "cloudcast": {...} } ou {...}
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let firstArray = json?.values.first(where: { $0 is [[String: Any]] }) as? [[String: Any]] {
            let dataArray = try JSONSerialization.data(withJSONObject: firstArray)
            if let items = try? decoder.decode([CloudcastItem].self, from: dataArray) {
                return MixcloudFeedResponse(data: items)
            }
            if let wrapped = try? decoder.decode([CloudcastWrapper].self, from: dataArray) {
                return MixcloudFeedResponse(data: wrapped.compactMap(\.cloudcast))
            }
        }

        throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Nenhuma estrutura de feed reconhecida"))
    }
}

/// Response quando cada item do array vem em "cloudcast": { "data": [ { "cloudcast": {...} } ] }
private struct MixcloudFeedResponseWrapped: Decodable {
    let data: [CloudcastWrapper]?
    private enum CodingKeys: String, CodingKey { case data, results, feed, cloudcasts }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        var list: [CloudcastWrapper]? = try c.decodeIfPresent([CloudcastWrapper].self, forKey: .data)
        if list == nil, let d = try? c.decodeIfPresent([CloudcastWrapper].self, forKey: .results), let x = d { list = x }
        if list == nil, let d = try? c.decodeIfPresent([CloudcastWrapper].self, forKey: .feed), let x = d { list = x }
        if list == nil, let d = try? c.decodeIfPresent([CloudcastWrapper].self, forKey: .cloudcasts), let x = d { list = x }
        data = list
    }
}

/// Item do feed quando a API retorna aninhado em "cloudcast"
private struct CloudcastWrapper: Decodable {
    let cloudcast: CloudcastItem?
}

struct CloudcastItem: Decodable {
    let pictures: Pictures?
    let url: String?
    let name: String?

    private enum CodingKeys: String, CodingKey {
        case pictures
        case images
        case url
        case name
        case key
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // API usa "pictures" ou "images" para as URLs de imagem
        pictures = try container.decodeIfPresent(Pictures.self, forKey: .pictures)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        // API pode retornar "url" ou "key" (path relativo)
        if let u = try container.decodeIfPresent(String.self, forKey: .url) {
            url = u.hasPrefix("http") ? u : "https://www.mixcloud.com\(u.hasPrefix("/") ? "" : "/")\(u)"
        } else if let k = try container.decodeIfPresent(String.self, forKey: .key) {
            url = "https://www.mixcloud.com\(k.hasPrefix("/") ? k : "/\(k)")"
        } else {
            url = nil
        }
    }
}

struct Pictures: Decodable {
    let _640wx640h: String?

    private enum CodingKeys: String, CodingKey {
        case _640wx640h = "640wx640h"
    }
}
