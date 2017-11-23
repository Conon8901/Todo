//
//  DateViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/11/21.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class DateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    @IBOutlet var navBar: UINavigationBar!
    
    var dateArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 60
        table.allowsSelection = false
        
        navBar.topItem?.title = variables.shared.condition
        
        dateArray = variables.shared.dateArray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Date")
        
        cell?.textLabel?.text = dateArray[indexPath.row]
        
        return cell!
    }
    
    @IBAction func tapCancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
