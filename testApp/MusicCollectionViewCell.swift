//
//  MusicCollectionViewCell.swift
//  naimAudioApp
//
//  Created by Younes Nouri Soltan on 31/05/2020.
//  Copyright © 2020 Younes Nouri Soltan. All rights reserved.
//

import UIKit

class MusicCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    var musicItem: [String : Any]! {
        didSet {
            configureView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func configureView() {

        let jsonAttribute = musicItem["attributes"] as? [String: Any]
        let jsonArtWork = jsonAttribute!["artwork"] as? [String: Any]
         
        var artWorkUrl = jsonArtWork!["url"] as! String
        artWorkUrl = artWorkUrl.replacingOccurrences(of: "{w}", with: "60")
        artWorkUrl = artWorkUrl.replacingOccurrences(of: "{h}", with: "60")
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL(string: artWorkUrl)!) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self!.imageView.image = image
                    }
                }
            }
        }
        nameLabel.text = jsonAttribute!["name"] as? String
    }
}
