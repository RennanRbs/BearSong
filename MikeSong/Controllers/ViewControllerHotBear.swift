//
//  ViewControllerHotBear.swift
//  BearSong
//
//  Created by Rennan Rebouças on 19/10/18.
//  Copyright © 2018 Rennan Rebouças. All rights reserved.
//

import UIKit

class ViewControllerHotBear: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView_HotBear: UICollectionView!
    
    var hotbearNumberCell: Json4Swift_Base?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView_HotBear.delegate = self
        collectionView_HotBear.dataSource = self
        self.collectionView_HotBear.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "hotBearCell")
        RequestHotbear()
    }
    
    func RequestHotbear()  {
        let url = URL(string: "https://api.mixcloud.com/popular/hot/")
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

