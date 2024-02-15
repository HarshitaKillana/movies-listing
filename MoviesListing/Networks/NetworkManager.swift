//
//  NetworkManager.swift
//  MoviesListing
//
//  Created by Harshita Killana on 04/02/24.
//

import Foundation

//TODO: Cell reusablity scenarios when new data is loaded place holder should be there or reset code should be there since rgitering on the same table view from memory it deques the same cell back again

enum ValidationResultforDetails {
    case success(MovieDetails)
    case failure(String)
}

enum ValidationResult {
    case success(MovieSearchResponse)
    case failure(String)
}

protocol SeachMovieFetchable {
    func searchMovies(parameters: SearchParameters, completion: @escaping (Result<MovieSearchResponse, Error>) -> ())
}

protocol MovieDetailsFetchable {
    func fetchMovieDetails(movieID: String) async throws -> ValidationResultforDetails?
    func fetchMovieDetails(movieID: String, completion: @escaping (ValidationResultforDetails) -> Void)
}

final class NetworkManager: SeachMovieFetchable {
    
    func searchMovies(parameters: SearchParameters, completion: @escaping (Result<MovieSearchResponse, Error>) -> ()) {
        guard let baseURL = URL(string: "https://www.omdbapi.com/") else {
           // completion(.failure(error))
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
           // completion(.failure("Invalid URL"))
            return
        }
        
        let task = URLSession.shared.dataTask(with: finalURL) { data, response, error in
            
            guard let data else {
                if let error {
                    completion(.failure(error))
                }
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(MovieSearchResponse.self, from: data)
                if let responseResult = decodedData.response, responseResult.lowercased() == "true".lowercased() {
                    completion(.success(decodedData))
                } else {
                    let error  = NSError(domain: "blibli.com", code: 404, userInfo: ["Error": "Movie not Found"])
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

}

extension NetworkManager : MovieDetailsFetchable {
    
    func fetchMovieDetails(movieID: String, completion: @escaping (ValidationResultforDetails) -> Void) {
        guard let baseURL = URL(string: "https://www.omdbapi.com/") else {
            completion(.failure("Invalid URL"))
            return
        }
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryItems = [
            URLQueryItem(name: "i", value: movieID),
            URLQueryItem(name: "apikey", value: "fd12ab17")
        ]
        components?.queryItems = queryItems
        
        guard let finalURL = components?.url else {
            completion(.failure("Invalid URL"))
            return
        }
        
        let task = URLSession.shared.dataTask(with: finalURL) { data, response, error in
            guard let data else {
                completion(.failure("No data"))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(MovieDetails.self, from: data)
                completion(.success(decodedData))
            } catch let error {
                completion(.failure("Error decoding movie details \(error.localizedDescription)"))
            }
        }
        task.resume()
    }
}


extension NetworkManager {
    func fetchMovieDetails(movieID: String) async throws -> ValidationResultforDetails? {
        
        guard let baseURL = URL(string: "https://www.omdbapi.com/") else {
            return .failure("base url failed")
        }
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryItems = [
            URLQueryItem(name: "i", value: movieID),
            URLQueryItem(name: "apikey", value: "fd12ab17")
        ]
        components?.queryItems = queryItems
        guard let url = components?.url else { return nil}
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return .failure("api server error")
        }
        let MovieDetails = try JSONDecoder().decode(MovieDetails.self, from: data)
        return .success(MovieDetails)
    }
}
