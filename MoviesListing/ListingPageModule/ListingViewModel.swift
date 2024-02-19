//
//  ListingViewModel.swift
//  MoviesListing
//
//  Created by Harshita Killana on 04/02/24.
//

import Foundation

protocol ListingViewModelDelegate: AnyObject {
    func searchSucceeded()
    func searchFailed(error message: String)
}

protocol PresentMovieDetailsDelegate: AnyObject {
    func presentDetailsViewController(_ viewModel: MovieDetailsViewModel)
}

final class ListingViewModel {
    private let networkManager: SeachMovieFetchable
    weak var delegate: ListingViewModelDelegate?
    weak var detailsDelegate: PresentMovieDetailsDelegate? // delegate shoul dhave meaningful name of what thery are doing
    var shouldLoadMovieFromCache: Bool = true
    
    init(networkManager: SeachMovieFetchable) {
        self.networkManager = networkManager
    }

    let movieDetailsModel = MovieDetailsViewModel(networkManager: NetworkManager())
    var movies: [Movie] = []
    var watchlistMovies: [Movie] = []
    private var currentPage: Int = 1
    var totalResults: Int = 0
    private let resultsPerPage: Int = 10
    private var lastSearchTerm: String = ""
    
    func reset() {
        shouldLoadMovieFromCache = true
    }
    
    func movieDetails(_ indexPath: IndexPath) -> Movie{
            return movies[indexPath.row]
            
    }
    
    func getNumberOfMovies() -> Int {
            return movies.count
    }
    
    func searchMovies(searchTerm: String) {
        guard searchTerm.count >= 3 else {
            delegate?.searchFailed(error: "Enter a minimum of three letters")
            return
        }
        lastSearchTerm = searchTerm
        currentPage = 1
        let parameters = SearchParameters(query: searchTerm, page: currentPage)
        networkManager.searchMovies(parameters: parameters) { [weak self] result in
            switch result {
            case .success(let movies):
                self?.totalResults = Int(movies.totalResults ?? "0")!
                self?.movies = movies.search ?? []
                self?.delegate?.searchSucceeded()
            case .failure(_):
                self?.delegate?.searchFailed(error: "no movie found")
            }
        }
    }
    
    func loadMoreResults(search: String) {
        lastSearchTerm = search
        guard totalResults > currentPage * resultsPerPage else {
            return
        }
        
        currentPage += 1
        let parameters = SearchParameters(query: lastSearchTerm, page: currentPage)
        networkManager.searchMovies(parameters: parameters) { [weak self] result in
            switch result {
            case .success(let movies):
                self?.movies.append(contentsOf: movies.search ?? [])
                self?.delegate?.searchSucceeded()
            case .failure(_):
                self?.delegate?.searchFailed(error: "no movie found")
                
            }
        }
    }
    
    func didSelect(at indexPath: IndexPath){
        let searchid = movies[indexPath.row].imdbID
        movieDetailsModel.searchId = searchid ?? "" 
        movieDetailsModel.isAddedToWistlist = movies[indexPath.row].isInWatchlist
        detailsDelegate?.presentDetailsViewController(movieDetailsModel)
    }
    
}


extension ListingViewModel {
    
     func loadMoviesFromUserDefaults() {
//        print(UserDefaults.standard.dictionaryRepresentation().keys)
//        print(UserDefaults.standard.dictionaryRepresentation().values)
        movies = []
        let dict = UserDefaults.standard.dictionaryRepresentation()
        let keys = dict.keys.filter { key in
            if key.hasPrefix("tt"){
                if let storedData = UserDefaults.standard.data(forKey: key) {
                    if let storedMovie = try? JSONDecoder().decode(Movie.self, from: storedData) {
                        movies.append(storedMovie)
                        return true
                    }
                }
            }
            return false
        }
        
    }
}
