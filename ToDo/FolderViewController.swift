//
//  ViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/06/03.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class FolderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPathForSelectedRow = table.indexPathForSelectedRow {
            table.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }

    //セル数設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchbar.text != ""{
            return searchArray.count
        }else{
            return folderNameArray.count
        }
    }
    
    //セル取得・表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Folder")
        
        if searchbar.text != ""{
            cell?.textLabel?.text = searchArray[indexPath.row]
        }else{
            cell?.textLabel?.text = folderNameArray[indexPath.row]
        }
        
        return cell!
    }
    
    //検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchbar.endEditing(true)
    }
    
    //テキスト変更時の呼び出しメソッド
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
    
    //タッチ時の挙動
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if edit {
            let beforeAddition = String(folderNameArray[indexPath.row])
            
            let alert = UIAlertController(title: "名称変更", message: "タイトル入力", preferredStyle: .alert)
            let saveAction = UIAlertAction(title: "変更", style: .default) { (action:UIAlertAction!) -> Void in
                
                let textField = alert.textFields![0] as UITextField
                
                let blank = String(describing: textField.text).components(separatedBy: self.excludes).joined()
                if blank != "Optional(\"\")"{
                    self.sameName = false
                    for i in 0...self.folderNameArray.count-1{
                        if self.folderNameArray[i] == textField.text!{
                            self.sameName = true
                        }
                    }
                    
                    if self.sameName{
                        self.showalert(message: "同名のフォルダがあります")

                    }else{
                        if textField.text != "move" && textField.text != "folder" && textField.text != "TodoList" && textField.text != "ToDoList"{
                            self.folderNameArray[indexPath.row] = textField.text!
                            self.table.reloadData()
                        }else{
                            self.showalert(message: "その名称は使用できません")
                        }
                    }
                }else{
                    self.showalert(message: "入力してください")
                }
                
                self.saveData.set(self.folderNameArray, forKey: "folder")
                
                self.editDict = self.saveData.object(forKey: "ToDoList") as! [String : Array<String>]
                self.editDict[String(self.folderNameArray[indexPath.row])] = self.editDict[beforeAddition!]
                self.editDict[beforeAddition!] = nil
                self.saveData.set(self.editDict, forKey: "ToDoList")
            }
            
            let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action:UIAlertAction!) -> Void in
                
                if let indexPathForSelectedRow = self.table.indexPathForSelectedRow {
                    self.table.deselectRow(at: indexPathForSelectedRow, animated: true)
                }
                
            }
            
            alert.addTextField { (textField:UITextField!) -> Void in
                textField.text = self.folderNameArray[indexPath.row]
                textField.textAlignment = NSTextAlignment.left
            }
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)

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
    
    @IBAction func add(sender: AnyObject) {
        
        let alert = UIAlertController(title: "フォルダ追加", message: "タイトル入力", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "追加", style: .default) { (action:UIAlertAction!) -> Void in
            
            let textField = alert.textFields![0] as UITextField
            let blank = String(describing: textField.text).components(separatedBy: self.excludes).joined()
            if blank != "Optional(\"\")"{
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
                    if textField.text != "move" && textField.text != "folder" && textField.text != "TodoList" && textField.text != "ToDoList"{
                        self.folderNameArray.append(textField.text!)
                        self.table.reloadData()
                        
                        self.saveData.set(self.folderNameArray, forKey: "folder")
                        self.saveData.synchronize()
                        
                        self.search()
                    }else{
                        self.showalert(message: "その名称は使用できません")
                    }

                }
                
            }else{
                self.showalert(message: "入力してください")
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
    
    
    //削除関係
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            deleteDict = saveData.object(forKey: "ToDoList") as! [String : Array<String>]
            deleteDict[String(folderNameArray[indexPath.row])] = nil
            self.saveData.set(self.deleteDict, forKey: "ToDoList")
            folderNameArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            
            saveData.set(self.folderNameArray, forKey: "folder")
            
            search()
        }
    }

    //並び替え関係
    @IBAction func tapEdit(sender: AnyObject) {
        if isEditing {
            super.setEditing(false, animated: true)
            table.setEditing(false, animated: true)
            edit = false
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            table.allowsSelectionDuringEditing = true
            edit = true
        }
    }
    
    //セルの移動時に呼ばれる
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingFolder = folderNameArray[sourceIndexPath.row]
        folderNameArray.remove(at: sourceIndexPath.row)
        folderNameArray.insert(movingFolder, at: destinationIndexPath.row)
        saveData.set(folderNameArray, forKey:"folder")
    }
    
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
    
}
