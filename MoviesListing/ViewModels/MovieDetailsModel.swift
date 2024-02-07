//
//  MovieDetailsModel.swift
//  MoviesListing
//
//  Created by Harshita Killana on 02/02/24.
//

import UIKit

class MovieDetailsViewModel {
    private var movieDetails: MovieDetails?
    private let networkManager: MovieDetailsFetchable
    
    init(networkManager: MovieDetailsFetchable) {
        self.networkManager = networkManager
    }
    
    func getMovieDetails() -> MovieDetails? {
        return movieDetails
    }
    
    func fetchMovieDetails(movieID: String, completion: @escaping (ValidationResultforDetails) -> Void) {
        NetworkManager().fetchMovieDetails(movieID: movieID) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let details):
                self.movieDetails = details
                completion(.success(details))
            case .failure(let errors):
                completion(.failure(errors))
            }
        }
    }
}
