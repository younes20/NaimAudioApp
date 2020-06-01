//
//  ViewController.swift
//  testApp
//
//  Created by Younes Nouri Soltan on 29/05/2020.
//  Copyright © 2020 Younes Nouri Soltan. All rights reserved.
//

import UIKit
import StoreKit


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
 
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var previousButton: UIButton!
    
    let cellReuseIdentifier = "MusicCell"
    
    var musicItems = Array<[String : Any]>()
    var currentItems = Array<[String : Any]>()
    
    var pageIndex = 0
    var numberOfItems = 10
    
    var isNextButtonActive: Bool! {
        didSet {
            if isNextButtonActive {
                nextButton.backgroundColor = UIColor(named: "MainColor")
            } else {
                nextButton.backgroundColor = UIColor.lightGray
            }
        }
    }
    
    var isPreviousButtonActive: Bool! {
        didSet {
            if isPreviousButtonActive {
                previousButton.backgroundColor = UIColor(named: "MainColor")
            } else {
                previousButton.backgroundColor = UIColor.lightGray
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        collectionView.register(UINib(nibName: "MusicCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: cellReuseIdentifier)

        isPreviousButtonActive = false
        
        let developerToken = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjlBNzM3NExGSkwifQ.eyJpc3MiOiJYWDNVSlo3MzczIiwiaWF0IjoxNTkwOTIxOTE1LCJleHAiOjE1OTgxMjE5MTV9.S8xLjiBkiPix4f3honHWO8YZaM8VAm2ZebgJqlW9-rQUYKQALVaDlCzbtRIQXsNpj3s3iy_N1RM5AAIVENnLjA"
        
        let searchTerm  = "workouts"
        let countryCode = "us"

        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host   = "api.music.apple.com"
        urlComponents.path   = "/v1/catalog/\(countryCode)/search"
                
        urlComponents.queryItems = [
            URLQueryItem(name: "term", value: searchTerm),
            URLQueryItem(name: "limit", value: "17"),
            URLQueryItem(name: "types", value: "playlists"),
        ]

        let url = urlComponents.url
        
        
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        
        request.setValue(developerToken, forHTTPHeaderField: "Music-User-Token")

        let session = URLSession.shared
                
        let task = session.dataTask(with: request) { data, response, error in

            guard let data = data else {
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                let jsonResult = json!["results"] as? [String: Any]
                let jsonPlayLists = jsonResult!["playlists"] as? [String: Any]
                self.musicItems = jsonPlayLists!["data"] as! Array<[String : Any]>
                
                
                DispatchQueue.main.async {
                    if self.musicItems.count > self.numberOfItems {
                        self.currentItems = Array(self.musicItems[self.pageIndex...self.numberOfItems-1])
                        self.isNextButtonActive = true
                    } else {
                        self.currentItems = Array(self.musicItems[self.pageIndex...])
                    }
                    self.collectionView.reloadData()
                }
            }
            catch let error {
                print(error)
            }
        }
        
        task.resume()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! MusicCollectionViewCell
        let musicItem = currentItems[indexPath.row]
        cell.musicItem = musicItem
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width - 20)/2, height: (view.frame.width - 20)/2)
    }

    @IBAction func nextPage(sender: UIButton) {
        // Check is next button is active
        if isNextButtonActive {
            isPreviousButtonActive = true
            pageIndex += 1
            
            let startIndex = pageIndex*numberOfItems
            let endIndex = startIndex + numberOfItems - 1
            
            if musicItems.count > endIndex {
                //If remaining items are more than maximum allowed items
                currentItems = Array(musicItems[startIndex...endIndex])
            } else {
                currentItems = Array(musicItems[startIndex...])
            }
            collectionView.reloadData()

            if endIndex >= musicItems.count {
                isNextButtonActive = false
            }
        } else {
            // Do nothing
        }

    }
    
    @IBAction func previousPage(){
        if isPreviousButtonActive {
            isNextButtonActive = true
            pageIndex -= 1

            let startIndex = pageIndex*numberOfItems
            let endIndex = startIndex + numberOfItems-1
            
            currentItems = Array(musicItems[startIndex...endIndex])
            collectionView.reloadData()
            
            if pageIndex == 0 {
                isPreviousButtonActive = false
            }

        } else {
            // Do nothing
        }
    }
}

