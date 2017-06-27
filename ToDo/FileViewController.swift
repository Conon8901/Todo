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
    var showDict = ["LiT": ["ToDo", "Camera"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table.dataSource = self
        table.delegate = self
//        self.saveData.set(self.showDict, forKey: "ToDoList")
        showDict = saveData.object(forKey: "ToDoList") as! [String : Array<String>]
        
        print("Folder名: \(saveData.object(forKey: "move")!)")//LiT
        moved = saveData.object(forKey: "move")! as! String

        print(showDict)
        
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
        
        cell?.textLabel?.text = showDict[moved]?[indexPath.row]/////
        
        return cell!
    }
    
    //タッチ時の挙動
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("File: \(showDict[moved]?[indexPath.row])を選択")
    }
    
    @IBAction func back() {
        self.saveData.set(self.showDict, forKey: "file")
        _ = self.navigationController?.popViewController(animated: true)
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
                self.showDict[self.moved] = self.addArray//追加にする
                
                print(self.showDict[self.moved]!)//保存内容
                self.saveData.setValue(self.showDict, forKeyPath: "ToDoList")
                print(self.saveData.object(forKey: "ToDoList")!)
                
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

    // セルの並び替えを有効にする
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    }
    
}
