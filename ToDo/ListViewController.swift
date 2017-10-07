//
//  ListViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/09/08.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: - Declare
    
    @IBOutlet var table: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var navBar: UINavigationBar!
    
    var listNameArray = [String]()
    var searchArray = [String]()
    
    var saveData = UserDefaults.standard
    
    var isSameName = false
    
    // MARK: - Basics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        
        listNameArray = saveData.object(forKey: "@folders") as! [String]
        
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = false
        
        table.keyboardDismissMode = .interactive
        table.allowsSelectionDuringEditing = true
        
        let partial = NSLocalizedString("部分", comment: "")
        let exact = NSLocalizedString("完全", comment: "")
        let forward = NSLocalizedString("前方", comment: "")
        let backward = NSLocalizedString("後方", comment: "")
        
        searchBar.scopeButtonTitles = [partial, exact, forward, backward]
        
        navBar.topItem?.title = NSLocalizedString("フォルダ", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text == "" {
            return listNameArray.count
        } else {
            return searchArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "List")
        
        if searchBar.text == "" {
            cell?.textLabel?.text = listNameArray[indexPath.row]
        } else {
            cell?.textLabel?.text = searchArray[indexPath.row]
        }
        
        cell?.textLabel?.numberOfLines = 0
    
        if cell?.textLabel?.text == saveData.object(forKey: "@folderName") as! String? {
            cell?.selectionStyle = .none
            cell?.textLabel?.textColor = .lightGray
        }
    
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let folderName = saveData.object(forKey: "@folderName") as! String
        
        if searchBar.text == "" {
            if listNameArray[indexPath.row] == folderName {
                return nil
            } else {
                return indexPath
            }
        } else {
            if searchArray[indexPath.row] == folderName {
                return nil
            } else {
                return indexPath
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var dic: [String : Array<String>] = saveData.object(forKey: "@dictData") as! [String : Array<String>]
        let fromFolderName = saveData.object(forKey: "@folderName") as! String
        let fileName = saveData.object(forKey: "@movingFileName") as! String
        let formerkey = fromFolderName+"@"+fileName
        let memotextview = saveData.object(forKey: formerkey) as! String?
        let dateswitch = saveData.object(forKey: formerkey+"@ison") as! Bool?
        let datepicker = saveData.object(forKey: formerkey+"@date") as! Date?
        var laterkey = ""
        
        if searchBar.text == "" {
            if dic[listNameArray[indexPath.row]] == nil {
                dic[listNameArray[indexPath.row]] = [fileName]
            } else {
                dic[listNameArray[indexPath.row]]!.append(fileName)
            }
            
            dic[fromFolderName]?.remove(at: (dic[fromFolderName]?.index(of: fileName))!)
            
            laterkey = listNameArray[indexPath.row]+"@"+fileName
        } else {
            if dic[searchArray[indexPath.row]] == nil {
                dic[searchArray[indexPath.row]] = [fileName]
            } else {
                dic[searchArray[indexPath.row]]!.append(fileName)
            }
            
            dic[fromFolderName]?.remove(at: (dic[fromFolderName]?.index(of: fileName))!)
            
            laterkey = searchArray[indexPath.row]+"@"+fileName
        }
        
        if memotextview != nil {
            saveData.set(memotextview, forKey: laterkey)
            saveData.removeObject(forKey: formerkey)
        }
        
        if dateswitch != nil {
            saveData.set(dateswitch, forKey: laterkey+"@ison")
            saveData.removeObject(forKey: formerkey+"@ison")
        }
        
        if datepicker != nil {
            saveData.set(datepicker, forKey: laterkey+"@date")
            saveData.removeObject(forKey: formerkey+"@date")
        }
        
        saveData.set(dic, forKey: "@dictData")
        
        saveData.set(true, forKey: "@isFromListView")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func add() {
        let alert = UIAlertController(title: NSLocalizedString("フォルダ追加", comment: ""), message: NSLocalizedString("タイトル入力", comment: ""), preferredStyle: .alert)
        let saveAction = UIAlertAction(title: NSLocalizedString("追加", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let isBlank = textField.text!.components(separatedBy: CharacterSet.whitespaces).joined() == ""
            
            if isBlank {
                self.showalert(message: NSLocalizedString("入力してください", comment: ""))
            } else {
                self.isSameName = false
                if self.listNameArray.count != 0 {
                    for i in 0...self.listNameArray.count-1 {
                        if self.listNameArray[i] == textField.text! {
                            self.isSameName = true
                        }
                    }
                }
                
                if self.isSameName {
                    self.showalert(message: NSLocalizedString("同名のフォルダがあります", comment: ""))
                } else {
                    if (textField.text?.contains("@"))! {
                        self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                        
                        self.deselect()
                    } else {
                        self.listNameArray.append(textField.text!)
                        self.table.reloadData()
                        
                        self.saveData.set(self.listNameArray, forKey: "@folders")
                        
                        var dict = self.saveData.object(forKey: "@dictData") as! [String : Array<String>]
                        dict[textField.text!] = []
                        self.saveData.set(dict, forKey: "@dictData")
                        
                        if self.listNameArray.count >= 11 {
                            let location = CGPoint(x: 0, y: self.table.contentSize.height-self.table.frame.height)
                            self.table.setContentOffset(location, animated: true)
                        }
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextField { (textField: UITextField!) -> Void in
            textField.textAlignment = .left
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - searchBar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            searchArray.removeAll()
            searchArray = listNameArray
        } else {
            search()
        }
        
        table.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if searchBar.text != "" {
            search()
            table.reloadData()
            searchBar.becomeFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        table.reloadData()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if table.contentOffset.y < -64 {
            searchBar.endEditing(true)
        }
    }
    
    // MARK: - Method
    
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
    
    func search() {
        searchArray.removeAll()
        
        for folderName in listNameArray {
            switch searchBar.selectedScopeButtonIndex {
            case 0:
                if folderName.lowercased(with: NSLocale.current).contains(searchBar.text!.lowercased(with: NSLocale.current)) {
                    searchArray.append(folderName)
                }
            case 1:
                if folderName.lowercased(with: NSLocale.current) == searchBar.text!.lowercased(with: NSLocale.current) {
                    searchArray.append(folderName)
                }
            case 2:
                if folderName.lowercased(with: NSLocale.current).hasPrefix(searchBar.text!.lowercased(with: NSLocale.current)) {
                    searchArray.append(folderName)
                }
            case 3:
                if folderName.lowercased(with: NSLocale.current).hasSuffix(searchBar.text!.lowercased(with: NSLocale.current)) {
                    searchArray.append(folderName)
                }
            default:
                break
            }
        }
    }
    
    // MARK: - Else
    
    @IBAction func tapCancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
