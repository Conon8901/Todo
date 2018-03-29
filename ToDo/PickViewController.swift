//
//  DateViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/11/21.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class PickViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Declare
    
    @IBOutlet var table: UITableView!
    
    var saveData = UserDefaults.standard
    
    var pickedArray = [String]()
    
    var isDataNil = false
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 60
        table.allowsSelection = false
        table.tableFooterView = UIView()
        
        switch variables.shared.condition {
        case .month:
            navigationItem.title = "ALERT_BUTTON_DATE_MONTH".localized
            
            pickTasks(interval: .month)
        case .week:
            navigationItem.title = "ALERT_BUTTON_DATE_WEEK".localized
            
            pickTasks(interval: .week)
        case .over:
            navigationItem.title = "ALERT_BUTTON_DATE_OVER".localized
            
            pickTasks(interval: .over)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - NavigationController
    
    @IBAction func tapCancel() {
        self.dismiss(animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Pick")
        
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
    
    // MARK: - Methods
    
    func pickTasks(interval: Condition) {
        let tasksDict = saveData.object(forKey: "dictData") as! [String: [String]]
        let openedCategory = variables.shared.currentCategory
        
        for task in tasksDict[openedCategory]! {
            let key = openedCategory + "@" + task + "@date"
            if let date = saveData.object(forKey: key) as! Date? {
                if date.timeIntervalSinceNow < interval.rawValue {
                    pickedArray.append(task)
                }
            }
        }
    }
}
