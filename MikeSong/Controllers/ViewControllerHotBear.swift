//
//  ViewControllerHotBear.swift
//  BearSong
//
//  Created by Rennan Rebouças on 19/10/18.
//  Copyright © 2018 Rennan Rebouças. All rights reserved.
//

import UIKit

class ViewControllerHotBear: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, RefreshTabbarDelegate {
    
    
    @IBOutlet weak var collectionView_HotBear: UICollectionView!
    
    var hotbearNumberCell: Json4Swift_Base?
    private let refreshHotBear = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView_HotBear.delegate = self
        collectionView_HotBear.dataSource = self
        
        self.collectionView_HotBear.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"hotBearCell")
        
        RequestHotbear()
        

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: collectionView_HotBear)
        }
        
        refreshHotBear.addTarget(self, action: #selector(oneRefresh), for: .valueChanged)
        collectionView_HotBear.insertSubview(refreshHotBear, at: 0)
       
       
    }
    
    
    
//Delegate RefreshTabBar
    @objc func oneRefresh()  {
        RequestHotbear()
        refresh()
    }
    
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    
    func refresh() {
        run(after: 2) {
            self.refreshHotBear.endRefreshing()
        }
    }
    
    
    
    
    func RequestHotbear()  {
        
        let url = URL(string: "https://api.mixcloud.com/new/")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do {
                let decoder = JSONDecoder()
                let hotbear = try decoder.decode(Json4Swift_Base.self, from: dataResponse)
                
                self.hotbearNumberCell = hotbear
                DispatchQueue.main.async {
                    self.collectionView_HotBear.reloadData()

                }
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return hotbearNumberCell?.data?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hotBearCell", for: indexPath) as! CollectionViewCell
        
        cell.uiImage_image.image(fromUrl: hotbearNumberCell!.data![indexPath.item].pictures?._640wx640h ?? "erro")
        
        return cell
    }
    
}




extension ViewControllerHotBear: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let largura = self.collectionView_HotBear.frame.width
        let side = (largura-24)/2
        
        return CGSize(width: side, height: side)
    }
    
}



// DelegatePeekAndPop
extension ViewControllerHotBear: UIViewControllerPreviewingDelegate{
//peek
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView_HotBear.indexPathForItem(at: location) else {
                return nil
        }
         guard let cell = collectionView_HotBear.cellForItem(at: indexPath) as? CollectionViewCell
            else {
                return nil
        }
        
        let peekController = storyboard?.instantiateViewController(withIdentifier: "Peek") as? PeekViewViewController
        
        peekController?.peekimage = cell.uiImage_image.image
        let data = hotbearNumberCell!.data![indexPath.item]
        peekController?.urlMusic = data.url
        peekController?.peekText = data.name
        peekController?.preferredContentSize = CGSize(width: 0, height: 400)
        return peekController
    }
//pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
    }

}


