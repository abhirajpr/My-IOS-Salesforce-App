//
//  SyncTableViewController.swift
//  
//
//  Created by Abhiraj on 04/12/18.
//

import Foundation
import UIKit
import SalesforceSDKCore
import CoreData

class SyncTableViewController: UITableViewController {
    
    var array  = [String]()
    var  refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        refresher.attributedTitle = NSAttributedString(string: "Pull to Sync")
        refresher.addTarget(self, action: #selector(SyncTableViewController.reload), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lead")
        request.predicate = NSPredicate(format: "isSynced = %@", "0")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "leadName") as! String)
                print(data.value(forKey: "isSynced") as Any )
                array.append(data.value(forKey: "leadName") as! String)
            }
        } catch {
            print("Failed")
        }
        
        
    }

    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return array.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "CellIdentifier"
        
        // Dequeue or create a cell of the appropriate type.
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier:cellIdentifier) ??  UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        cell.textLabel?.text = array[indexPath.row]
        
        
        return cell
    }
    @objc func reload(){
        
        var requestArray = [RestRequest]()
        var flag = 0
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lead")
        request.predicate = NSPredicate(format: "isSynced = %@", "0")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "leadName") as! String)
                if(data.value(forKey: "leadName") as? String != nil){
                    
                    requestArray.append(RestClient.sharedInstance().buildCreateRequest(forObjectType: "Lead", fields: ["LastName":data.value(forKey: "leadName") as! String , "Company": data.value(forKey: "leadName") as! String , "Status":data.value(forKey: "leadName") as! String , "Title":data.value(forKey: "leadName") as! String]))
                    flag = 1
                    data.setValue(true, forKey: "isSynced")
                    
                    do {
                        try context.save()
                    } catch {
                        print("Failed saving in isSynced Updation")
                    }
                    
                    
                }
            }
        } catch {
            print("Failed")
        }


        if(flag == 1){
            flag = 0
            let createLead = RestClient.sharedInstance().buildBatchRequest(usingRequests: requestArray, haltOnError: true)
            _ = RestClient.sharedInstance().send(request: createLead, onFailure: { (error, resp) in
                print(error?.localizedDescription as Any)
                print("******Error in buildBatchRequest******")
            }, onSuccess: { (any, resp) in
                DispatchQueue.main.async {
                    
                    print("resp------\(String(describing: resp))")
                }
            })
        }else{
            
            print("******No Offline Data******")
        }
       
        refresher.endRefreshing()
        tableView.reloadData()
    }

   
}
