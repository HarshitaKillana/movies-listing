//
//  HomeViewModel.swift
//  MoviesListing
//
//  Created by Harshita Killana on 31/01/24.
//

import Foundation

//typealias searchMovieCompletion<T: Codable> = (Result<T, Error>) -> Voi
protocol HomeViewModelDelegate: AnyObject { // why any object
    func searchSucceeded(_ viewModel: HomeViewModel, with model: ListingViewModel, searchText: String) // function arguments syntatically should make sense
    func searchFailed(error message: String)
}

final class HomeViewModel {
    weak var delegate: HomeViewModelDelegate? // this can be  private and a dependency
    private let networkManager: SeachMovieFetchable
    
    init(networkManager: SeachMovieFetchable) {
        self.networkManager = networkManager
    }
    
    let listingViewModel = ListingViewModel(networkManager: NetworkManager()) // why do this here ? there is no data as of now ?
    var currentPage: Int = 1 // private ?
    var totalResults: Int = 0 // private ?
    
    func searchMovies(searchTerm: String) { // searchMovies(with term: String)
        guard searchTerm.count >= 3 else { // create constants for fixed values
            delegate?.searchFailed(error: "Enter a minimum of three letters.")
            return
        }
        //  lastSearchTerm = searchTerm
        let parameters = SearchParameters(query: searchTerm, page: currentPage)
        networkManager.searchMovies(parameters: parameters) { [weak self] result in
            switch result {
            case .success(let movies):
                guard let self else { return } // can be at top
                self.totalResults = movies.search?.count ?? 0
                self.listingViewModel.movies = movies.search ?? []
                self.listingViewModel.totalResults = Int(movies.totalResults ?? "0")!
                self.delegate?.searchSucceeded(self, with: self.listingViewModel, searchText: searchTerm)
                
            case .failure(let error):
                guard let self else { return }
                print(error.localizedDescription)
                self.delegate?.searchFailed(error:"No movie found with the name \(searchTerm)" )
            }
        }
    }
}

struct SearchParameters {
    let query: String
    let page: Int
}

enum Results {
    case success(ListingViewModel)
    case failure([String])
}
