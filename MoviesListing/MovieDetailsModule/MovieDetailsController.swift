//
//  MovieDetailsViewController.swift
//  MoviesListing
//
//  Created by Harshita Killana on 01/02/24.
//

import UIKit

final class MovieDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // should have a single xib rather should be multiple for every row as of now
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var errorLabel: UILabel!
    
    private var movieDetails: MovieDetails?
    private let defaults = UserDefaults.standard
    var movieDetailsViewModel = MovieDetailsViewModel(networkManager: NetworkManager())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        movieDetailsViewModel.delegate = self
        setupTableView()
        setupActivityIndicator()
        Task {
                   await fetchMovieDetails()
               }
        tableView.allowsSelection = false
       
        
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "movieDetailsCell", for: indexPath) as? MovieDetailsCell else {
            return UITableViewCell()
        }
        configureCell(cell)
        return cell
    }
    
    private func configureCell(_ cell: MovieDetailsCell) {
        cell.backgroundColor = .black
        guard let movieDetails = movieDetailsViewModel.getMovieDetails() else { return }
        cell.setupFields(movieDetails: movieDetails)
        cell.saveWatchListInfo = { [weak self] in
            guard let self else { return }
           // self.defaults.set(!(movieDetails.isInWatchlist ?? false), forKey: movieDetails.imdbID ?? "")
            guard let isInWatchlist = movieDetails.isInWatchlist else {return}
            if isInWatchlist {
                self.defaults.removeObject(forKey: movieDetails.imdbID ?? "")
            } else {
                if let encodedData = try? JSONEncoder().encode(movieDetails) {
                    defaults.set(encodedData, forKey: movieDetails.imdbID ?? "")
                }
            }
            cell.updateButton(!(movieDetails.isInWatchlist ?? false)  )
            self.movieDetailsViewModel.isAddedToWistlist = !self.movieDetailsViewModel.isAddedToWistlist
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
        CGFloat(20)
    }
    

    //MARK- Fetch Movie Details
    
    private func fetchMovieDetails() async {
        showActivityIndicator()
        await movieDetailsViewModel.fetchMovieDetails()
    }
}

extension MovieDetailsController: MovieDetailsModelDelegate {
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
