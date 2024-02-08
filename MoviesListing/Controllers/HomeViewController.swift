//
//  ViewController.swift
//  MoviesListing
//
//  Created by Harshita Killana on 31/01/24.
//

import UIKit

// Try to  make differen conformations in different extensions
final class HomeViewController: UIViewController, UITextFieldDelegate, HomeViewModelDelegate {
    
    @IBOutlet private weak var movieTextField: UITextField!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var pixarImage: UIImageView!
    @IBOutlet private weak var errorLabel: UILabel!
    
    let homeViewModel: HomeViewModel = HomeViewModel(networkManager: NetworkManager()) // default argument
    
    override func viewDidLoad() {
        // requirement in did load
        super.viewDidLoad()
        setupSearchButton()
        setUpLogo()
        setupLabel()
        movieTextField.delegate = self
        homeViewModel.delegate = self
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
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    //MARK - Search Button Action
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        setupLabel()// evertime why should we execute this code
        guard let searchText = movieTextField.text, !searchText.isEmpty else { return }
        homeViewModel.searchMovies(searchTerm: searchText)
    }
    
    func searchSucceeded(_ viewModel: HomeViewModel, with model: ListingViewModel, searchText: String) {
        pushListingViewController(with: model, searchText: searchText)
    }
    
    func searchFailed(error message: String) {
        DispatchQueue.main.async {
            // this function could be in main thread itself so that itself handle and not a responsibility of caller
            self.showError(message: message)
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // WHEN TO USE
        errorLabel.isHidden = true
    }
    
    private func pushListingViewController(with model: ListingViewModel, searchText: String) {
        DispatchQueue.main.async {
            if let listingViewController = self.storyboard?.instantiateViewController(withIdentifier: "ListingViewController") as? ListingViewController {
                listingViewController.listingViewModel = model
                listingViewController.searchText = searchText
                self.navigationController?.pushViewController(listingViewController, animated: true)
            }
        }
    }
}

