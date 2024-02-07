//
//  ViewController.swift
//  MoviesListing
//
//  Created by Harshita Killana on 31/01/24.
//

import UIKit

class HomeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var movieTextField: UITextField!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var pixarImage: UIImageView!
    @IBOutlet private weak var errorLabel: UILabel!
    
    let homeViewModel = HomeViewModel(networkManager: NetworkManager())
    //var clicked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchButton()
        setuppixar()
        setupLabel()
        movieTextField.delegate = self
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
    
    private func setuppixar() {
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
        setupLabel()
        guard let searchText = movieTextField.text, !searchText.isEmpty else { return }
        homeViewModel.searchMovies(searchTerm: searchText) { [weak self] result in
            switch result {
            case .success(let model):
                self?.pushListingViewController(with: model,searchText: searchText)
            case .failure(let errors):
                self?.showError(message: errors.joined(separator: "\n"))
            }
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
    
    //MARK - Push Listing View Controller
    private func pushListingViewController(with model: ListingViewModel, searchText: String) {
        DispatchQueue.main.async {
            if let listingViewController = self.storyboard?.instantiateViewController(withIdentifier: "ListingViewController") as? ListingViewController {
               
                listingViewController.listingViewModel = model
                listingViewController.firstSearch = searchText
                self.navigationController?.pushViewController(listingViewController, animated: true)
            }
        }
    }
}

