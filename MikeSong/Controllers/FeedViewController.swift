//
//  FeedViewController.swift
//  BearSong
//
//  Created by Rennan Rebouças on 19/10/18.
//  Copyright © 2018 Rennan Rebouças. All rights reserved.
//

import UIKit
import CoreData

class FeedViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, TabBarRefreshDelegate {

    @IBOutlet weak var collectionView_HotBear: UICollectionView!

    var feedResponse: MixcloudFeedResponse?
    private let refreshControl = UIRefreshControl()
    private var loadingIndicator: UIActivityIndicatorView?
    private var refreshButton: UIButton?
    private var errorEmptyView: UIView?
    /// Names of items favorited in this session or loaded from Core Data; used to show heart on cards.
    private var favoritedItemNames: Set<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(title: "Hot Song Bear")
        if #available(iOS 13.0, *) {
            let item = UITabBarItem(
                title: nil,
                image: UIImage(systemName: "square.grid.2x2"),
                selectedImage: UIImage(systemName: "square.grid.2x2.fill")
            )
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            (navigationController ?? self).tabBarItem = item
        }
        guard let collectionView = collectionView_HotBear else {
            print("[FeedViewController] collectionView_HotBear outlet não conectado no storyboard")
            return
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "FeedItemCell", bundle: nil), forCellWithReuseIdentifier: "hotBearCell")

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = LayoutConstants.sectionInset
            flowLayout.minimumLineSpacing = LayoutConstants.cellSpacing
            flowLayout.minimumInteritemSpacing = LayoutConstants.cellSpacing
        }

        loadFavoritedNamesFromCoreData()
        requestFeed()

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: collectionView_HotBear)
        }

        refreshControl.addTarget(self, action: #selector(oneRefresh), for: .valueChanged)
        collectionView.insertSubview(refreshControl, at: 0)

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        loadingIndicator = indicator

        let button = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        } else {
            button.setTitle("Refresh", for: .normal)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        view.addSubview(button)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: LayoutConstants.paddingStandard),
                button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -LayoutConstants.paddingStandard)
            ])
        } else {
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: view.topAnchor, constant: LayoutConstants.paddingStandard + 20),
                button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LayoutConstants.paddingStandard)
            ])
        }
        refreshButton = button

        let errorView = makeErrorEmptyView()
        view.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: LayoutConstants.paddingStandard),
            errorView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -LayoutConstants.paddingStandard)
        ])
        errorView.isHidden = true
        errorEmptyView = errorView
    }

    private func makeErrorEmptyView() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            icon.image = UIImage(systemName: "exclamationmark.triangle")
        }
        icon.tintColor = .systemGray
        icon.contentMode = .scaleAspectFit
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Nao foi possivel carregar o feed. Toque para tentar novamente."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        container.addSubview(icon)
        container.addSubview(label)
        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: container.topAnchor),
            icon.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 48),
            icon.heightAnchor.constraint(equalToConstant: 48),
            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: LayoutConstants.paddingStandard),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(errorViewTapped))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        return container
    }

    @objc private func errorViewTapped() {
        requestFeed()
    }

    @objc private func refreshButtonTapped() {
        refreshControl.beginRefreshing()
        requestFeed()
    }

    @objc func oneRefresh() {
        requestFeed()
    }

    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + wait, execute: closure)
    }

    func refresh() {
        refreshControl.endRefreshing()
    }

    private func finishFeedRequest(hadError: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loadingIndicator?.stopAnimating()
            self.loadingIndicator?.isHidden = true
            self.refreshControl.endRefreshing()
            let isEmpty = self.feedResponse?.data?.isEmpty ?? true
            let shouldShowError = hadError || isEmpty
            self.errorEmptyView?.isHidden = !shouldShowError
        }
    }

    func requestFeed() {
        DispatchQueue.main.async { [weak self] in
            self?.loadingIndicator?.isHidden = false
            self?.loadingIndicator?.startAnimating()
        }
        guard let url = URL(string: "https://api.mixcloud.com/search/?q=music&type=cloudcast&limit=20") else { return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("[FeedViewController]", error.localizedDescription)
                self?.finishFeedRequest(hadError: true)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                if let http = response as? HTTPURLResponse {
                    print("[FeedViewController] HTTP status:", http.statusCode)
                }
                self?.finishFeedRequest(hadError: true)
                return
            }
            guard let data = data else {
                self?.finishFeedRequest(hadError: true)
                return
            }
            do {
                let response = try MixcloudFeedResponse.decode(from: data)
                self?.feedResponse = response
                let count = response.data?.count ?? 0
                if count == 0, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("[FeedViewController] Chaves no JSON:", json?.keys.sorted())
                    for key in ["data", "results", "feed", "cloudcasts"] {
                        if let arr = json?[key] as? [[String: Any]], let first = arr.first {
                            print("[FeedViewController] Array '\(key)' tem \(arr.count) itens. Chaves do 1º item:", first.keys.sorted())
                            break
                        }
                    }
                }
                DispatchQueue.main.async {
                    self?.collectionView_HotBear?.reloadData()
                    if count == 0 {
                        print("[FeedViewController] Feed decodificado mas com 0 itens. Verifique a estrutura da API.")
                    }
                }
            } catch let parsingError {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("[FeedViewController] Chaves do JSON:", json?.keys.sorted())
                }
                print("[FeedViewController] Erro ao decodificar feed:", parsingError)
                self?.finishFeedRequest(hadError: true)
                return
            }
            self?.finishFeedRequest(hadError: false)
        }
        task.resume()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedResponse?.data?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hotBearCell", for: indexPath) as! FeedItemCell
        guard let data = feedResponse?.data, indexPath.item < data.count else { return cell }
        let item = data[indexPath.item]
        cell.uiImage_image.image(fromUrl: item.pictures?._640wx640h ?? "")
        let name = item.name ?? ""
        cell.setFavorited(favoritedItemNames.contains(name))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let data = feedResponse?.data, indexPath.item < data.count else { return }
        let item = data[indexPath.item]
        let name = item.name ?? "Unknown"
        let cell = collectionView.cellForItem(at: indexPath) as? FeedItemCell
        var imageToSave = cell?.uiImage_image.image
        if imageToSave == nil, let urlString = item.pictures?._640wx640h, let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                imageToSave = img
            }
        }
        guard let image = imageToSave else { return }
        if FavoriteStorageHelper.saveFavorite(image: image, name: name) {
            favoritedItemNames.insert(name)
            collectionView.reloadItems(at: [indexPath])
        }
    }

    private func loadFavoritedNamesFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = ["name"]
        do {
            let results = try appDelegate.persistentContainer.viewContext.fetch(request) as? [[String: Any]]
            let names = (results ?? []).compactMap { $0["name"] as? String }
            favoritedItemNames = Set(names)
        } catch {
            // ignore
        }
    }
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView_HotBear.frame.width
        let insets = LayoutConstants.sectionInset
        let spacing = LayoutConstants.cellSpacing
        let contentWidth = width - insets.left - insets.right - spacing
        let side = contentWidth / 2
        return CGSize(width: side, height: side)
    }
}

extension FeedViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView_HotBear.indexPathForItem(at: location),
              let _ = collectionView_HotBear.cellForItem(at: indexPath) as? FeedItemCell,
              let data = feedResponse?.data, indexPath.item < data.count else {
            return nil
        }
        let peekController = storyboard?.instantiateViewController(withIdentifier: "Peek") as? PeekPreviewViewController
        let cell = collectionView_HotBear.cellForItem(at: indexPath) as? FeedItemCell
        peekController?.peekimage = cell?.uiImage_image.image
        let item = data[indexPath.item]
        peekController?.urlMusic = item.url ?? ""
        peekController?.peekText = item.name ?? ""
        peekController?.preferredContentSize = CGSize(width: 0, height: 400)
        return peekController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {}
}
