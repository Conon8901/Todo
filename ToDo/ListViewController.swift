//
//  ListViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/09/08.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: - Declare
    
    @IBOutlet var table: UITableView!
    @IBOutlet var searchbar: UISearchBar!
    
    var listNameArray = [String]()
    var searchArray = [String]()
    
    var saveData = UserDefaults.standard
    
    var sameName = false
    
    // MARK: - Basics
    
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
    
    // MARK: - SearchBar
    
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

    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchbar.text != "" {
            return searchArray.count
        } else {
            return listNameArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "List")
        
        if searchbar.text != "" {
            cell?.textLabel?.text = searchArray[indexPath.row]
        } else {
            cell?.textLabel?.text = listNameArray[indexPath.row]
        }
        
        cell?.textLabel?.numberOfLines = 0
    
        if cell?.textLabel?.text == saveData.object(forKey: "@move") as? String {
            cell?.selectionStyle = .none
            cell?.textLabel?.textColor = .lightGray
        }
    
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if searchbar.text == "" {
            switch listNameArray[indexPath.row] {
            case saveData.object(forKey: "@move") as! String:
                return nil
            default:
                return indexPath
            }
        } else {
            switch searchArray[indexPath.row] {
            case saveData.object(forKey: "@move") as! String:
                return nil
            default:
                return indexPath
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var dic: [String : Array<String>] = saveData.object(forKey: "@ToDoList") as! [String : Array<String>]!
        let fromFolderName = saveData.object(forKey: "@move") as! String
        let fileName = saveData.object(forKey: "@movingfile") as! String
        let formerkey = fromFolderName+"@"+fileName
        let memotextview = saveData.object(forKey: formerkey) as! String?
        let dateswitch = saveData.object(forKey: formerkey+"@ison") as! Bool?
        let datefield = saveData.object(forKey: formerkey+"@") as! String?
        let datepicker = saveData.object(forKey: formerkey+"@@") as! Date?
        var laterkey = ""
        
        if(searchbar.text == "") {
            if dic[listNameArray[indexPath.row]] != nil {
                dic[listNameArray[indexPath.row]]!.append(fileName)
            } else {
                dic[listNameArray[indexPath.row]] = [fileName]
            }
            dic[fromFolderName]?.remove(at: (dic[fromFolderName]?.index(of: fileName))!)
            
            laterkey = listNameArray[indexPath.row]+"@"+fileName
        } else {
            if dic[searchArray[indexPath.row]] != nil {
                dic[searchArray[indexPath.row]]!.append(fileName)
            } else {
                dic[searchArray[indexPath.row]] = [fileName]
            }
            dic[fromFolderName]?.remove(at: (dic[fromFolderName]?.index(of: fileName))!)
            
            laterkey = searchArray[indexPath.row]+"@"+fileName
        }
        
        if memotextview != nil {
            saveData.set(memotextview, forKey: laterkey)
            saveData.removeObject(forKey: formerkey)
        }
        if dateswitch != nil {
            saveData.set(dateswitch, forKey: laterkey+"@ison")
            saveData.removeObject(forKey: formerkey+"@ison")
        }
        if datefield != nil {
            saveData.set(datefield, forKey: laterkey+"@")
            saveData.removeObject(forKey: formerkey+"@")
        }
        if datepicker != nil {
            saveData.set(datepicker, forKey: laterkey+"@@")
            saveData.removeObject(forKey: formerkey+"@@")
        }
        
        saveData.set(dic, forKey: "@ToDoList")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func add() {
        let alert = UIAlertController(title: NSLocalizedString("フォルダ追加", comment: ""), message: NSLocalizedString("タイトル入力", comment: ""), preferredStyle: .alert)
        let saveAction = UIAlertAction(title: NSLocalizedString("追加", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let isBlank = textField.text!.components(separatedBy: CharacterSet.whitespaces).joined() == ""
            
            if isBlank {
                self.showalert(message: NSLocalizedString("入力してください", comment: ""))
            } else {
                self.sameName = false
                if self.listNameArray.count != 0 {
                    for i in 0...self.listNameArray.count-1 {
                        if self.listNameArray[i] == textField.text! {
                            self.sameName = true
                        }
                    }
                }
                if self.sameName {
                    self.showalert(message: NSLocalizedString("同名のフォルダがあります", comment: ""))
                } else {
                    if (textField.text?.contains("@"))! {
                        self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                        
                        self.deselect()
                    } else {
                        self.listNameArray.append(textField.text!)
                        self.table.reloadData()
                        
                        self.saveData.set(self.listNameArray, forKey: "@folder")
                        
                        var dict = self.saveData.object(forKey: "@ToDoList") as! [String : Array<String>]
                        dict[textField.text!] = []
                        self.saveData.set(dict, forKey: "@ToDoList")
                        
                        self.saveData.synchronize()
                        
                        if self.listNameArray.count >= 11 {
                            let coordinates = CGPoint(x: 0, y: self.table.contentSize.height-self.table.frame.height)
                            self.table.setContentOffset(coordinates, animated: true)
                        }
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
        }
        
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.textAlignment = NSTextAlignment.left
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Method
    
    func showalert(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("エラー", comment: ""),
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deselect() {
        if let indexPathForSelectedRow = self.table.indexPathForSelectedRow {
            self.table.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    // MARK: - Else
    
    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
