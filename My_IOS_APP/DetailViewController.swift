//
//  DetailViewController.swift
//  TrailheadiOSTest
//
//  Created by Abhiraj on 13/11/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import UIKit
import SalesforceSDKCore

class DetailViewController: UIViewController {

    
    @IBOutlet weak var preConvertBtn: UIButton!
    @IBOutlet weak var leadNameDetail: UILabel!
    @IBOutlet weak var leadComplanyDetail: UILabel!
    @IBOutlet weak var leadStatusDetail: UILabel!
    @IBOutlet weak var leadTitleDetail: UILabel!
    
    var stringPassed = ""
    var leadId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Lead Details"
        
        preConvertBtn.backgroundColor = UIColor(red: 0/255.0, green: 110/255.0, blue: 207/255.0, alpha: 1.0)
        preConvertBtn.layer.cornerRadius = 7
        preConvertBtn.setTitleColor(UIColor.white, for: .normal)
        
        print("detail Controller------\(stringPassed)")
        leadId = stringPassed
        
        let request = RestClient.sharedInstance().buildRetrieveRequest(forObjectType: "Lead", objectId: leadId! , fieldList: "LastName,Id,Company,Status,Title")
        _ = RestClient.sharedInstance().send(request: request, onFailure: { (error, resp) in
            print(error?.localizedDescription as Any)
            
        }, onSuccess: { (responce, any) in
            DispatchQueue.main.async {
                
                print("destailresp------\(String(describing: responce))")
                if let jsonResponse = responce as? Dictionary<String,Any> {
                    
                        DispatchQueue.main.async {
                            self.leadNameDetail.text = (jsonResponse["LastName"] as! String)
                            self.leadComplanyDetail.text = (jsonResponse["Company"] as! String)
                            self.leadStatusDetail.text = (jsonResponse["Status"] as! String)
                            self.leadTitleDetail.text = (jsonResponse["Title"] as! String)
                        }
                    
                }
            }
        })
        
    }

    @IBAction func convertBtnPressed(_ sender: Any) {
        
        let vc = ConvertViewController()
        vc.namePassed = leadNameDetail.text!
        vc.userIdPassed = leadId!
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
