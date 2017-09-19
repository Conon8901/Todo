//
//  ListViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/09/08.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var table: UITableView!
    @IBOutlet var searchbar: UISearchBar!
    
    var listNameArray = [String]()
    var searchArray = [String]()
    
    var saveData = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        
        listNameArray = saveData.object(forKey: "@folder") as! [String]
        
        searchbar.delegate = self
        searchbar.enablesReturnKeyAutomatically = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchbar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchArray.removeAll()
        
        if(searchbar.text == "") {
            searchArray = listNameArray
        }else{
            for data in listNameArray {
                if data.lowercased(with: NSLocale.current).contains(searchbar.text!.lowercased(with: NSLocale.current)) {
                    searchArray.append(data)
                }
            }
        }
        table.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchbar.text != ""{
            return searchArray.count
        }else{
            return listNameArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "List")
        
        if searchbar.text != ""{
            cell?.textLabel?.text = searchArray[indexPath.row]
        }else{
            cell?.textLabel?.text = listNameArray[indexPath.row]
        }
            
        cell?.textLabel?.numberOfLines = 0
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var dic: [String : Array<String>] = saveData.object(forKey: "@ToDoList") as! [String : Array<String>]!
        let folder = saveData.object(forKey: "@move") as! String
        let file = saveData.object(forKey: "@movingfile") as! String
        let key = folder+"@"+file
        let memotextview = saveData.object(forKey: key) as! String?
        let dateswitch = saveData.object(forKey: key+"@ison") as! Bool?
        let datefield = saveData.object(forKey: key+"@") as! String?
        let datepicker = saveData.object(forKey: key+"@@") as! Date?
        
        if(searchbar.text == "") {
            if memotextview != nil{
                saveData.set(memotextview, forKey: listNameArray[indexPath.row]+"@"+file)
                saveData.set("", forKey: key)
            }
            if dic[listNameArray[indexPath.row]] != nil{
                dic[listNameArray[indexPath.row]]!.append(file)
            }else{
                dic[listNameArray[indexPath.row]] = [file]
            }
            dic[folder]?.remove(at: (dic[folder]?.index(of: file))!)
            
            let laterkey = listNameArray[indexPath.row]+"@"+file
            
            if memotextview != nil{
                saveData.set(memotextview, forKey: laterkey)
                saveData.set("", forKey: key)
            }
            if dateswitch != nil{
                saveData.set(dateswitch, forKey: laterkey+"@ison")
                saveData.set(false, forKey: key+"@ison")
            }
            if datefield != nil{
                saveData.set(datefield, forKey: laterkey+"@")
                saveData.set("", forKey: key+"@")
            }
            if datepicker != nil{
                saveData.set(datepicker, forKey: laterkey+"@@")
                saveData.set(NSDate(), forKey: key+"@@")
            }
        }else{
//////////////////////////////////////////////Dateの書き換え///////////////////////////////////////////////
            saveData.set(memotextview, forKey: searchArray[indexPath.row]+"@"+file)
            if dic[searchArray[indexPath.row]] != nil{
                dic[searchArray[indexPath.row]]!.append(file)
            }else{
                dic[searchArray[indexPath.row]] = [file]
            }
            dic[folder]?.remove(at: (dic[folder]?.index(of: file))!)
        }
        
        saveData.set(dic, forKey: "@ToDoList")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
