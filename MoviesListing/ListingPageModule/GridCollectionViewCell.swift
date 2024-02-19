//
//  GridCollectionViewCell.swift
//  MoviesListing
//
//  Created by Harshita Killana on 15/02/24.
//

import UIKit

class GridCollectionViewCell: UICollectionViewCell {
    static let identifier = "GridCollectionViewCell"
    
    private let movieImage = UIImageView()
    private let movieTitle = UILabel()
    private let movieYear = UILabel()
    private let typeImage = UIImageView()
    private let typeLabel = UILabel()
    private let watchlistButton = UIButton()
    
    var saveWatchListInfo: (() -> Void)?
    
    private func setupCell() {
            layer.borderWidth = 2.0
            layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            layer.cornerRadius = 10.0
        }
    
    private func setupImage() {
        self.addSubview(movieImage)
        movieImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            movieImage.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            movieImage.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            movieImage.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            movieImage.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    private func setupMovieTitle() {
        self.addSubview(movieTitle)
        movieTitle.numberOfLines = 0
        movieTitle.translatesAutoresizingMaskIntoConstraints = false
        movieTitle.lineBreakMode = .byTruncatingTail
        NSLayoutConstraint.activate([
            movieTitle.topAnchor.constraint(equalTo: movieImage.bottomAnchor, constant: 8),
            movieTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            movieTitle.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4)
            
        ])
    }
    
    private func setupMovieYear() {
        self.addSubview(movieYear)
        movieYear.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            movieYear.topAnchor.constraint(equalTo: movieTitle.bottomAnchor, constant: 8),
            movieYear.leadingAnchor.constraint(equalTo: movieTitle.leadingAnchor),
        ])
    }
    
    private func setupTypeImage() {
        self.addSubview(typeImage)
        typeImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            typeImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.06),
            typeImage.widthAnchor.constraint(equalTo: typeImage.heightAnchor),
            typeImage.topAnchor.constraint(equalTo: movieYear.bottomAnchor, constant: 8),
            typeImage.leadingAnchor.constraint(equalTo: movieTitle.leadingAnchor)
            
        ])
    }
    
    private func setupTypeLabel() {
        self.addSubview(typeLabel)
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            typeLabel.leadingAnchor.constraint(equalTo: typeImage.trailingAnchor, constant: 6),
            typeLabel.bottomAnchor.constraint(equalTo: typeImage.bottomAnchor),
        ])
    }
    
    private func setupWatchListButton() {
        self.addSubview(watchlistButton)
        watchlistButton.backgroundColor = .systemBlue
        watchlistButton.setTitle("Add to watchlist", for: .normal)
        watchlistButton.setTitleColor(.white, for: .normal)
        watchlistButton.addTarget(self, action: #selector(watchlistButtonAction), for: .touchUpInside)
        watchlistButton.titleLabel?.adjustsFontSizeToFitWidth = true
        watchlistButton.titleLabel?.minimumScaleFactor = 0.5
        watchlistButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            watchlistButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
            watchlistButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            watchlistButton.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 8),
            watchlistButton.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: -16)
            
        ])
        watchlistButton.layer.cornerRadius = 8
        watchlistButton.titleLabel?.numberOfLines = 1
       // watchlistButton.titleLabel?.minimumScaleFactor = 0.2
    }
    
    func setupMovieImage(with url: URL, placeholder: UIImage? = nil) {
        movieImage.sd_setImage(with: url, placeholderImage: nil)
    }
    
   
    @objc func watchlistButtonAction(_ sender: Any) {
        addtowatchlist()
    }
    
    private func resetView() {
        watchlistButton.backgroundColor = .systemBlue
        watchlistButton.setTitle("Add to watchlist", for: .normal)
        movieImage.image = nil
    }
    
    private func addtowatchlist() {
        saveWatchListInfo?()
    }
    
    func updateButton(_ added: Bool) {
        // can get button title as well
        if added {
            watchlistButton.backgroundColor = .systemGreen
            watchlistButton.setTitle("Added to watchlist", for: .normal)
        } else {
            watchlistButton.backgroundColor = .systemBlue
            watchlistButton.setTitle("Add to watchlist", for: .normal)
        }
    }
    
    func setupViews() {
        setupCell()
        setupImage()
        setupMovieTitle()
        setupMovieYear()
        setupTypeImage()
        setupTypeLabel()
        setupWatchListButton()
        
    }
    
    func setupFields( _ movie: Movie){
        setupViews()
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
            setupMovieImage(with: imageUrl)
        }
        updateButton(movie.isInWatchlist)
    }
    
}

extension GridCollectionViewCell {
    
    class func getProductHeightForWidth(width: CGFloat) -> CGFloat {
     // magic numbers explanation:
     // 16 - offset between image and price
     // 22 - height of price
     // 8 - offset between price and title
     var resultingHeight: CGFloat = 16 + 22 + 8
     // get image height based on width and aspect ratio
     let imageHeight = width * 2 / 3
     resultingHeight += imageHeight
     let titleHeight = props.title.getHeight(
     font: .systemFont(ofSize: 12), width: width
     )
     resultingHeight += titleHeight
     return resultingHeight
     }
}
