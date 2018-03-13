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
    
    var pickedArray = [String]()
    
    var isDataNil = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 60
        table.allowsSelection = false
        table.tableFooterView = UIView()
        
        navigationItem.title = variables.shared.condition
        
        pickedArray = variables.shared.dateArray
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pickedArray.count == 0 {
            isDataNil = true
            
            return 1
        } else {
            isDataNil = false
            
            return pickedArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Date")
        
        if isDataNil {
            cell?.textLabel?.text = "CELL_LABEL_NA".localized
            cell?.textLabel?.textColor = .gray
            cell?.textLabel?.textAlignment = .center
        } else {
            cell?.textLabel?.text = pickedArray[indexPath.row]
            cell?.textLabel?.textColor = .black
            cell?.textLabel?.textAlignment = .left
        }
        
        return cell!
    }
    
    // MARK: - Others
    
    @IBAction func tapCancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
