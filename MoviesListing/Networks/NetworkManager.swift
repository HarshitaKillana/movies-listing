//
//  NetworkManager.swift
//  MoviesListing
//
//  Created by Harshita Killana on 04/02/24.
//

import Foundation

enum ValidationResultforDetails {
    case success(MovieDetails)
    case failure([String])
}

protocol SeachMovieFetchable {
    func searchMovies(parameters: SearchParameters, completion: @escaping (ValidationResult) -> Void)
}

protocol MovieDetailsFetchable {
    func fetchMovieDetails(movieID: String, completion: @escaping (ValidationResultforDetails) -> Void)
}

class NetworkManager: SeachMovieFetchable {
    
    func searchMovies(parameters: SearchParameters, completion: @escaping (ValidationResult) -> Void) {
        guard let baseURL = URL(string: "https://www.omdbapi.com/") else {
            completion(.failure(["Invalid URL"]))
            return
        }
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        let apiKey = "fd12ab17"
        
        let queryItems = [
            URLQueryItem(name: "s", value: parameters.query),
            URLQueryItem(name: "page", value: String(parameters.page)),
            URLQueryItem(name: "apikey", value: apiKey)
        ]
        components?.queryItems = queryItems
        
        guard let finalURL = components?.url else {
            completion(.failure(["Invalid URL"]))
            return
        }
        
        let task = URLSession.shared.dataTask(with: finalURL) { data, response, error in
            
            guard let data = data else {
                completion(.failure(["No data"]))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(MovieSearchResponse.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(["No movies found with the name \" \(parameters.query)\""]))
            }
        }
        task.resume()
    }

}

extension NetworkManager : MovieDetailsFetchable {
    
    func fetchMovieDetails(movieID: String, completion: @escaping (ValidationResultforDetails) -> Void) {
        guard let baseURL = URL(string: "https://www.omdbapi.com/") else {
            completion(.failure(["Invalid URL"]))
            return
        }
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryItems = [
            URLQueryItem(name: "i", value: movieID),
            URLQueryItem(name: "apikey", value: "fd12ab17")
        ]
        components?.queryItems = queryItems
        
        guard let finalURL = components?.url else {
            completion(.failure(["Invalid URL"]))
            return
        }
        
        let task = URLSession.shared.dataTask(with: finalURL) { data, response, error in
            guard let data = data else {
                completion(.failure(["No data"]))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(MovieDetails.self, from: data)
                completion(.success(decodedData))
            } catch let error {
                completion(.failure(["Error decoding movie details \(error.localizedDescription)"]))
            }
        }
        task.resume()
    }
}
