//
//  MovieListingCell.swift
//  MoviesListing
//
//  Created by Harshita Killana on 01/02/24.
//

import UIKit
import SDWebImage

final class MovieListingCell: UITableViewCell {
        
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieYear: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var watchlistButton: UIButton!
    @IBOutlet weak var mainview: UIView!
    
    var saveWatchListInfo: (() -> Void)?
    private let imageCache = ImageCache.shared // why is this here
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
 
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
        
    private func setUpView() {
        mainview.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        mainview.layer.borderWidth = 3
        mainview.layer.cornerRadius = 30
       // mainview.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 5)
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
        movieImage.image = nil
    }
    
    private func addtowatchlist() {
        saveWatchListInfo?()
    }
    
    func updateButton(_ added: Bool) {
        // can get button title as well
        if added {
            watchlistButton.tintColor = .systemGreen
            watchlistButton.setTitle("Added to watchlist", for: .normal)
        } else {
            watchlistButton.tintColor = .tintColor
            watchlistButton.setTitle("Add to watchlist", for: .normal)
        }
    }
    
    func setupFields( _ movie: Movie){
        setUpView()
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
        
        let imageUrlString = movie.poster ?? ""
        if let imageUrl = URL(string: imageUrlString) {
            imageCache.loadImage(from: imageUrl) { [weak self] image in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    self?.setupMovieImage(image)
                }
            }
        }
        updateButton(movie.isInWatchlist)
    }
    
}
