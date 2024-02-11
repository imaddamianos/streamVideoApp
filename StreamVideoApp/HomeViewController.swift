//
//  HomeViewController.swift
//  StreamVideoApp
//
//  Created by iMad on 10/02/2024.
//

import UIKit

class HomePageViewController: UIViewController {

    @IBOutlet weak var isSubscriberSwitch: UISwitch!
    @IBOutlet weak var horizontalCollectionView: UICollectionView!
    @IBOutlet weak var verticalCollectionView: UICollectionView!

    var horizontalVideoModels: [MediaContent] = []
    var verticalVideoModels: [MediaContent] = []
    var isSubscriber: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        loadVideoModels()
        
        isSubscriber = UserDefaults.standard.bool(forKey: "isSubscriber")
        isSubscriberSwitch.isOn = isSubscriber
    }

    @IBAction func isSubscriberSwitchChanged(_ sender: Any) {
        isSubscriber = isSubscriberSwitch.isOn
        UserDefaults.standard.set(isSubscriber, forKey: "isSubscriber")
    }
    
    func setupCollectionView() {
        horizontalCollectionView.delegate = self
        horizontalCollectionView.dataSource = self
        verticalCollectionView.delegate = self
        verticalCollectionView.dataSource = self
        verticalCollectionView.register(MoviesCollectionViewCell.nib, forCellWithReuseIdentifier: MoviesCollectionViewCell.identifier)
        horizontalCollectionView.register(MoviesCollectionViewCell.nib, forCellWithReuseIdentifier: MoviesCollectionViewCell.identifier)
    }
    
    func loadVideoModels() {
        if let horizontalModels = APICalls.shared.readHorizontalVideoModelsFromJSONFile() {
            horizontalVideoModels = horizontalModels
            horizontalCollectionView.reloadData()
        }
        
        if let verticalModels = APICalls.shared.readVerticalVideoModelsFromJSONFile() {
            verticalVideoModels = verticalModels
            verticalCollectionView.reloadData()
        }
    }
}

extension HomePageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == horizontalCollectionView {
            return horizontalVideoModels.count
        } else if collectionView == verticalCollectionView {
            return verticalVideoModels.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviesCollectionViewCell.identifier, for: indexPath) as! MoviesCollectionViewCell
        
        var videoModel: MediaContent
        
        if collectionView == horizontalCollectionView {
            videoModel = horizontalVideoModels[indexPath.item]
        } else {
            videoModel = verticalVideoModels[indexPath.item]
        }
        
        cell.backgroundColor = UIColor.lightGray
        cell.coverImage.image = UIImage(named: videoModel.image)
        cell.movieTxt.text = videoModel.name

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedModel: MediaContent
        
        if collectionView == horizontalCollectionView {
            selectedModel = horizontalVideoModels[indexPath.item]
        } else {
            selectedModel = verticalVideoModels[indexPath.item]
        }
        
        performSegue(withIdentifier: "goToPlayer", sender: selectedModel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlayer" {
            if let destinationVC = segue.destination as? ViewController {
                if let selectedModel = sender as? MediaContent {
                    destinationVC.videoModel = selectedModel
                }
            }
        }
    }
}
