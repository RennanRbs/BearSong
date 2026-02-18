//
//  FeedViewController.swift
//  BearSong
//
//  Created by Rennan Rebouças on 19/10/18.
//  Copyright © 2018 Rennan Rebouças. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, TabBarRefreshDelegate {

    @IBOutlet weak var collectionView_HotBear: UICollectionView!

    var feedResponse: MixcloudFeedResponse?
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let collectionView = collectionView_HotBear else {
            print("[FeedViewController] collectionView_HotBear outlet não conectado no storyboard")
            return
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "FeedItemCell", bundle: nil), forCellWithReuseIdentifier: "hotBearCell")

        requestFeed()

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: collectionView_HotBear)
        }

        refreshControl.addTarget(self, action: #selector(oneRefresh), for: .valueChanged)
        collectionView.insertSubview(refreshControl, at: 0)
    }

    @objc func oneRefresh() {
        requestFeed()
        refresh()
    }

    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + wait, execute: closure)
    }

    func refresh() {
        run(after: 2) {
            self.refreshControl.endRefreshing()
        }
    }

    func requestFeed() {
        // Endpoints possíveis: /new/ ou /discover/new/
        guard let url = URL(string: "https://api.mixcloud.com/new/") else { return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("[FeedViewController]", error?.localizedDescription ?? "Response Error")
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
            }
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
        return cell
    }
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView_HotBear.frame.width
        let side = (width - 24) / 2
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
