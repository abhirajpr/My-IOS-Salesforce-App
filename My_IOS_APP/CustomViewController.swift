//
//  CustomViewController.swift
//  TrailheadiOSTest
//
//  Created by Abhiraj on 13/11/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit

class CustomViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func btnPresssed(_ sender: Any) {
        
     
        let vc = RootViewController()
        self.navigationController?.pushViewController(vc, animated: true)
       
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
