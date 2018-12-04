//
//  MenuViewController.swift
//  TrailheadiOSTest
//
//  Created by Abhiraj on 19/11/18.
//  Copyright © 2018 Salesforce. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var pending: UIButton!
    @IBOutlet weak var leadListBtn: UIButton!
    @IBOutlet weak var createLeadBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leadListBtn.backgroundColor = UIColor(red: 0/255.0, green: 110/255.0, blue: 207/255.0, alpha: 1.0)
        leadListBtn.layer.cornerRadius = 9
        leadListBtn.setTitleColor(UIColor.white, for: .normal)
        
        createLeadBtn.backgroundColor = UIColor(red: 0/255.0, green: 110/255.0, blue: 207/255.0, alpha: 1.0)
        createLeadBtn.layer.cornerRadius = 9
        createLeadBtn.setTitleColor(UIColor.white, for: .normal)
        
        pending.backgroundColor = UIColor(red: 0/255.0, green: 110/255.0, blue: 207/255.0, alpha: 1.0)
        pending.layer.cornerRadius = 9
        pending.setTitleColor(UIColor.white, for: .normal)

    }

    @IBAction func createLeadPage(_ sender: Any) {
        
        let vc = TestViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func leadListPage(_ sender: Any) {
        
        let vc = RootViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func pendingChangesPage(_ sender: Any) {
        let vc = SyncTableViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
