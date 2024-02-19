//
//  ListingViewController.swift
//  MoviesListing
//
//  Created by Harshita Killana on 01/02/24.
//

import UIKit

// same here as well
class ListingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var searchField: UITextField!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var movieListingCollectionView: UICollectionView!
    @IBOutlet private weak var searchView: UIView!
    @IBOutlet private weak var gridButton: UIButton!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var watchlistTitle: UILabel!
    
    var searchTask: DispatchWorkItem?
    var searchText: String = ""
    var isFromTabBar: Bool = true
    var presentedDisplayScreen: Bool = false
    var isGridLayout: Bool = false
    
    
    var listingViewModel: ListingViewModel = ListingViewModel(networkManager: NetworkManager())
    
    private let defaults = UserDefaults.standard
    
    //MARK - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        setupDelegates()
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        listingViewModel.reset()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func showTabBar() {
        if isFromTabBar, let tabBar = self.tabBarController?.tabBar {
            tabBar.isHidden = false
            self.view.bringSubviewToFront(tabBar)
        }
    }
    
    private func configureViews() {
        setupCollectionView()
        setupErrorLabel()
        searchField.text = searchText
    }
    
    private func setupDelegates() {
        listingViewModel.delegate = self
        listingViewModel.detailsDelegate = self
        searchField.delegate = self
        
    }
    func showingWatchlist() {
        listingViewModel.loadMoviesFromUserDefaults()
        hideSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showTabBar()
        if isFromTabBar {
            hideSearch()
            listingViewModel.loadMoviesFromUserDefaults()
        } else {
            self.tabBarController?.tabBar.isHidden = true
            showSearch()
        }
        movieListingCollectionView.reloadData()
        configureViews()
    }
    
    // MARK - UI SETUP
    private func setupErrorLabel() {
        errorLabel.isHidden = true
    }
    
    private func hideSearch() {
        searchField.isHidden = true
        gridButton.isHidden = true
        backButton.isHidden = true
        watchlistTitle.text = "Your Watchlist"
    }
    
    private func showSearch() {
        searchField.isHidden = false
        gridButton.isHidden = false
        backButton.isHidden = false
        watchlistTitle.isHidden = true
    }
    
    private func setupCollectionView() {
        movieListingCollectionView.dataSource = self
        movieListingCollectionView.delegate = self
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        movieListingCollectionView.collectionViewLayout = layout
        
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        movieListingCollectionView.register(nib, forCellWithReuseIdentifier: "SingleColumnCell")
        movieListingCollectionView.register(GridCollectionViewCell.self, forCellWithReuseIdentifier:GridCollectionViewCell.identifier)
    }
    
    //MARK - ERROR HANDLING
    private func showErrorMessage(_ message: String) {
        DispatchQueue.main.async {
            self.errorLabel.text = message
            self.errorLabel.isHidden = false
            self.movieListingCollectionView.isHidden = true
        }
    }
    
    private func hideErrorMessage() {
        DispatchQueue.main.async {
            self.errorLabel.isHidden = true
            self.movieListingCollectionView.isHidden = false
        }
    }
    
    @IBAction func gridButtonTapped(_ sender: Any) {
        isGridLayout = !isGridLayout
        movieListingCollectionView.reloadData()
        configureViews()
    }
    
    @IBAction func backbuttonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    // MARK - Movie Search
    private func searchMovies(searchTerm: String) {
        listingViewModel.searchMovies(searchTerm: searchTerm)
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
            searchMovies(searchTerm: newText)
        }
        return true
    }
}

extension ListingViewController: ListingViewModelDelegate, PresentMovieDetailsDelegate{
    func searchSucceeded() {
        hideErrorMessage()
        DispatchQueue.main.async {
            self.movieListingCollectionView.reloadData()
        }
    }
    
    func searchFailed(error message: String) {
        showErrorMessage(message)
    }
    
    func presentDetailsViewController(_ viewModel: MovieDetailsViewModel) {
        viewModel.resetData()
        if let detailsViewController = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailsController") as? MovieDetailsController {
            presentedDisplayScreen = false
            detailsViewController.movieDetailsViewModel = viewModel
            detailsViewController.modalPresentationStyle = .fullScreen
            self.present(detailsViewController, animated: true)
            listingViewModel.shouldLoadMovieFromCache = false
        }
    }
}


extension ListingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listingViewModel.getNumberOfMovies()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = movieListingCollectionView.dequeueReusableCell(withReuseIdentifier: "SingleColumnCell", for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        
        guard let gridCell = movieListingCollectionView.dequeueReusableCell(withReuseIdentifier: GridCollectionViewCell.identifier, for: indexPath) as? GridCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let movie = listingViewModel.movieDetails(indexPath)
        let movieId = movie.imdbID
        if isGridLayout{
            gridCell.setupFields(movie)
            gridCell.saveWatchListInfo = { [weak self] in
                guard let self else { return }
                let isWatchlist = movie.isInWatchlist
                if isWatchlist {
                    self.defaults.removeObject(forKey: movieId ?? "")
                    self.movieListingCollectionView.reloadData()
                } else {
                    if let encodedData = try? JSONEncoder().encode(movie) {
                        UserDefaults.standard.set(encodedData, forKey: movieId ?? "")
                    }
                }
                gridCell.updateButton(!isWatchlist)
            }
            return gridCell
        } else {
            cell.setupFields(movie)
            cell.saveWatchListInfo = { [weak self] in
                guard let self else { return }
                let isWatchlist = movie.isInWatchlist
                if isWatchlist {
                    self.defaults.removeObject(forKey: movieId ?? "")
                    self.movieListingCollectionView.reloadData()
                } else {
                    if let encodedData = try? JSONEncoder().encode(movie) {
                        UserDefaults.standard.set(encodedData, forKey: movieId ?? "")
                    }
                }
                cell.updateButton(!isWatchlist)
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastElement = listingViewModel.getNumberOfMovies() - 2
        if indexPath.row == lastElement {
            listingViewModel.loadMoreResults(search: searchText)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        listingViewModel.didSelect(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridLayout{
            let collectionViewWidth = movieListingCollectionView.bounds.width
            let dynamicWidth = (collectionViewWidth-20)/2
            return CGSize(width: dynamicWidth, height: 260)
        } else {
            return CGSize(width: UIScreen.main.bounds.width, height: 260)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}
