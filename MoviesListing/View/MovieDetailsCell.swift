//
//  MovieDetailsCell.swift
//  MoviesListing
//
//  Created by Harshita Killana on 01/02/24.
//

import UIKit

final class MovieDetailsCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var plotLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var storetodefaults: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setupMovieImage(_ image:UIImage) {
        movieImage.image = image
    }
    
    @IBAction func addtoWatchlist(_ sender: Any) {
        storetodefaults?()
    }
    
    func updateButton(_ added: Bool) {
        if added {
            button.tintColor = .systemRed
            button.setTitle(" - ", for: .normal)
            
        } else {
            button.tintColor = .systemGreen
            button.setTitle(" + ", for: .normal)
        }
    }
    
    private func setupButton() {
        button.layer.cornerRadius = button.frame.size.width / 2
    }
    
    func setupFields(movieDetails: MovieDetails) {
        setupButton()
        titleLabel.text = movieDetails.title
        plotLabel.text = "Plot:\n\(movieDetails.plot)"
        languageLabel.text = "Language: \(movieDetails.language)"
        updateButton(movieDetails.isInWatchlist!)
        if let rating = Double(movieDetails.imdbRating), rating >= 0 && rating <= 10 {
            let scaledRating = round((rating / 2.0) * 10.0) / 10.0
            let starRating = String(repeating: "⭐", count: Int(scaledRating))
            ratingLabel.text = "Rating: \(starRating)"
        } else {
            ratingLabel.text = "Rating: N/A"
        }
        
        if let imageUrl = URL(string: movieDetails.poster) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl),
                   let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.setupMovieImage(image)
                    }
                }
            }
        }
        
    }
}
