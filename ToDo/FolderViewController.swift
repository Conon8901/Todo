//
//  ViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/06/03.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class FolderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: - declare
    
    @IBOutlet var table: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var searchbar: UISearchBar!
    
    var folderNameArray = [String]()
    var addNameArray = [String]()
    var searchArray = [String]()
    
    var saveData : UserDefaults = UserDefaults.standard
    
    let excludes = CharacterSet(charactersIn: "　 ")
    
    var deleteDict = [String: Array<String>]()
    var editDict = [String: Array<String>]()
    
    var edit: Bool = false
    var sameName: Bool = false
    
    // MARK: - basics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        
        if saveData.object(forKey: "folder") != nil{
            folderNameArray = saveData.object(forKey: "folder") as! [String]
        }else{
           self.saveData.set(self.folderNameArray, forKey: "folder")
        }
        
        if saveData.object(forKey: "ToDoList") != nil{
            editDict = saveData.object(forKey: "ToDoList") as! [String : Array<String>]
        }else{
            self.saveData.set(self.editDict, forKey: "ToDoList")
        }
        
        search()
        
        searchbar.delegate = self
        searchbar.enablesReturnKeyAutomatically = false
        
        searchArray = folderNameArray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = table.indexPathForSelectedRow {
            table.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
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
            searchArray = folderNameArray
        } else {
            for data in folderNameArray {
                if data.contains(searchbar.text!) {
                    searchArray.append(data)
                }
            }
        }
        table.reloadData()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchbar.text != ""{
            return searchArray.count
        }else{
            return folderNameArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Folder")
        
        if searchbar.text != ""{
            cell?.textLabel?.text = searchArray[indexPath.row]
        }else{
            cell?.textLabel?.text = folderNameArray[indexPath.row]
        }
        
        cell?.textLabel?.numberOfLines=0
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if edit {
            edit(indexPath: indexPath)
        }else{
            if(searchbar.text == "") {
                saveData.set(String(folderNameArray[indexPath.row]), forKey: "move")
            } else {
                saveData.set(String(searchArray[indexPath.row]), forKey: "move")
            }
            
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "File") as! FileViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }

    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            deleteDict = saveData.object(forKey: "ToDoList") as! [String : Array<String>]
            
            if(searchbar.text == "") {
                deleteDict[String(folderNameArray[indexPath.row])] = nil
                self.saveData.set(self.deleteDict, forKey: "ToDoList")
                folderNameArray.remove(at: indexPath.row)
            } else {
                deleteDict[String(searchArray[indexPath.row])] = nil
                self.saveData.set(self.deleteDict, forKey: "ToDoList")
                searchArray.remove(at: indexPath.row)
                folderNameArray.remove(at: folderNameArray.index(of: searchArray[indexPath.row])!-1)
            }
            
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            
            saveData.set(self.folderNameArray, forKey: "folder")
            
            search()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingFolder = folderNameArray[sourceIndexPath.row]
        folderNameArray.remove(at: sourceIndexPath.row)
        folderNameArray.insert(movingFolder, at: destinationIndexPath.row)
        saveData.set(folderNameArray, forKey:"folder")
    }
    
    @IBAction func tapEdit(sender: AnyObject) {
        if isEditing {
            super.setEditing(false, animated: true)
            table.setEditing(false, animated: true)
            editButton.title = "編集"
            edit = false
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            table.allowsSelectionDuringEditing = true
            editButton.title = "完了"
            edit = true
        }
    }
    
    func edit(indexPath: IndexPath) {
        let beforeAddition = String(folderNameArray[indexPath.row])
        
        let alert = UIAlertController(title: "名称変更", message: "タイトル入力", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "変更", style: .default) { (action:UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let blank = String(describing: textField.text!).components(separatedBy: self.excludes).joined()
            if blank != ""{
                self.sameName = false
                for i in 0...self.folderNameArray.count-1{
                    if self.folderNameArray[i] == textField.text!{
                        self.sameName = true
                    }
                }
                
                if self.sameName{
                    self.showalert(message: "同名のフォルダがあります")
                    
                    self.deselect()
                }else{
                    self.folderNameArray[indexPath.row] = textField.text!
                    self.table.reloadData()
                }
            }else{
                self.showalert(message: "入力してください")
                
                self.deselect()
            }
            
            self.saveData.set(self.folderNameArray, forKey: "folder")
            
            self.editDict = self.saveData.object(forKey: "ToDoList") as! [String : Array<String>]
            self.editDict[String(self.folderNameArray[indexPath.row])] = self.editDict[beforeAddition!]
            self.editDict[beforeAddition!] = nil
            self.saveData.set(self.editDict, forKey: "ToDoList")
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action:UIAlertAction!) -> Void in
            self.deselect()
        }
        
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.text = self.folderNameArray[indexPath.row]
            textField.textAlignment = NSTextAlignment.left
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func add(sender: AnyObject) {
        let alert = UIAlertController(title: "フォルダ追加", message: "タイトル入力", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "追加", style: .default) { (action:UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            let blank = String(describing: textField.text!).components(separatedBy: self.excludes).joined()
            if blank != ""{
                self.sameName = false
                if self.folderNameArray.count != 0{
                    for i in 0...self.folderNameArray.count-1{
                        if self.folderNameArray[i] == textField.text!{
                            self.sameName = true
                        }
                    }
                }
                if self.sameName{
                    self.showalert(message: "同名のフォルダがあります")
                }else{
                    self.folderNameArray.append(textField.text!)
                    self.table.reloadData()
                    
                    self.saveData.set(self.folderNameArray, forKey: "folder")
                    self.saveData.synchronize()
                    
                    self.search()
                }
            }else{
                self.showalert(message: "入力してください")
            }
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action:UIAlertAction!) -> Void in
            self.deselect()
        }
        
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.textAlignment = NSTextAlignment.left
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - func
    
    func showalert(message: String) {
        let alert = UIAlertController(
            title: "エラー",
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func search() {
        if folderNameArray.count == 0{
            editButton.isEnabled = false
        }else{
            editButton.isEnabled = true
        }
    }
    
    func deselect() {
        if let indexPathForSelectedRow = self.table.indexPathForSelectedRow {
            self.table.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    // MARK: - else
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        self.view.endEditing(true)
    }
}

