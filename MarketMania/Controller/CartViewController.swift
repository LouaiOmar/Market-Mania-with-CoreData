//
//  CartViewController.swift
//  MarketMania
//
//  Created by Louai on 10/1/20.
//  Copyright © 2020 Louai. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit


class CartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate {

 
    @IBOutlet weak var todayDate: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalPrice: UILabel!
   
    var itemArray: [Item] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewWillAppear(_ animated: Bool) {
        loadItems()
        todayDate.text = changeDateFormat()
        updateTotalPrice()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     tableView.register(UINib(nibName: "CartTableCell", bundle: nil), forCellReuseIdentifier: "CartCell")       
    }
    
  
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var unitPrice: Float = 0
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell") as! CartTableCell
        cell.delegate = self
        cell.configure(itemArray[indexPath.row])
        cell.plusButtonTapped = {
            self.itemArray[indexPath.row].numberOfPieces += 1
            unitPrice = Float(self.itemArray[indexPath.row].numberOfPieces) * self.itemArray[indexPath.row].price
            cell.configureLabels(Int(self.itemArray[indexPath.row].numberOfPieces), unitPrice)
            self.saveItem()
            self.updateTotalPrice()
        }
        cell.minusButtonTapped = {
            self.itemArray[indexPath.row].numberOfPieces -= 1
            if self.itemArray[indexPath.row].numberOfPieces == 0 {
                self.context.delete(self.itemArray[indexPath.row])
                } else {
                unitPrice = Float(self.itemArray[indexPath.row].numberOfPieces) * self.itemArray[indexPath.row].price
                cell.configureLabels(Int(self.itemArray[indexPath.row].numberOfPieces), unitPrice)
                    }
            self.saveItem()
            self.updateTotalPrice()
        }
                return cell
     }
     
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
                let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
        self.deleteSelectedRow(at: indexPath)
        }
        deleteAction.image = UIImage(named: "Trash")
        return [deleteAction]
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
           var options = SwipeOptions()
           options.expansionStyle = .destructive
           return options
       }


    func deleteSelectedRow(at indexPath: IndexPath) {
                context.delete(itemArray[indexPath.row])
                saveItem()
                updateTotalPrice()

        }
    
}


  
    


//MARK:-
//Date Format

extension CartViewController {
   
    func changeDateFormat() -> String {
    let today = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM y"
    return formatter.string(from: today)
    }

    func loadItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            itemArray = try context.fetch(request)
            } catch {
            print(error)
            }
        DispatchQueue.main.async {
               self.tableView.reloadData()
           }
        
    }
    
    func updateTotalPrice() {
        loadItems()
        var totalPriceCalculated: Float = 0
        var totalPriceString =  ""
            totalPriceCalculated = itemArray.map({$0.price * Float($0.numberOfPieces)}).reduce(0.0, +)
            totalPriceString = String(format: "%.02f", totalPriceCalculated)
            totalPrice.text = "Total Price:     $ \(totalPriceString)"
    }


    func saveItem() {
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }



}
