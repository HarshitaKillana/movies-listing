//
//  ListingViewModel.swift
//  MoviesListing
//
//  Created by Harshita Killana on 04/02/24.
//

import Foundation

class ListingViewModel {
    private let networkManager: SeachMovieFetchable
    
    init(networkManager: SeachMovieFetchable) {
        self.networkManager = networkManager
    }
    
    var movies: [Movie] = []
    var currentPage: Int = 1
    var totalResults: Int = 0
    let resultsPerPage: Int = 10
    var lastSearchTerm: String = ""
    
    func movieDetails(_ indexPath: IndexPath) -> Movie{
        return movies[indexPath.row]
    }
    
    func getNumberOfRows() -> Int {
        return movies.count
    }
    
    
    func searchMovies(searchTerm: String, completion: @escaping (ValidationResult) -> Void) {
        guard searchTerm.count >= 3 else {
            completion(.failure(["Enter a minimum of three letters"]))
            return
        }
        lastSearchTerm = searchTerm
        let parameters = SearchParameters(query: searchTerm, page: currentPage)
        networkManager.searchMovies(parameters: parameters) { [weak self] result in
            switch result {
            case .success(let movies):
                self?.totalResults = Int(movies.totalResults)!
                self?.movies.append(contentsOf: movies.search)
                completion(.success(movies))
            case .failure(let errors):
                DispatchQueue.main.async {
                    completion(.failure(errors))
                }
            }
        }
    }
    
    func loadMoreResults(search: String, completion: @escaping (ValidationResult) -> Void) {
//        print(lastSearchTerm)
//        print(totalResults)
//        print(currentPage * resultsPerPage)
        lastSearchTerm = search
        if totalResults == 0 {
            let parameters = SearchParameters(query: lastSearchTerm, page: currentPage)
            networkManager.searchMovies(parameters: parameters) { [weak self] result in
                switch result {
                case .success(let movies):
                    completion(.success(movies))
                    self?.totalResults = Int(movies.totalResults)!
                case .failure(let errors):
                    DispatchQueue.main.async {
                        completion(.failure(errors))
                    }
                }
            }
        }
        guard totalResults > currentPage * resultsPerPage else {
            completion(.failure(["No more results"]))
            return
        }
        
        currentPage += 1
        let parameters = SearchParameters(query: lastSearchTerm, page: currentPage)
        networkManager.searchMovies(parameters: parameters) { [weak self] result in
            switch result {
            case .success(let movies):
                completion(.success(movies))
            case .failure(let errors):
                completion(.failure(errors))
//                DispatchQueue.main.async {
//                    completion(.failure(errors))
//                }
            }
        }
    }
}
