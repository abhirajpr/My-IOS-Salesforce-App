//
//  SmartViewController.swift
//  My_IOS_APP
//
//  Created by Abhiraj on 28/11/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import UIKit
import SalesforceSDKCore
import SmartSync
import SmartStore
import CoreData
import SystemConfiguration





class SmartViewController: UIViewController {

    
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var samartBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

//
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        
//        let context = appDelegate.persistentContainer.viewContext
//
//        let entity = NSEntityDescription.entity(forEntityName: "Lead", in: context)
//        let newLead = NSManagedObject(entity: entity!, insertInto: context)
//
//
//        newLead.setValue("test core", forKey: "leadName")
//        newLead.setValue("close", forKey: "leadStatus")
//        newLead.setValue("google", forKey: "leadCompany")
//        newLead.setValue("cpo", forKey: "LeadTitle")
//        newLead.setValue(false, forKey: "isSynced")
//        do {
//
//            try context.save()
//
//        } catch {
//
//            print("Failed saving")
//        }
    
        
    }


    @IBAction func smartBtnPressed(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Lead")
        request.predicate = NSPredicate(format: "isSynced = %@", "false")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "leadName") as! String)
                lbl.text = data.value(forKey: "leadName") as? String
                data.setValue(true, forKey: "isSynced")
                
                do {
                    try context.save()
                 } catch {
                    print("Failed saving")
                 }
            }
            
        } catch {
            
            print("Failed")
        }

        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available!")
        }
    }
    public class Reachability {
        
        class func isConnectedToNetwork() -> Bool {
            
            var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }
            
            var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
            if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
                return false
            }
            
            /* Only Working for WIFI
             let isReachable = flags == .reachable
             let needsConnection = flags == .connectionRequired
             
             return isReachable && !needsConnection
             */
            
            // Working for Cellular and WIFI
            let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            let ret = (isReachable && !needsConnection)
            
            return ret
            
        }
    }
    
}
