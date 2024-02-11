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

    var horizontalImages: [UIImage] = []
    var verticalImages: [UIImage] = []
    var videoModels: [MediaContent] = []
    var isSubscriber: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        loadVideoModels()
        
        isSubscriber = UserDefaults.standard.bool(forKey: "isSubscriber")
        isSubscriberSwitch.isOn = isSubscriber
    }

    @IBAction func isSubscriberSwitchChanged(_ sender: Any) {
        isSubscriber = (sender as AnyObject).isOn
        // Save isSubscriber value to local storage
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
            if let models = APICalls.shared.readVideoModelsFromJSONFile() {
                videoModels = models
                verticalCollectionView.reloadData()
                horizontalCollectionView.reloadData()
            }
        }
}

extension HomePageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviesCollectionViewCell.identifier, for: indexPath) as! MoviesCollectionViewCell
        let videoModel = videoModels[indexPath.item]
        
        cell.backgroundColor = UIColor.lightGray
        cell.coverImage.image = UIImage(named: videoModel.image)
        cell.movieTxt.text = videoModel.name

            return cell
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var selectedModel = videoModels[indexPath.item]
         performSegue(withIdentifier: "goToPlayer", sender: selectedModel)
       selectedModel.isSubscriber = isSubscriber
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
