/*
 Copyright (c) 2015-present, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation
import UIKit
import SalesforceSDKCore

class RootViewController : UITableViewController
{
    
    struct DeletedItemInfo {
        var data: [String:Any]
        var path: IndexPath
    }
    
    private var deleteRequests = [Int:DeletedItemInfo]()
    private var dataRow : [[String:Any]] = [[:]]
    
    
    var dataRows = [Dictionary<String, Any>]()
    
    // MARK: - View lifecycle
    override func loadView()
    {
        super.loadView()
        self.title = "Leads"
        
        let request = RestClient.sharedInstance().buildQueryRequest(soql: "SELECT Name, Id FROM Lead Where IsConverted=false")
        RestClient.sharedInstance().send(request: request, onFailure: { (error, urlResponse) in
            SFSDKLogger.sharedInstance().log(type(of:self), level:.debug, message:"Error invoking: \(request)")
        }) { [weak self] (response, urlResponse) in
            if let jsonResponse = response as? Dictionary<String,Any> {
                if let result = jsonResponse ["records"] as? [Dictionary<String,Any>] {
                    DispatchQueue.main.async {
                        self?.dataRows = result
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int
    {
        return self.dataRows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "CellIdentifier"
        
        // Dequeue or create a cell of the appropriate type.
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier:cellIdentifier) ??  UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        
        // If you want to add an image to your cell, here's how.
        let image = UIImage(named: "icon.png")
        cell.imageView?.image = image
        
        // Configure the cell to show the data.
        let obj = dataRows[indexPath.row]
        cell.textLabel?.text = obj["Name"] as? String
        
        // This adds the arrow to the right hand side.
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    override func tableView(_ tableView: UITableView,
                            editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
        
    {
        if (indexPath.row < self.dataRows.count) {
            return UITableViewCellEditingStyle.delete
        } else {
            return UITableViewCellEditingStyle.none
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let selectedId: String = self.dataRows[row]["Id"] as! String
        
        print("resp------\(selectedId)")
        
        let vc = DetailViewController()
        vc.stringPassed = selectedId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        if (row < self.dataRows.count && editingStyle == UITableViewCellEditingStyle.delete)
        {
            let deletedId: String = self.dataRows[row]["Id"] as! String
            let deletedItemInfo = DeletedItemInfo(data: self.dataRows[row], path:indexPath)
            let restApi = RestClient.sharedInstance()
            
            let deleteRequest: RestRequest = restApi.buildDeleteRequest(forObjectType: "Lead", objectId: deletedId)
            
            _ = restApi.send(request: deleteRequest, onFailure: { (error, resp) in
                print(error?.localizedDescription as Any)
            }, onSuccess: { (any, resp) in
                DispatchQueue.main.async {
                    
                    print("resp------\(String(describing: resp))")
                    
                    self.deleteRequests[deleteRequest.hashValue] = deletedItemInfo
                    self.dataRows.remove(at:row)
                    self.tableView.reloadData()
                }
            })
            
            
        }
    }
}
