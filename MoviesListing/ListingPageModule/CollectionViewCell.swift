//
//  CollectionViewCell.swift
//  MoviesListing
//
//  Created by Harshita Killana on 15/02/24.
//

import UIKit
import SDWebImage

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieYear: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var watchlistButton: UIButton!
    
    var saveWatchListInfo: (() -> Void)?
    private let imageCache = ImageCache.shared
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
    
//    private func setUpView() {
//        mainview.layer.borderColor = UIColor.gray.withAlphaComponent(0.1).cgColor
//        mainview.layer.borderWidth = 3
//        mainview.layer.cornerRadius = 30
//        mainview.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 5)
//    }
    
    func setupMovieImage(with url: URL, placeholder: UIImage? = nil) {
        movieImage.sd_setImage(with: url, placeholderImage: nil)
    }
    
    private func setupButton() {
        watchlistButton.layer.cornerRadius = 50
        watchlistButton.titleLabel?.numberOfLines = 1
        watchlistButton.titleLabel?.minimumScaleFactor = 0.2
    }
    
    @IBAction func watchlistButtonAction(_ sender: Any) {
        addtowatchlist()
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        watchlistButton.tintColor = tintColor
        watchlistButton.setTitle("Add to watchlist", for: .normal)
        movieImage.image = nil
    }
    
    private func addtowatchlist() {
        saveWatchListInfo?()
    }
    
    private func setupCell() {
            layer.borderWidth = 1.0
        layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            layer.cornerRadius = 10.0
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
       // setUpView()
        setupButton()
        //setupCell()
      //  resetView()
        movieTitle.text = movie.title
        movieYear.text = movie.year
        typeLabel.text = movie.type
        /// need not hard code moview or series can get from model
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
