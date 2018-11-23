//
//  ConvertViewController.swift
//  TrailheadiOSTest
//
//  Created by Abhiraj on 15/11/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import Foundation
import UIKit
import SalesforceSDKCore
import SmartSync

class ConvertViewController: UIViewController {

    
    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var convertBtn: UIButton!
    @IBOutlet weak var oppName: UITextField!
    @IBOutlet weak var isConvertedBtn: UILabel!
    @IBOutlet weak var leadName: UILabel!
    var namePassed = ""
    var userIdPassed = ""
    var name: String?
    var UID: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Lead Conversion"
        
        
        
        convertBtn.backgroundColor = UIColor(red: 0/255.0, green: 110/255.0, blue: 207/255.0, alpha: 1.0)
        convertBtn.layer.cornerRadius = 7
        convertBtn.setTitleColor(UIColor.white, for: .normal)
        
        name = namePassed
        print("namePassed------\(String(describing: namePassed))")
        leadName.text = name!
        print("userIdPassed------\(String(describing: userIdPassed))")
        UID = userIdPassed
    }
    
    @IBAction func convertToLead(_ sender: Any) {
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        let oppNameTxt = oppName.text
        let webservicePath = "/services/apexrest/ConvertLead/" + UID! + "-" + oppNameTxt!
        print("webservicePath------\(String(describing: webservicePath))")
        let request = RestRequest(method: RestRequest.Method.GET,    path:webservicePath, queryParams:nil)
        
        request.endpoint = ""
        _ = RestClient.sharedInstance().send(request: request, onFailure: { (error, resp) in
            
            print(error?.localizedDescription as Any)
            self.isConvertedBtn.text = "Not Converted"
            self.isConvertedBtn.textColor = UIColor.red
            
            self.activityIndicator.stopAnimating()
            
        }, onSuccess: { (responce, any) in
            DispatchQueue.main.async {
                
                print("destailresp------\(String(describing: responce))")
                self.isConvertedBtn.text = "Converted"
                self.isConvertedBtn.textColor = UIColor.green
                
                self.activityIndicator.stopAnimating()
                self.convertBtn.isEnabled = false
            }
        })
    }
    
}
