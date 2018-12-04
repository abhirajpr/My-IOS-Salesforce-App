//
//  TestViewController.swift
//  TrailheadiOSTest
//
//  Created by Abhiraj on 13/11/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import UIKit
import SalesforceSDKCore
import SmartSync
import SmartStore
import CoreData
import SystemConfiguration



class TestViewController: UIViewController {
    
    
    var dataRows = [NSDictionary]()
    var store: SmartStore = SmartStore()
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
   
    
   
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var leadName: UITextField!
    @IBOutlet weak var leadCompany: UITextField!
    @IBOutlet weak var leadStatus: UITextField!
    @IBOutlet weak var leadTitle: UITextField!
    let picker = UIPickerView()
    var selectedRow = Int()
    
    @IBOutlet weak var creationStatus: UILabel!
   
    let statusList = ["Open - Not Contacted","Working - Contacted","Closed - Converted","Closed - Not Converted"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Lead"
        
        saveBtn.backgroundColor = UIColor(red: 0/255.0, green: 110/255.0, blue: 207/255.0, alpha: 1.0)
        saveBtn.layer.cornerRadius = 7
        saveBtn.setTitleColor(UIColor.white, for: .normal)
        
        createPicker()
        createToolbar()

    }
    
    func createPicker(){
        
        picker.delegate = self
        picker.dataSource = self
        leadStatus.inputView=picker
        picker.selectedRow(inComponent: 0)
        picker.backgroundColor = .white
       
    }
    
    func createToolbar(){
        let toolbar=UIToolbar()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(TestViewController.dismissKeyboard))
        
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        leadStatus.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard(){
//        picker.selectedRow(inComponent: selectedRow)
        view.endEditing(true)
    }


    
    @IBOutlet weak var nameLblTemp: UILabel!
    @IBOutlet weak var companyLblTemp: UILabel!
    @IBOutlet weak var statusLblTemp: UILabel!
    @IBOutlet weak var titleLblTemp: UILabel!
    
    
    
    @IBAction func btnPressed(_ sender: Any) {
        //        let vc = RootViewController()
        //        self.navigationController?.pushViewController(vc, animated: true)
        
        let vc = SmartViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        let name = leadName.text
        let company = leadCompany.text
        let status = leadStatus.text
        let title = leadTitle.text

        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            
            let createLead = RestClient.sharedInstance().buildCreateRequest(forObjectType: "Lead", fields: ["LastName":name as Any , "Company": company as Any , "Status":status as Any , "Title":title as Any])
            _ = RestClient.sharedInstance().send(request: createLead, onFailure: { (error, resp) in
                print(error?.localizedDescription as Any)
                self.creationStatus.text = "failed"
                self.creationStatus.textColor = UIColor.red
                
                self.activityIndicator.stopAnimating()
                
            }, onSuccess: { (any, resp) in
                DispatchQueue.main.async {
                    
                    print("resp------\(String(describing: resp))")
                    self.nameLblTemp.text = "Name :"+self.leadName.text!
                    self.companyLblTemp.text = "Company :"+self.leadCompany.text!
                    self.statusLblTemp.text = "Status :"+self.leadStatus.text!
                    self.titleLblTemp.text = "Title :"+self.leadTitle.text!
                    self.creationStatus.text = "Success"
                    self.creationStatus.textColor = UIColor.green
                    
                    self.leadName.text = ""
                    self.leadCompany.text = ""
                    self.leadStatus.text = ""
                    self.leadTitle.text = ""
                    
                    self.activityIndicator.stopAnimating()
                }
            })
        }else{
            print("Internet Connection not Available!")
            
         
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let context = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: "Lead", in: context)
            let newLead = NSManagedObject(entity: entity!, insertInto: context)
            
            
            newLead.setValue(self.leadName.text!, forKey: "leadName")
            newLead.setValue(self.leadStatus.text!, forKey: "leadStatus")
            newLead.setValue(self.leadCompany.text!, forKey: "leadCompany")
            newLead.setValue(self.leadTitle.text!, forKey: "LeadTitle")
            newLead.setValue(false, forKey: "isSynced")
            do {
                
                try context.save()
                
            } catch {
                
                print("Failed saving")
            }
            
            
            
            self.creationStatus.text = "No Internet, Data saved offline"
            self.creationStatus.textColor = UIColor.orange
            self.activityIndicator.stopAnimating()
        }
        
       
      
    }
}

extension TestViewController: UIPickerViewDelegate, UIPickerViewDataSource    {
    
    func numberOfComponents(in picker: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ picker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statusList.count
    }
    
    func pickerView(_ picker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statusList[row]
    }
    
    func pickerView(_ picker: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var statusTemp: String?
//        selectedRow = row
        statusTemp = statusList[row]
        leadStatus.text = statusTemp
         print("statusTemp------\(String(describing: statusTemp))")
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
            
            // Working for Cellular and WIFI
            let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            let ret = (isReachable && !needsConnection)
            
            return ret
            
        }
    }
    
}
