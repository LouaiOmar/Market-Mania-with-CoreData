//
//  DetailsViewController.swift
//  MarketMania
//
//  Created by Louai on 9/21/20.
//  Copyright © 2020 Louai. All rights reserved.
//

import UIKit
import CoreData

class SubCategoryListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FetchData {

 
    @IBOutlet weak var cartBadge: UIBarButtonItem!
    @IBOutlet weak var subCategoryLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
   
    var itemArray: [Item] = []
   let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var labelText = ""
    var subCategoryProducts = MostViewed()
    var itemRow = 0
    let spacing: CGFloat = 10.0
   
    override func viewDidLayoutSubviews() {
        cartBadge.addBadge(number: itemArray.count)
    }
        
    
    
    override func viewDidLoad() {
           super.viewDidLoad()
        loadItems()
        collectionView.register(UINib(nibName: "ListCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ListCell")
        subCategoryProducts.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        self.collectionView?.collectionViewLayout = layout
    }
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subCategoryProducts.mostViewedProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as! ListCollectionCell
        cell.configureCells(subCategoryProducts.mostViewedProducts[indexPath.row])
        cell.cartButtonIsTapped = {
            self.checkAndSaveNewItem(indexPath)
        }
        return cell
    }
    
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let numberOfItemsPerRow:CGFloat = 2
    let spacingBetweenCells:CGFloat = 10
    
    let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
    
    if let collection = self.collectionView{
        let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
        return CGSize(width: width, height: 300.0)
    }else{
        return CGSize(width: 0, height: 0)
        }
        
      }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemRow = indexPath.row
        performSegue(withIdentifier: "goToDetails", sender: self)

    }
    
    func updateUI() {
        collectionView.reloadData()
        subCategoryLabel.text = labelText
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "goToDetails" {
        let destinationVC = segue.destination as! DetailsViewController
        destinationVC.productDetails.removeAll()
        destinationVC.productDetails.append(subCategoryProducts.mostViewedProducts[itemRow])
        }
    }
    
}

//MARK:-

extension SubCategoryListViewController{
    
    func loadItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            itemArray = try context.fetch(request)
            } catch {
            print(error)
            }
    }
    
    func updateCartBadge() {
        loadItems()
        self.cartBadge.updateBadge(number: itemArray.count )
    }

    override func viewWillAppear(_ animated: Bool) {
        updateCartBadge()
    }
    
    func checkAndSaveNewItem(_ indexPath: IndexPath) {
    
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "name MATCHES %@", subCategoryProducts.mostViewedProducts[indexPath.row].names.title)
        do {
            let newItemList = try context.fetch(request)
            if newItemList.count == 0 {
              let newItem = Item(context: self.context)
                newItem.image = self.subCategoryProducts.mostViewedProducts[indexPath.row].images.standard
                newItem.name = self.subCategoryProducts.mostViewedProducts[indexPath.row].names.title
                newItem.price = self.subCategoryProducts.mostViewedProducts[indexPath.row].prices.current
                self.itemArray.append(newItem)
            } else {
                newItemList[0].numberOfPieces += 1
            }
        
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        updateCartBadge()
    }
        
}
