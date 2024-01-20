//
//  Movie.swift
//  myCinema
//
//  Created by t2023-m0028 on 1/19/24.
//

import Foundation

struct Movie: Codable {
    let id: Int
    let title: String
    let posterPath: String?
    let rating: Double
    let detail: String
    let releaseDate: String

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case posterPath = "poster_path"
        case rating
        case detail = "overview"
        case releaseDate = "release_date"
    }

    init(id: Int, title: String, posterPath: String?, rating: Double, detail: String, releaseDate: String) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.rating = rating
        self.detail = detail
        self.releaseDate = releaseDate
    }

    init(json: [String: Any]) throws {
        guard let id = json["id"] as? Int,
              let title = json["title"] as? String,
              let releaseDate = json["release_date"] as? String,
              let rating = json["vote_average"] as? Double,
              let detail = json["overview"] as? String,
              let posterPath = json["poster_path"] as? String else {
            throw NetworkError.otherError("Invalid JSON structure for Movie object.")
        }

        self.init(id: id, title: title, posterPath: posterPath, rating: rating, detail: detail, releaseDate: releaseDate)
    }
}
