//
//  ListingViewController.swift
//  MoviesListing
//
//  Created by Harshita Killana on 01/02/24.
//

import UIKit

// same here as well
final class ListingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ListingViewModelDelegate, PresentMovieDetailsDelegate {
    
    @IBOutlet private weak var searchField: UITextField!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var movieListingTableView: UITableView!
    @IBOutlet private weak var errorLabel: UILabel!
    
    var searchTask: DispatchWorkItem?
    var searchText: String = "" // why do we need this ?
    var listingViewModel = ListingViewModel(networkManager: NetworkManager())
    private let defaults = UserDefaults.standard
    
    //MARK - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetups() // Setups??
        listingViewModel.delegate = self
        listingViewModel.detailsDelegate = self
    }
    
    private func initialSetups() {
        searchField.delegate = self // delegate functionality was on top here also consolidate in one place
        setupTableView()
        setupErrorLabel()
        searchField.text = searchText
        movieListingTableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        movieListingTableView.reloadData()
    }
    
    // MARK - UI SETUP
    
    private func setupErrorLabel() {
        errorLabel.isHidden = true
    }
    
    private func setupTableView() {
        movieListingTableView.dataSource = self
        movieListingTableView.delegate = self
        
        let nib = UINib(nibName: "MovieListingCell", bundle: nil)
        movieListingTableView.register(nib, forCellReuseIdentifier: "movieListingCell") // constants at on place
        movieListingTableView.separatorInset = UIEdgeInsets(top:16, left: 16, bottom: 16, right: 16) // what is this ?
    }
    
    //MARK - ERROR HANDLING
    private func showErrorMessage(_ message: String) {
        DispatchQueue.main.async {
            self.errorLabel.text = message
            self.errorLabel.isHidden = false
            self.movieListingTableView.isHidden = true
        }
    }
    
    private func hideErrorMessage() {
        DispatchQueue.main.async {
            self.errorLabel.isHidden = true
            self.movieListingTableView.isHidden = false
        }
    }
    
    //MARK - Search Button Action
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        guard let searchTerm = searchField.text,
              !searchTerm.isEmpty else
        {
            return
        }
        searchText = searchTerm
        searchMovies(searchTerm: searchTerm)
    }
    
    // MARK - Movie Search
    private func searchMovies(searchTerm: String) {
        listingViewModel.searchMovies(searchTerm: searchTerm)
    }
    
    func searchSucceeded() {
        hideErrorMessage()
        DispatchQueue.main.async {
            self.movieListingTableView.reloadData()
        }
    }
    
    func searchFailed(error message: String) {
        showErrorMessage(message)
    }
    
    
    //MARK - TABLE VIEW SETUP
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listingViewModel.getNumberOfMovies()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieListingCell", for: indexPath) as! MovieListingCell
        
        cell.selectionStyle = .none
        cell.setUpView()
        let movie = listingViewModel.movieDetails(indexPath)
        cell.setupFields(movie)
        // why two methods one of set up view and then fields ? if one is done another can be induced by it
        let movieId = movie.imdbID
        cell.saveWatchListInfo = { [weak self] in
            guard let self else { return }
            let isWatchlist = movie.isInWatchlist
            self.defaults.set(!isWatchlist, forKey: movieId)
            cell.updateButton(!isWatchlist)
        }
        return cell
        /// reusablity code is missing how to reset the view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listingViewModel.didSelect(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = listingViewModel.getNumberOfMovies() - 3
        if indexPath.row == lastElement {
            loadMoreResults()
        }
        // what is prefetch data source check
    }
    
    //MARK - Load More Results
    
    private func loadMoreResults() {
        listingViewModel.loadMoreResults(search: searchText)
        // unrequired fucntion could be directly called as its one liner
    }
    
    //MARK - Present Details View Controller
    
    func presentDetailsViewController(_ model: MovieDetailsViewModel) {
        model.resetData()
        if let detailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailsController") as? MovieDetailsController {
            detailsViewController.movieDetailsViewModel = model
            //make it viewmodel
            detailsViewController.modalPresentationStyle = .fullScreen
            self.present(detailsViewController, animated: true)
        }
    }
    
    
    //MARK - Text Field Delegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        searchText = newText
        searchTask?.cancel()
        
        if newText.count >= 3 {
            let task = DispatchWorkItem { [weak self] in
                self?.searchMovies(searchTerm: newText)
            }
            searchTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
        } else {
            searchMovies(searchTerm: newText) // why call after 3 dirctly without waiting can wait here as well
        }
        return true
    }
}
