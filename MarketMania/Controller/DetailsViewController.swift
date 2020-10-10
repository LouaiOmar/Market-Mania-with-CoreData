//
//  DetailsViewController.swift
//  MarketMania
//
//  Created by Louai on 9/25/20.
//  Copyright © 2020 Louai. All rights reserved.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  
    @IBOutlet weak var cartBadge: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
  
    var productDetails = [ProductResult]()
    var itemArray: [Item] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

  
    
    override func viewDidLayoutSubviews() {
        cartBadge.addBadge(number: itemArray.count)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "ImageViewCell", bundle: nil), forCellReuseIdentifier: "ImageCell")
       tableView.register(UINib(nibName: "DescriptionViewCell", bundle: nil), forCellReuseIdentifier: "DescriptionCell")
        loadItems()
    }

    // MARK: - Table view data source

    

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageViewCell
            cell.configure(productDetails[0].images.standard)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! DescriptionViewCell
            cell.configure(productDetails[0])
            cell.cartButtonIsTapped = {
                self.checkAndSaveNewItem(indexPath)
            }
                       return cell
        }
        
    }
  
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 400
        }
 

}

//MARK:-

extension DetailsViewController {
    
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
          self.cartBadge.updateBadge(number: itemArray.count)
      }

  
    
    func checkAndSaveNewItem(_ indexPath: IndexPath) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "name MATCHES %@", productDetails[0].names.title)
        do {
            let newItemList = try context.fetch(request)
            if newItemList.count == 0 {
              let newItem = Item(context: self.context)
                newItem.image = self.productDetails[0].images.standard
                newItem.name = self.productDetails[0].names.title
                newItem.price = self.productDetails[0].prices.current
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
    
  
    override func viewWillAppear(_ animated: Bool) {
        updateCartBadge()
    }
    
    
}
