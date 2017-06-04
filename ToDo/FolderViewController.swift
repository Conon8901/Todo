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

    var foldernameArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        table.dataSource = self
        
        table.delegate = self
        
        foldernameArray = ["学校", "LifeisTech", "SEG"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //セル数設定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foldernameArray.count
    }
    
    //セル取得・表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Folder")
        
        cell?.textLabel?.text = foldernameArray[indexPath.row]
        
        return cell!
    }
    
    //タッチ時の挙動
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Folder: \(foldernameArray[indexPath.row])を選択")
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "File") as! FileViewController
        self.present(nextView, animated: true, completion: nil)
    }
    
    @IBAction func add(sender: AnyObject) {
        
        let alert = UIAlertController(title: "フォルダ追加", message: "タイトル入力", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "追加", style: .default) { (action:UIAlertAction!) -> Void in
            
            // 入力したテキストをコンソールに表示
            let textField = alert.textFields![0] as UITextField
            self.foldernameArray.append(textField.text!)
            print(self.foldernameArray)
            self.table.reloadData()
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
    
}

