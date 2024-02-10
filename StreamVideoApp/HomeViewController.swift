//
//  HomeViewController.swift
//  StreamVideoApp
//
//  Created by iMad on 10/02/2024.
//

import UIKit

class HomePageViewController: UIViewController {

    @IBOutlet weak var horizontalTableView: UICollectionView!
    @IBOutlet weak var verticalCollectionView: UICollectionView!

    var horizontalImages: [UIImage] = []
    var verticalImages: [UIImage] = []
    var videoModels: [MediaContent] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        loadSampleImages()
        loadVideoModels()
    }

    func setupCollectionView() {
        horizontalTableView.delegate = self
        horizontalTableView.dataSource = self
        verticalCollectionView.delegate = self
        verticalCollectionView.dataSource = self
        verticalCollectionView.register(MoviesCollectionViewCell.nib, forCellWithReuseIdentifier: MoviesCollectionViewCell.identifier)
        horizontalTableView.register(MoviesCollectionViewCell.nib, forCellWithReuseIdentifier: MoviesCollectionViewCell.identifier)
        let verticalLayout = UICollectionViewFlowLayout()
        verticalLayout.scrollDirection = .vertical
        verticalCollectionView.collectionViewLayout = verticalLayout
    }
    
    func loadVideoModels() {
            if let models = APICalls.shared.readVideoModelsFromJSONFile() {
                videoModels = models
                verticalCollectionView.reloadData()
                horizontalTableView.reloadData()
            }
        }

    func loadSampleImages() {
        horizontalImages = [UIImage(named: "sample_image_1")!, UIImage(named: "sample_image_2")!, UIImage(named: "sample_image_3")!]
        verticalImages = [UIImage(named: "sample_image_4")!, UIImage(named: "sample_image_3")!, UIImage(named: "sample_image_2")!]
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

            return cell
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         let selectedModel = videoModels[indexPath.item]
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
