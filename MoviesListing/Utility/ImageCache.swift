//
//  ImageCache.swift
//  MoviesListing
//
//  Created by Harshita Killana on 05/02/24.
//

import UIKit

class ImageCache {

    private let cache = NSCache<NSString, UIImage>()
    static let shared = ImageCache()

    private init() {}

    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        
        // Check if the image is already in the cache
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
            return
        }

        // If not, download the image and cache it
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }

            // Cache the downloaded image
            self?.cache.setObject(image, forKey: url.absoluteString as NSString)
            completion(image)
        }.resume()
    }
}
