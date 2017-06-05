//
//  ViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/06/03.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class FolderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //TableView宣言
    @IBOutlet var table: UITableView!
    
    var folderNameArray = [String]()
    
    var saveData : UserDefaults = UserDefaults.standard
    
    let excludes = CharacterSet(charactersIn: "　 ")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        table.dataSource = self
        
        table.delegate = self
        
        folderNameArray = saveData.object(forKey: "folder") as! [String]
        self.saveData.set(self.folderNameArray, forKey: "folder")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //セル数設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderNameArray.count
    }
    
    //セル取得・表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Folder")
        
        cell?.textLabel?.text = folderNameArray[indexPath.row]
        
        return cell!
    }
    
    //タッチ時の挙動
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Folder: \(folderNameArray[indexPath.row])を選択")
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "File") as! FileViewController
        self.present(nextView, animated: true, completion: nil)
    }//\(filenameArray[indexPath.row])でforKey設定してsavedata,読み込み
    
    @IBAction func add(sender: AnyObject) {
        
        let alert = UIAlertController(title: "フォルダ追加", message: "タイトル入力", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "追加", style: .default) { (action:UIAlertAction!) -> Void in
            
            // 入力したテキストを配列に代入
            let textField = alert.textFields![0] as UITextField
            let add = String(describing: textField.text).components(separatedBy: self.excludes).joined()
            if add != "Optional(\"\")"{
                self.folderNameArray.append(textField.text!)
                print(self.folderNameArray)
                self.table.reloadData()
                
                self.saveData.set(self.folderNameArray, forKey: "folder")
                self.saveData.synchronize()
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
            folderNameArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
        }
    }

    
}
