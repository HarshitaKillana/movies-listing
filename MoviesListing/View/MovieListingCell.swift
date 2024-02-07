//
//  MovieListingCell.swift
//  MoviesListing
//
//  Created by Harshita Killana on 01/02/24.
//

import UIKit

struct MovieListingCellData {
    let movieImage: UIImage
    let movieTitle: String
    let movieYear: String
    let typeImage: UIImage
    let typeLabel: String
}

class MovieListingCell: UITableViewCell {
        
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieYear: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var watchlistButton: UIButton!
    
  
    @IBOutlet weak var mainview: UIView!
    
    
    var storeindefaults: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUpCell() {
        
    }
    
    func setUpView() {
        mainview.layer.borderColor = UIColor.gray.withAlphaComponent(0.1).cgColor
        mainview.layer.borderWidth = 3
        mainview.layer.cornerRadius = 30
    }
    
    func setupMovieImage(_ image:UIImage) {
        movieImage.image = image
    }
    
    private func setupButton() {
        watchlistButton.layer.cornerRadius = 50
    }
    
    @IBAction func watchlistButtonAction(_ sender: Any) {
        addtowatchlist()
    }
    
    private func resetView() {
        watchlistButton.tintColor = tintColor
        watchlistButton.setTitle("Add to watchlist", for: .normal)
    }
    
    private func addtowatchlist() {
        storeindefaults?()
    }
    
    func updateButton(_ added: Bool) {
        if added {
            watchlistButton.tintColor = .systemGreen
            watchlistButton.setTitle("Added to watchlist", for: .normal)
        } else {
            watchlistButton.tintColor = .tintColor
            watchlistButton.setTitle("Add to watchlist", for: .normal)
        }
    }
    
    func setupFields( _ movie: Movie){
        setupButton()
        resetView()
        movieTitle.text = movie.title
        movieYear.text = movie.year
        typeLabel.text = movie.type
        if movie.type == "movie" {
            typeImage.image = UIImage(named: "movie")
        } else {
            typeImage.image = UIImage(named: "series")
        }
    }
    
}
