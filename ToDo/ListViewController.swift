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
    
    let excludes = CharacterSet(charactersIn: "　 ")
    
    var sameName = false
    
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
        let formerkey = folder+"@"+file
        let memotextview = saveData.object(forKey: formerkey) as! String?
        let dateswitch = saveData.object(forKey: formerkey+"@ison") as! Bool?
        let datefield = saveData.object(forKey: formerkey+"@") as! String?
        let datepicker = saveData.object(forKey: formerkey+"@@") as! Date?
        var laterkey = ""
        
        if(searchbar.text == "") {
            if dic[listNameArray[indexPath.row]] != nil{
                dic[listNameArray[indexPath.row]]!.append(file)
            }else{
                dic[listNameArray[indexPath.row]] = [file]
            }
            dic[folder]?.remove(at: (dic[folder]?.index(of: file))!)
            
            laterkey = listNameArray[indexPath.row]+"@"+file
        }else{
            saveData.set(memotextview, forKey: searchArray[indexPath.row]+"@"+file)
            if dic[searchArray[indexPath.row]] != nil{
                dic[searchArray[indexPath.row]]!.append(file)
            }else{
                dic[searchArray[indexPath.row]] = [file]
            }
            dic[folder]?.remove(at: (dic[folder]?.index(of: file))!)
            
            laterkey = searchArray[indexPath.row]+"@"+file
        }
        
        if memotextview != nil{
            saveData.set(memotextview, forKey: laterkey)
            saveData.removeObject(forKey: formerkey)
        }
        if dateswitch != nil{
            saveData.set(dateswitch, forKey: laterkey+"@ison")
            saveData.removeObject(forKey: formerkey+"@ison")
        }
        if datefield != nil{
            saveData.set(datefield, forKey: laterkey+"@")
            saveData.removeObject(forKey: formerkey+"@")
        }
        if datepicker != nil{
            saveData.set(datepicker, forKey: laterkey+"@@")
            saveData.removeObject(forKey: formerkey+"@@")
        }
        
        saveData.set(dic, forKey: "@ToDoList")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func add() {
        let alert = UIAlertController(title: NSLocalizedString("フォルダ追加", comment: ""), message: NSLocalizedString("タイトル入力", comment: ""), preferredStyle: .alert)
        let saveAction = UIAlertAction(title: NSLocalizedString("追加", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            let blank = String(describing: textField.text!).components(separatedBy: self.excludes).joined()
            if blank != ""{
                self.sameName = false
                if self.listNameArray.count != 0{
                    for i in 0...self.listNameArray.count-1{
                        if self.listNameArray[i] == textField.text!{
                            self.sameName = true
                        }
                    }
                }
                if self.sameName{
                    self.showalert(message: NSLocalizedString("同名のフォルダがあります", comment: ""))
                }else{
                    if (textField.text?.contains("@"))!{
                        self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                        
                        self.deselect()
                    }else{
                        self.listNameArray.append(textField.text!)
                        self.table.reloadData()
                        
                        self.saveData.set(self.listNameArray, forKey: "@folder")
                        
                        var dict = self.saveData.object(forKey: "@ToDoList") as! [String : Array<String>]
                        dict[textField.text!] = []
                        self.saveData.set(dict, forKey: "@ToDoList")

                        self.saveData.synchronize()
                        
                        if self.listNameArray.count >= 11{
                            let offset = CGPoint(x: 0, y: self.table.contentSize.height-self.table.frame.height)
                            self.table.setContentOffset(offset, animated: true)
                        }
                    }
                }
            }else{
                self.showalert(message: NSLocalizedString("入力してください", comment: ""))
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
            self.deselect()
        }
        
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.textAlignment = NSTextAlignment.left
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
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
}
