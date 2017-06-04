//
//  FileViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/06/03.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class FileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //TableView宣言
    @IBOutlet var table: UITableView!
    
    var filenameArray = [String]()
    
    var saveData : UserDefaults = UserDefaults.standard//////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        table.dataSource = self
        
        table.delegate = self
        
        filenameArray = saveData.object(forKey: "file") as! [String]/////////////////////////////////////
        self.saveData.set(self.filenameArray, forKey: "file")////////////////////////////////////////////
        self.saveData.synchronize()//////////////////////////////////////////////////////////////////////
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //セル数設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filenameArray.count
    }
    
    //セル取得・表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "File")
        
        cell?.textLabel?.text = filenameArray[indexPath.row]
        
        return cell!
    }
    
    //タッチ時の挙動
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("File: \(filenameArray[indexPath.row])を選択")
    }
    
    @IBAction func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func add(sender: AnyObject) {
        
        let alert = UIAlertController(title: "フォルダ追加", message: "タイトル入力", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "追加", style: .default) { (action:UIAlertAction!) -> Void in
            
            // 入力したテキストをコンソールに表示
            let textField = alert.textFields![0] as UITextField
            self.filenameArray.append(textField.text!)
            print(self.filenameArray)
            self.table.reloadData()
            
            self.saveData.set(self.filenameArray, forKey: "file")////////////////////////////////////////
            self.saveData.synchronize()//////////////////////////////////////////////////////////////////
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) -> Void in
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
            filenameArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
        }
    }

}
