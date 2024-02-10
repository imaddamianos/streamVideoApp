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
//        APICalls.shared.readVideoModelsFromJSONFile()
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
//        if (horizontalTableView != nil) {
//            return horizontalImages.count
//        }else{
        return videoModels.count
//        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MoviesCollectionViewCell.identifier, for: indexPath) as! MoviesCollectionViewCell
        let videoModel = videoModels[indexPath.item]
        
//        if (horizontalTableView != nil) {
//        
//            cell.backgroundColor = UIColor.lightGray
//
//            let imageView = UIImageView(image: horizontalImages[indexPath.item])
//            imageView.contentMode = .scaleAspectFit
//            imageView.translatesAutoresizingMaskIntoConstraints = false // Add this line
//
//            cell.contentView.addSubview(imageView)
//            NSLayoutConstraint.activate([
//                imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
//                imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
//                imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
//                imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
//            ])
//            
//            return cell
//        }else{
            // Configure collection view cell
            cell.backgroundColor = UIColor.lightGray
        cell.coverImage.image = UIImage(named: videoModel.image)
//            let imageView = UIImageView(image: verticalImages[indexPath.item])
//            imageView.contentMode = .scaleAspectFit
//            imageView.translatesAutoresizingMaskIntoConstraints = false // Add this line
//
//            cell.contentView.addSubview(imageView)
//            NSLayoutConstraint.activate([
//                imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
//                imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
//                imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
//                imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
//            ])

            return cell
//        }
    }
}

//extension HomePageViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return horizontalImages.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoviesTableViewCell.identifier, for: indexPath) as? MoviesTableViewCell else {
//            // If the cell cannot be dequeued, create a new instance of MoviesTableViewCell
//            let cell = MoviesTableViewCell(style: .default, reuseIdentifier: MoviesTableViewCell.identifier)
//            cell.coverImage.image = horizontalImages[indexPath.item]
//            return cell
//        }
//        // Configure the cell with the corresponding image
//        cell.coverImage.image = horizontalImages[indexPath.item]
//        return cell
//    }
//
//}
