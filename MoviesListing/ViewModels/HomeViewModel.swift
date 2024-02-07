//
//  HomeViewModel.swift
//  MoviesListing
//
//  Created by Harshita Killana on 31/01/24.
//

import Foundation

//typealias searchMovieCompletion<T: Codable> = (Result<T, Error>) -> Voi

class HomeViewModel {
  
    private let networkManager: SeachMovieFetchable
    
    init(networkManager: SeachMovieFetchable) {
        self.networkManager = networkManager
    }
    
    let listingViewModel = ListingViewModel(networkManager: NetworkManager())
    var currentPage: Int = 1
    var totalResults: Int = 0

    func searchMovies(searchTerm: String, completion: @escaping (Results) -> Void) {
        guard searchTerm.count >= 3 else {
            completion(.failure(["Enter a minimum of three letters"]))
            return
        }
      //  lastSearchTerm = searchTerm
        let parameters = SearchParameters(query: searchTerm, page: currentPage)
        networkManager.searchMovies(parameters: parameters) { [weak self] result in
            switch result {
            case .success(let movies):
                guard let self = self else {return}
                self.totalResults = movies.search.count
                self.listingViewModel.movies = movies.search
                completion(.success(self.listingViewModel))
            case .failure(let errors):
                completion(.failure(errors))
            }
        }
    }
    
}

struct SearchParameters {
    let query: String
    let page: Int
}

enum ValidationResult {
    case success(MovieSearchResponse)
    case failure([String])
}

enum Results {
    case success(ListingViewModel)
    case failure([String])
}
