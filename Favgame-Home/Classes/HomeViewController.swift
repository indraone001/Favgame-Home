//
//  HomeViewController.swift
//  Favgame
//
//  Created by deri indrawan on 27/12/22.
//

import UIKit
import Combine
import SkeletonView

class HomeViewController: UIViewController {
  // MARK: - Properties
  var getListGameUseCase: GetListGameUseCase?
  private var cancellables: Set<AnyCancellable> = []
  private var gameList: [Game]?
  
  private let appTitle: UILabel = {
    let label = UILabel()
    let atributedTitle = NSMutableAttributedString(string: "Favgame", attributes: [
      NSAttributedString.Key.font: Constant.fontBold,
      NSAttributedString.Key.foregroundColor: UIColor.white
    ])
    label.attributedText = atributedTitle
    return label
  }()
  
  private let gameCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = UIColor(rgb: Constant.rhinoColor)
    collectionView.isSkeletonable = true
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.register(
      GameCollectionViewCell.self,
      forCellWithReuseIdentifier: GameCollectionViewCell.identifier
    )
    return collectionView
  }()
  
  // MARK: - Life Cycle
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.tabBarController?.tabBar.isHidden = false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(rgb: Constant.rhinoColor)
    setupUI()
    fetchGameList()
  }
  
  // MARK: - Helper
  private func setupUI() {
    navigationController?.navigationBar.isHidden = true
    
    view.addSubview(appTitle)
    appTitle.anchor(
      top: view.safeAreaLayoutGuide.topAnchor,
      leading: view.leadingAnchor,
      paddingTop: 16,
      paddingLeft: 10
    )
    
    view.addSubview(gameCollectionView)
    gameCollectionView.dataSource = self
    gameCollectionView.delegate = self
    gameCollectionView.anchor(
      top: appTitle.bottomAnchor,
      leading: view.leadingAnchor,
      bottom: view.bottomAnchor,
      trailing: view.trailingAnchor,
      paddingTop: 8
    )
  }
  
  private func fetchGameList() {
    gameCollectionView.showSkeleton(usingColor: .gray, transition: .crossDissolve(0.25))
    getListGameUseCase?.execute()
      .receive(on: RunLoop.main)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .failure:
            let alert = UIAlertController(title: "Alert", message: String(describing: completion), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        case .finished:
          self.gameCollectionView.hideSkeleton(reloadDataAfter: true)
        }
      }, receiveValue: { [weak self] gameList in
        self?.gameList = gameList
      })
      .store(in: &cancellables)
  }
  
}

extension HomeViewController: SkeletonCollectionViewDataSource, SkeletonCollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  // MARK: - SkeletonCollectionViewDataSource
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    return GameCollectionViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 8
  }
  
  // MARK: - UICollectionViewDataSource
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return gameList?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let gameCell = collectionView.dequeueReusableCell(
        withReuseIdentifier: GameCollectionViewCell.identifier,
        for: indexPath
    ) as? GameCollectionViewCell else {
        return UICollectionViewCell()
    }
    
    guard let gameList = gameList else { return UICollectionViewCell() }
    let game = gameList[indexPath.row]
    gameCell.configure(with: game)
    
    return gameCell
  }
    
  // MARK: - UICollectionViewDelegateFlowLayout
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width / 2 - 16, height: 280)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let selectedGameId = gameList?[indexPath.row].id
    let detailVC = Injection().container.resolve(DetailViewController.self)
    guard let detailVC = detailVC else { return }
    detailVC.configure(withGameId: selectedGameId!)
    
    let nav = UINavigationController(rootViewController: detailVC)
    nav.modalPresentationStyle = .fullScreen
    
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = UIColor(rgb: Constant.rhinoColor)
    nav.navigationBar.standardAppearance = appearance
    nav.navigationBar.scrollEdgeAppearance = nav.navigationBar.standardAppearance
    nav.navigationBar.tintColor = .white
    present(nav, animated: true)
  }
}
