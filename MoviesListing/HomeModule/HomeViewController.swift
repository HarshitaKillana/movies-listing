//
//  ViewController.swift
//  MoviesListing
//
//  Created by Harshita Killana on 31/01/24.
//

import UIKit

final class HomeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var movieTextField: UITextField!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var pixarImage: UIImageView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet weak var watchlistButton: UIButton!
    
    
    
    let homeViewModel: HomeViewModel = HomeViewModel()
    
    override func viewDidLoad() {
        // requirement in did load
        super.viewDidLoad()
        setupSearchButton()
        setUpLogo()
        setupLabel()
        movieTextField.delegate = self
        homeViewModel.delegate = self
        watchlistButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        movieTextField.text = ""
    }

    //MARK - Setup UI
    private func setupLabel() {
        errorLabel.isHidden = true
    }
    
    private func setupSearchButton() {
        searchButton.titleLabel?.textAlignment = .center
    }
    
    private func setUpLogo() {
        pixarImage.layer.borderWidth = 1.5
        pixarImage.layer.cornerRadius = 16
        pixarImage.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
    }
    
    private func showError(message: String) {
        DispatchQueue.main.async {
            self.errorLabel.text = message
            self.errorLabel.isHidden = false
        }
    }
    
    
    @IBAction func watchlistButtonTapped(_ sender: Any) {
        homeViewModel.goToWatchlist()
    }
    
    //MARK - Search Button Action
    func setupSearchGestureTap() {
        let buttonTap = UITapGestureRecognizer(target: self, action: #selector(buttonTapped(_:)))
        searchButton.isUserInteractionEnabled = true
        searchButton.addGestureRecognizer(buttonTap)
    }
    
    @objc func buttonTapped(_ sender: UITapGestureRecognizer) {
        guard let searchText = movieTextField.text, !searchText.isEmpty else { return }
        homeViewModel.searchMovies(with: searchText)
    }
    
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        guard let searchText = movieTextField.text, !searchText.isEmpty else { return }
        homeViewModel.searchMovies(with: searchText)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
    
    private func pushListingViewController(with viewModel: ListingViewModel, searchText: String) {
        DispatchQueue.main.async {
            if let listingViewController = self.storyboard?.instantiateViewController(withIdentifier: "ListingViewController") as? ListingViewController {
                listingViewController.listingViewModel = viewModel
                listingViewController.searchText = searchText
                self.navigationController?.pushViewController(listingViewController, animated: true)
            }
        }
    }
}

extension HomeViewController: HomeViewModelDelegate {
    func searchSucceeded(with model: ListingViewModel, searchText: String) {
        pushListingViewController(with: model, searchText: searchText)
    }
    
    func searchFailed(error message: String) {
            showError(message: message)
    }
}
