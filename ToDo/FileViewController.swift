//
//  FileViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/06/03.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class FileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var navTitle: UINavigationBar!
    @IBOutlet var table: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var searchbar: UISearchBar!
    
    var saveData : UserDefaults = UserDefaults.standard
    
    let excludes = CharacterSet(charactersIn: "　 ")
    
    var openedFolder = ""
    var addfile = ""
    
    var addArray = [String]()
    var showDict = [String: Array<String>]()
    var searchArray = [String]()

    var edit: Bool = false
    var sameName: Bool = false
    
    @IBOutlet var BackToFolder: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table.dataSource = self
        table.delegate = self
        
        if saveData.object(forKey: "ToDoList") != nil{
            showDict = saveData.object(forKey: "ToDoList") as! [String : Array<String>]
        }else{
            self.saveData.set(self.showDict, forKey: "TodoList")
        }
        
        openedFolder = saveData.object(forKey: "move")! as! String
        
        if showDict[openedFolder] == nil {
            print("openedFolderisnil")
            editButton.isEnabled = false
            loadView()
            viewDidLoad()
        }
        
        search()
        
        searchbar.delegate = self
        searchbar.enablesReturnKeyAutomatically = false
        
        if showDict[openedFolder] != nil{
            searchArray = showDict[openedFolder]!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navTitle.topItem?.title = openedFolder
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //セル数設定
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
    
    //セル取得・表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "File")
        
        if searchbar.text != ""{
            cell?.textLabel?.text = searchArray[indexPath.row]
        }else{
            cell?.textLabel?.text = showDict[openedFolder]?[indexPath.row]
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
    
    //タッチ時の挙動
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if edit {
            edit(indexPath: indexPath)
        }else{
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    @IBAction func panLeft(_ sender: UIScreenEdgePanGestureRecognizer) {
        saveData.setValue(showDict, forKeyPath: "ToDoList")
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func allRemove(_ sender: UILongPressGestureRecognizer) {
        
        if (sender.state == UIGestureRecognizerState.began) {
            let alert = UIAlertController(title: "全削除", message: "本当によろしいですか？", preferredStyle: .alert)
            let saveAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) -> Void in
                
                self.showDict[self.openedFolder] = []
                self.saveData.set(self.showDict, forKey: "ToDoList")
                
                self.table.reloadData()
                
                self.editButton.isEnabled = false
            }
            
            let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action:UIAlertAction!) -> Void in
                
            }
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)

        }
    }
    
    @IBAction func back() {
        saveData.setValue(showDict, forKeyPath: "ToDoList")
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func add(sender: AnyObject) {
        
        let alert = UIAlertController(title: "項目追加", message: "タイトル入力", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "追加", style: .default) { (action:UIAlertAction!) -> Void in
            
            let textField = alert.textFields![0] as UITextField
            let blank = String(describing: textField.text).components(separatedBy: self.excludes).joined()
            if blank != "Optional(\"\")"{
                
                if self.saveData.object(forKey: "ToDoList") != nil{
                    self.showDict = self.saveData.object(forKey: "ToDoList") as! [String : Array<String>]
                }
                
                //オプショナルバインディング nilの値を安全に取り出す
                if let dict = self.showDict[self.openedFolder] {
                    self.addArray = dict
                }else {
                    print("nil")
                }
                self.addfile = textField.text!
                self.addArray.append(self.addfile)
                self.showDict[self.openedFolder] = self.addArray
                
                self.saveData.setValue(self.showDict, forKeyPath: "ToDoList")
                
                self.saveData.synchronize()
                self.table.reloadData()
                
                self.search()
            
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
    
    //削除関係
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            showDict[openedFolder]?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            saveData.set(self.showDict, forKey: "ToDoList")

            search()
        }
    }
    
    //並び替え関係
    @IBAction func tapEdit(sender: AnyObject) {
        if isEditing {
            super.setEditing(false, animated: true)
            table.setEditing(false, animated: true)
            edit = false
            BackToFolder.isEnabled = true
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            table.allowsSelectionDuringEditing = true
            edit = true
            BackToFolder.isEnabled = false
        }
    }

    //セルの移動時に呼ばれる
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
    
    
    func edit(indexPath: IndexPath) {
        let alert = UIAlertController(title: "名称変更", message: "タイトル入力", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "変更", style: .default) { (action:UIAlertAction!) -> Void in

            let textField = alert.textFields![0] as UITextField
            
            let blank = String(describing: textField.text).components(separatedBy: self.excludes).joined()
            if blank != "Optional(\"\")"{
                self.showDict[self.openedFolder]?[indexPath.row] = textField.text!
                self.table.reloadData()
            }else{
                self.showalert(title: "エラー", message: "入力してください")
                if let indexPathForSelectedRow = self.table.indexPathForSelectedRow {
                    self.table.deselectRow(at: indexPathForSelectedRow, animated: true)
                }
            }
            
            self.saveData.set(self.showDict, forKey: "ToDoList")
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action:UIAlertAction!) -> Void in
            
            if let indexPathForSelectedRow = self.table.indexPathForSelectedRow {
                self.table.deselectRow(at: indexPathForSelectedRow, animated: true)
            }

        }
        
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.text = self.showDict[self.openedFolder]?[indexPath.row]
            textField.textAlignment = NSTextAlignment.left
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)

    }
    
    func showalert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func search() {
        if showDict[openedFolder]?.count == 0{
            editButton.isEnabled = false
        }else{
            editButton.isEnabled = true
        }
    }
    
}
