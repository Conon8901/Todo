//
//  FileViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/06/03.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class FileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var navTitle: UINavigationBar!
    //TableView宣言
    @IBOutlet var table: UITableView!
    
    var saveData : UserDefaults = UserDefaults.standard
    
    let excludes = CharacterSet(charactersIn: "　 ")
    
    var moved = ""
    
    var addfile = ""
    
    var addArray = [String]()
    
    var showDict = [String: Array<String>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table.dataSource = self
        table.delegate = self
        
        self.saveData.set(self.showDict, forKey: "TodoList")
        showDict = saveData.object(forKey: "ToDoList") as! [String : Array<String>]
        
        moved = saveData.object(forKey: "move")! as! String

        if showDict[moved] == nil{
            showDict[moved] = []
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navTitle.topItem?.title = moved
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //セル数設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showDict[moved]!.count
    }
    
    //セル取得・表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "File")
        
        cell?.textLabel?.text = showDict[moved]?[indexPath.row]
        
        return cell!
    }
    
    //タッチ時の挙動
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("File: \(showDict[moved]?[indexPath.row])を選択")
        edit(indexPath: indexPath)
    }
    
    @IBAction func back() {
        saveData.setValue(showDict, forKeyPath: "ToDoList")
        _ = self.navigationController?.popViewController(animated: true)
        print(showDict)
    }
    
    @IBAction func add(sender: AnyObject) {
        
        let alert = UIAlertController(title: "項目追加", message: "タイトル入力", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "追加", style: .default) { (action:UIAlertAction!) -> Void in
            
            // 入力したテキストを配列に代入
            let textField = alert.textFields![0] as UITextField
            let add = String(describing: textField.text).components(separatedBy: self.excludes).joined()
            if add != "Optional(\"\")"{
                self.showDict = self.saveData.object(forKey: "ToDoList") as! [String : Array<String>]
                //オプショナルバインディング nilの値を安全に取り出す
                if let dict = self.showDict[self.moved] {
                    self.addArray = dict
                }else {
                    print("nil")
                }
                self.addfile = textField.text!
                self.addArray.append(self.addfile)
                self.showDict[self.moved] = self.addArray
                
                self.saveData.setValue(self.showDict, forKeyPath: "ToDoList")
                print("後: \(self.showDict[self.moved])")
                
                self.saveData.synchronize()
                self.table.reloadData()
            
            }
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action:UIAlertAction!) -> Void in
        }
        
        // UIAlertControllerにtextFieldを追加
        alert.addTextField { (textField:UITextField!) -> Void in
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
            showDict[moved]?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            saveData.set(self.showDict, forKey: "ToDoList")
        }
    }
    
    //並び替え関係
    @IBAction func tapEdit(sender: AnyObject) {
        if isEditing {
            super.setEditing(false, animated: true)
            table.setEditing(false, animated: true)
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
        }
    }

    //セルの移動時に呼ばれる
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let delete = showDict[moved]?[sourceIndexPath.row]
        showDict[moved]?.remove(at: sourceIndexPath.row)
        showDict[moved]?.insert(delete!, at: destinationIndexPath.row)
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    
    func edit(indexPath: IndexPath) {
        let alert = UIAlertController(title: "名称変更", message: "タイトル入力", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "変更", style: .default) { (action:UIAlertAction!) -> Void in

            // 入力したテキストに変更
            let textField = alert.textFields![0] as UITextField
            
            let add = String(describing: textField.text).components(separatedBy: self.excludes).joined()
            if add != "Optional(\"\")"{
                self.showDict[self.moved]?[indexPath.row] = textField.text!
                self.table.reloadData()
            }else{
                self.showDict[self.moved]?.remove(at: indexPath.row)
                self.table.deleteRows(at: [indexPath], with: .fade)
                self.table.reloadData()
            }
            
            self.saveData.set(self.showDict, forKey: "ToDoList")
            print("前: \(self.showDict[self.moved])")
            
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action:UIAlertAction!) -> Void in
            
            if let indexPathForSelectedRow = self.table.indexPathForSelectedRow {
                self.table.deselectRow(at: indexPathForSelectedRow, animated: true)
            }

        }
        
        // UIAlertControllerにtextFieldを追加
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.text = self.showDict[self.moved]?[indexPath.row]
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)

    }
    
    
}
