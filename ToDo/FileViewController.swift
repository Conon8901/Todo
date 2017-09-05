//
//  FileViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/06/03.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class FileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: - Declare
    
    @IBOutlet var table: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var searchbar: UISearchBar!
    @IBOutlet var navtitle: UIButton!
    
    var saveData = UserDefaults.standard
    
    let excludes = CharacterSet(charactersIn: "　 ")
    
    var openedFolder = ""
    var addfile = ""
    
    var addArray = [String]()
    var showDict = [String:Array<String>]()
    var searchArray = [String]()

    var edit = false
    var sameName = false
    var button = false
    
    // MARK: - Basics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        
        if saveData.object(forKey: "ToDoList") != nil{
            showDict = saveData.object(forKey: "ToDoList") as! [String : Array<String>]
        }else{
            self.saveData.set(self.showDict, forKey: "TodoList")
        }
        
        openedFolder = saveData.object(forKey: "move")! as! String
        
        search()
            
        if showDict[openedFolder] != nil {
            searchArray = showDict[openedFolder]!
        }
        
        searchbar.delegate = self
        searchbar.enablesReturnKeyAutomatically = false
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(FileViewController.allRemove(_:)))
        self.navtitle.addGestureRecognizer(longPressGesture)
    
        navigationItem.backBarButtonItem = UIBarButtonItem(title: openedFolder, style: .plain, target: nil, action: nil)
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navtitle.setTitle(openedFolder, for: .normal)
        table.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveData.setValue(showDict, forKeyPath: "ToDoList")
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
            searchArray = showDict[openedFolder]!
        } else {
            for data in showDict[openedFolder]! {
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
            if showDict[openedFolder] == nil{
                return 0
            }else{
                return showDict[openedFolder]!.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "File")
        
        if searchbar.text != ""{
            cell?.textLabel?.text = searchArray[indexPath.row]
        }else{
            cell?.textLabel?.text = showDict[openedFolder]?[indexPath.row]
        }
        
        let text = (showDict[openedFolder]?[indexPath.row])!
        if let subtitle = saveData.object(forKey: openedFolder+text) as! String?{
            cell?.detailTextLabel?.text = subtitle
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if edit {
            edit(indexPath: indexPath)
        }else{
            if(searchbar.text == "") {
                saveData.set(String(showDict[openedFolder]![indexPath.row]), forKey: "memo")
            } else {
                saveData.set(String(searchArray[indexPath.row]), forKey: "memo")
            }
            
            saveData.set(openedFolder, forKey: "foldername")
            
            let storyboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "Memo") as! MemoViewController
            self.navigationController?.pushViewController(nextView, animated: true)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if searchbar.text == ""{
                saveData.set("", forKey: openedFolder+(showDict[openedFolder]?[indexPath.row])!)
                showDict[openedFolder]?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                saveData.set(self.showDict, forKey: "ToDoList")
            }else{
                saveData.set("", forKey: openedFolder+searchArray[indexPath.row])
                showDict[openedFolder]?.remove(at: (showDict[openedFolder]?.index(of: searchArray[indexPath.row])!)!)
                searchArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                saveData.set(self.showDict, forKey: "ToDoList")
            }
            
            search()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingFile = showDict[openedFolder]?[sourceIndexPath.row]
        showDict[openedFolder]?.remove(at: sourceIndexPath.row)
        showDict[openedFolder]?.insert(movingFile!, at: destinationIndexPath.row)
        saveData.setValue(showDict, forKeyPath: "ToDoList")
        table.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    @IBAction func add(sender: AnyObject) {
        let alert = UIAlertController(title: "項目追加", message: "タイトル入力", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "追加", style: .default) { (action:UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            let blank = String(describing: textField.text!).components(separatedBy: self.excludes).joined()
            if blank != ""{
                self.sameName = false
                
                if self.showDict[self.openedFolder]?.isEmpty == false{
                    for i in 0...(self.showDict[self.openedFolder]?.count)!-1{
                        if self.showDict[self.openedFolder]?[i] == textField.text!{
                            self.sameName = true
                        }
                    }
                }
                
                if self.sameName{
                    self.showalert(title: "エラー", message: "同名のファイルがあります")
                    
                    self.deselect()
                }else{
                    if self.saveData.object(forKey: "ToDoList") != nil{
                        self.showDict = self.saveData.object(forKey: "ToDoList") as! [String : Array<String>]
                    }
                    
                    if let dict = self.showDict[self.openedFolder] {
                        self.addArray = dict
                    }
                    self.addfile = textField.text!
                    self.addArray.append(self.addfile)
                    self.showDict[self.openedFolder] = self.addArray
                    
                    self.saveData.setValue(self.showDict, forKeyPath: "ToDoList")
                    
                    self.saveData.synchronize()
                    self.table.reloadData()
                    
                    self.search()
                }
            }else{
                self.showalert(title: "エラー", message: "入力してください")
            }
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action:UIAlertAction!) -> Void in
        }
        
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.textAlignment = NSTextAlignment.left
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func edit(indexPath: IndexPath) {
        let alert = UIAlertController(title: "名称変更", message: "タイトル入力", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "変更", style: .default) { (action:UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let blank = String(describing: textField.text!).components(separatedBy: self.excludes).joined()
            if blank != ""{
                self.sameName = false
                for i in 0...(self.showDict[self.openedFolder]?.count)!-1{
                    if self.showDict[self.openedFolder]?[i] == textField.text!{
                        self.sameName = true
                    }
                }
                
                if self.sameName, textField.text != self.showDict[self.openedFolder]?[indexPath.row]{
                    self.showalert(title: "エラー", message: "同名のフォルダがあります")
                    
                    self.deselect()
                }else{
                    let formertext = (self.showDict[self.openedFolder]?[indexPath.row])!
                    
                    self.showDict[self.openedFolder]?[indexPath.row] = textField.text!
                    
                    let revisedtext = (self.showDict[self.openedFolder]?[indexPath.row])!
                    
                    let formermemo = self.saveData.object(forKey: self.openedFolder+formertext)
                    
                    self.saveData.set("", forKey: self.openedFolder+formertext)
                    self.saveData.set(formermemo, forKey: self.openedFolder+revisedtext)
                    
                    self.table.reloadData()
                }
            }else{
                self.showalert(title: "エラー", message: "入力してください")
                
                self.deselect()
            }
            
            self.saveData.set(self.showDict, forKey: "ToDoList")
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action:UIAlertAction!) -> Void in
            self.deselect()
        }
        
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.text = self.showDict[self.openedFolder]?[indexPath.row]
            textField.textAlignment = NSTextAlignment.left
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func tapEdit(sender: AnyObject) {
        if isEditing {
            super.setEditing(false, animated: true)
            table.setEditing(false, animated: true)
            editButton.title = "編集"
            edit = false
            navigationItem.hidesBackButton = false
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            table.allowsSelectionDuringEditing = true
            editButton.title = "完了"
            edit = true
            navigationItem.hidesBackButton = true
        }
    }
    
    func allRemove(_ sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            let alert = UIAlertController(title: "全削除", message: "本当によろしいですか？", preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: "OK", style: .destructive) { (action:UIAlertAction!) -> Void in
                let count = (self.showDict[self.openedFolder]?.count)!
                if count != 0{
                    for i in 0...count-1{
                        self.saveData.set("", forKey: self.openedFolder+(self.showDict[self.openedFolder]?[i])!)
                    }
                    
                    self.showDict[self.openedFolder] = []
                    self.searchArray = []
                    
                    self.saveData.set(self.showDict, forKey: "ToDoList")
                    
                    self.table.reloadData()
                    
                    self.editButton.isEnabled = false
                }
            }
            
            let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action:UIAlertAction!) -> Void in
            }
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Method
    
    func showalert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func search() {
        let count: Int? = showDict[openedFolder]?.count
        if count == nil {
            editButton.isEnabled = false
        }else{
            if count! == 0{
                editButton.isEnabled = false
            }else{
                editButton.isEnabled = true
            }
        }
    }
    
    func deselect() {
        if let indexPathForSelectedRow = self.table.indexPathForSelectedRow {
            self.table.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    // MARK: - Else

    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        self.view.endEditing(true)
//        print(saveData.object(forKey: "sdgs")!)//クラッシュ
    }
}

