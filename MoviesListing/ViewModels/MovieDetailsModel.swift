//
//  MovieDetailsModel.swift
//  MoviesListing
//
//  Created by Harshita Killana on 02/02/24.
//

import UIKit
protocol MovieDetailsModelDelegate: AnyObject { // could have used same protocol as in first class
    func fetchingDetailsSucceded()
    func fetchingDetailsFailed()
}


final class MovieDetailsViewModel {
    private var movieDetails: MovieDetails?
    private let networkManager: MovieDetailsFetchable
    weak var delegate: MovieDetailsModelDelegate?
    
    var searchid: String = ""
    var addedToWistlist: Bool = false
    
    init(networkManager: MovieDetailsFetchable) {
        self.networkManager = networkManager
    }
    
    func resetData() {
        movieDetails = nil
    }
    
    func getMovieDetails() -> MovieDetails? {
        return movieDetails
    }
    
    func fetchMovieDetails() {
        NetworkManager().fetchMovieDetails(movieID: searchid) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let details):
                self.movieDetails = details
                self.movieDetails?.isInWatchlist = self.addedToWistlist
                self.delegate?.fetchingDetailsSucceded()
                //completion(.success(details))
            case .failure(_):
                self.delegate?.fetchingDetailsFailed()
                // completion(.failure(errors))
            }
        }
    }
}
