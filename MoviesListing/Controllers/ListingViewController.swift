//
//  ListingViewController.swift
//  MoviesListing
//
//  Created by Harshita Killana on 01/02/24.
//

import UIKit

class ListingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet private weak var searchField: UITextField!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var movieListingTableView: UITableView!
    @IBOutlet private weak var errorLabel: UILabel!
    
    var movies: [Movie] = []
    var firstSearch: String = ""
    var listingViewModel = ListingViewModel(networkManager: NetworkManager())
   // let resultsPerPage = 10
    let defaults = UserDefaults.standard
    let imageCache = ImageCache.shared
    var details: Movie?
    
    //MARK - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetups()
    }
    
    private func initialSetups() {
        searchField.delegate = self
        setupTableView()
        setupErrorLabel()
        searchField.text = firstSearch
        movieListingTableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        movieListingTableView.reloadData()
//        if let selectedIndexPath = movieListingTableView.indexPathForSelectedRow {
//            movieListingTableView.deselectRow(at: selectedIndexPath, animated: true)
//        }
    }
    
    // MARK - UI SETUP
    
    private func setupErrorLabel() {
        errorLabel.isHidden = true
    }
    
    private func setupTableView() {
        movieListingTableView.dataSource = self
        movieListingTableView.delegate = self
        
        let nib = UINib(nibName: "MovieListingCell", bundle: nil)
        movieListingTableView.register(nib, forCellReuseIdentifier: "movieListingCell")
        movieListingTableView.separatorInset = UIEdgeInsets(top:16, left: 16, bottom: 16, right: 16)
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
        guard let searchTerm = searchField.text, !searchTerm.isEmpty else { return }
        firstSearch = searchTerm
        searchMovies(searchTerm: searchTerm)
    }
    
    // MARK - Movie Search
    private func searchMovies(searchTerm: String) {
        listingViewModel.searchMovies(searchTerm: searchTerm) { [weak self] result in
            switch result {
            case .success(let movies):
                self?.movies = movies.search
                self?.hideErrorMessage()
                DispatchQueue.main.async {
                    self?.movieListingTableView.reloadData()
                }
            case .failure(let errors):
                self?.showErrorMessage(errors.joined(separator: "\n"))
            }
        }
    }
    
    //MARK - TABLE VIEW SETUP
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listingViewModel.getNumberOfRows()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieListingCell", for: indexPath) as! MovieListingCell
       
        cell.selectionStyle = .none
//        cell.layer.cornerRadius = 14
//        cell.layer.borderWidth = 2
//        cell.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        cell.setUpView()
        
//        cell.setupButton()
//        cell.resetView()
        details = listingViewModel.movieDetails(indexPath)
        movies.append(details!)
        cell.setupFields(details!)
       // cell.setupFields(movie: movies[indexPath.row])
        
        let imageUrlString = movies[indexPath.row].poster
        if let imageUrl = URL(string: imageUrlString) {
            imageCache.loadImage(from: imageUrl) { [weak cell] image in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    cell?.setupMovieImage(image)
                }
            }
        }
        let movieId = movies[indexPath.row].imdbID
        cell.updateButton(movies[indexPath.row].isInWatchlist )
        
        cell.storeindefaults = { [weak self] in
            guard let self else { return }
            let isWatchlist = self.movies[indexPath.row].isInWatchlist 
            self.defaults.set(!isWatchlist, forKey: movieId)
            cell.updateButton(!isWatchlist)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchid = movies[indexPath.row].imdbID
        presentDetailsViewController(id: searchid, isadded: movies[indexPath.row].isInWatchlist )
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = movies.count - 1
        if indexPath.row == lastElement {
            loadMoreResults()
        }
    }
    
    //MARK - Load More Results
    
    private func loadMoreResults() {
        listingViewModel.loadMoreResults(search: firstSearch) { [weak self] result in
            switch result {
            case .success(let newMovies):
                self?.movies.append(contentsOf: newMovies.search)
                DispatchQueue.main.async {
                    self?.movieListingTableView.reloadData()
                }
                
            case .failure(let errors):
                return
                // print("Error loading more results")
            }
        }
    }
    
    //MARK - Present Details View Controller
    
    private func presentDetailsViewController(id: String, isadded: Bool) {
        if let detailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailsController") as? MovieDetailsController {
            detailsViewController.searchid = id
            detailsViewController.addedToWistlist = isadded
            detailsViewController.modalPresentationStyle = .fullScreen
            self.present(detailsViewController, animated: true)
        }
    }

    //MARK - Text Field Delegate
    
    var searchTask: DispatchWorkItem?
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        firstSearch = newText
        
        searchTask?.cancel()
        
        if newText.count >= 3 {
            let task = DispatchWorkItem { [weak self] in
                self?.searchMovies(searchTerm: newText)
            }
            searchTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
        } else {
            searchMovies(searchTerm: newText)
        }
        return true
    }
}
