//
//  MovieDetailsViewController.swift
//  MoviesListing
//
//  Created by Harshita Killana on 01/02/24.
//

import UIKit

final class MovieDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource, MovieDetailsModelDelegate  {
    
    // should have a single xib rather should be multiple fro every row as of now
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!
    
    //var searchid: String = ""
    private var movieDetails: MovieDetails?
    private let defaults = UserDefaults.standard
    // var addedToWistlist: Bool = false
    var movieDetailsViewModel = MovieDetailsViewModel(networkManager: NetworkManager())
    
    deinit { // why do we manually need to do this ?
        movieDetails = nil
        print("denit called")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        movieDetailsViewModel.delegate = self
        setupTableView()
        setupActivityIndicator()
        fetchMovieDetails()
        tableView.allowsSelection = false
        setupErrorLabel()
        
    }
    
    //MARK - UI Setup
    
    private func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
    }
    
    private func showActivityIndicator() {
        self.view.bringSubviewToFront(activityIndicator)
        activityIndicator.style = .large
        activityIndicator.startAnimating()
    }
    
    private func hideActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func setupErrorLabel() {
        errorLabel.isHidden = true
    }
    
    private func showErrorMessage(_ message: String) {
        DispatchQueue.main.async {
            self.errorLabel.text = message
            self.errorLabel.isHidden = false
            self.tableView.isHidden = true
        }
        
    }
    
    private func hideErrorMessage() {
        DispatchQueue.main.async {
            self.errorLabel.isHidden = true
            self.tableView.isHidden = false
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "MovieDetailsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "movieDetailsCell")
        tableView.backgroundColor = .black
    }
    
    //MARK - Table View Setup
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let safeAreaHeight = self.view.safeAreaInsets.bottom
        return UIScreen.main.bounds.height - safeAreaHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieDetailsCell", for: indexPath) as! MovieDetailsCell
        configureCell(cell)
        // wrong place for api call very very very wrong
        return cell
    }
    
    private func configureCell(_ cell: MovieDetailsCell) {
        cell.backgroundColor = .black
        guard let movieDetails = movieDetailsViewModel.getMovieDetails() else { return }
        cell.setupFields(movieDetails: movieDetails)
        cell.storetodefaults = { [weak self] in // camelCase
            guard let self else { return }
            // force unwrap
            self.defaults.set(!movieDetails.isInWatchlist!, forKey: movieDetails.imdbID)
            // movieDetailsViewModel.updateWatchlistState()
            cell.updateButton(!movieDetails.isInWatchlist!)
            self.movieDetailsViewModel.addedToWistlist = !self.movieDetailsViewModel.addedToWistlist
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.blue, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        headerView.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            doneButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    @objc func doneButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // can return directly
        return CGFloat(20)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("disappear")
    }
    
    //MARK- Fetch Movie Details
    
    private func fetchMovieDetails() {
        showActivityIndicator()
        movieDetailsViewModel.fetchMovieDetails()
    }
    
    func fetchingDetailsSucceded() {
        hideErrorMessage()
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.hideActivityIndicator()
        }
    }
    
    func fetchingDetailsFailed() {
        showErrorMessage("Sorry, could not fetch movie details")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismiss(animated: true, completion: nil)
        }
        hideActivityIndicator()
    }
}
