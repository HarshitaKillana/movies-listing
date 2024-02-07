//
//  MoviesModel.swift
//  MoviesListing
//
//  Created by Harshita Killana on 01/02/24.
//

import Foundation

struct MovieSearchResponse: Codable {
    let search: [Movie]
    let totalResults: String
    let response: String

    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case response = "Response"
    }
}

struct Movie: Codable {
    let title: String
    let year: String
    let imdbID: String
    let type: String
    let poster: String
    var isInWatchlist: Bool {
        UserDefaults.standard.bool(forKey: imdbID)
    }

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
        case type = "Type"
        case poster = "Poster"
    }
}


class MovieDetails: Codable {
    var isInWatchlist: Bool?
    let title: String
    let year: String
    let plot: String
    let imdbID: String
    let poster: String
    let rated: String
    let imdbRating: String
    let language: String

    enum CodingKeys: String, CodingKey {
        
        case title = "Title"
        case year = "Year"
        case plot = "Plot"
        case imdbID
        case poster = "Poster"
        case rated = "Rated"
        case imdbRating
        case language = "Language"
        
    }
}

struct Rating: Codable {
    let source: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case value = "Value"
    }
}


enum ShowType {
    case movie
    case series
    case unknown
}
