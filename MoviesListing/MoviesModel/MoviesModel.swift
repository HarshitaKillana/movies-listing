//
//  MoviesModel.swift
//  MoviesListing
//
//  Created by Harshita Killana on 01/02/24.
//

import Foundation

struct MovieSearchResponse: Codable {
    let search: [Movie]?
    let totalResults: String?
    let response: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case response = "Response"
        case error = "Error"
    }
}

struct Movie: Codable {
    let title: String?
    let year: String?
    let imdbID: String?
    let type: String?
    let poster: String?
    var isInWatchlist: Bool {
        guard let id = imdbID else { return false }
        if let storedData = UserDefaults.standard.data(forKey: id) {
            if let movie = try? JSONDecoder().decode(Movie.self, from: storedData){
                return true
            }
        }
        return false
        //return UserDefaults.standard.bool(forKey: id)
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
    let title: String?
    let year: String?
    let plot: String?
    let imdbID: String?
    let poster: String?
    let rated: String?
    let imdbRating: String?
    let language: String?

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
