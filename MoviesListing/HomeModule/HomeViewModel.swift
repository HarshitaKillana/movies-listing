//
//  HomeViewModel.swift
//  MoviesListing
//
//  Created by Harshita Killana on 31/01/24.
//

import Foundation

protocol HomeViewModelDelegate: AnyObject { // why any object
    func searchSucceeded(with model: ListingViewModel, searchText: String)
    func searchFailed(error message: String)
}

final class HomeViewModel {
    weak var delegate: HomeViewModelDelegate? // this can be  private and a dependency
    private let networkManager: SeachMovieFetchable
    
    init(networkManager: SeachMovieFetchable = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    var listingViewModel = ListingViewModel(networkManager: NetworkManager())
    private var currentPage: Int = 1
    private var totalResults: Int = 0
    private let minimumSearchLength = 3
    
    func searchMovies(with term: String) { // searchMovies(with term: String)
        guard term.count >= minimumSearchLength else { 
            delegate?.searchFailed(error: "Enter a minimum of three letters.")
            return
        }
       
        let parameters = SearchParameters(query: term, page: currentPage)
        networkManager.searchMovies(parameters: parameters) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let movies):
                self.totalResults = movies.search?.count ?? 0
                self.listingViewModel.movies = []
                self.listingViewModel.movies = movies.search ?? []
                listingViewModel.shouldLoadMovieFromCache = false
                self.listingViewModel.totalResults = Int(movies.totalResults ?? "0")!
                self.delegate?.searchSucceeded(with: self.listingViewModel, searchText: term)
                
            case .failure(let error):
                print(error.localizedDescription)
                self.delegate?.searchFailed(error:"No movie found with the name \(term)" )
            }
        }
    }
    
    func goToWatchlist() {
//        shouldLoadFromDefaults = true
//        listingViewModel.movies = []
//        listingViewModel.loadMoviesFromUserDefaults()
        delegate?.searchSucceeded(with: listingViewModel, searchText: "")
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
