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
        } else {
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
        print(dic)
        let dickey = saveData.object(forKey: "@move") as! String
        print(dickey)
        let arr = dic[saveData.object(forKey: "@move") as! String]!
        print(arr)
        let str = saveData.object(forKey: "@movingfile") as! String
        print(str)
        let mem = saveData.object(forKey: dickey+str) as! String
        print(mem)
        
        if(searchbar.text == "") {
            saveData.set(mem, forKey: listNameArray[indexPath.row]+str)
            if dic[listNameArray[indexPath.row]] != nil{
                dic[listNameArray[indexPath.row]]!.append(str)
            }else{
                dic[listNameArray[indexPath.row]] = [str]
            }
            dic[dickey]?.remove(at: (dic[dickey]?.index(of: str))!)
        } else {
            saveData.set(mem, forKey: searchArray[indexPath.row]+str)
            if dic[searchArray[indexPath.row]] != nil{
                dic[searchArray[indexPath.row]]!.append(str)
            }else{
                dic[searchArray[indexPath.row]] = [str]
            }
            dic[dickey]?.remove(at: (dic[dickey]?.index(of: str))!)
        }
        print(dic)
        saveData.set(dic, forKey: "@ToDoList")
        print(saveData.object(forKey: "@ToDoList") as! [String : Array<String>])
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

    
}
