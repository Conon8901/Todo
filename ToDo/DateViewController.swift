//
//  DateViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/11/21.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class DateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Declare
    
    @IBOutlet var table: UITableView!
    
    var dateArray = [String]()
    
    var isArrayNil = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 60
        table.allowsSelection = false
        table.tableFooterView = UIView()
        
        navigationItem.title = variables.shared.condition
        
        dateArray = variables.shared.dateArray
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dateArray.count == 0 {
            isArrayNil = true
            
            return 1
        } else {
            isArrayNil = false
            
            return dateArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Date")
        
        if isArrayNil {
            cell?.textLabel?.text = NSLocalizedString("CELL_LABEL_NIL", comment: "")
            cell?.textLabel?.textColor = .gray
            
            cell?.textLabel?.textAlignment = .center
        } else {
            cell?.textLabel?.text = dateArray[indexPath.row]
        }
        
        return cell!
    }
    
    // MARK: - Others
    
    @IBAction func tapCancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
