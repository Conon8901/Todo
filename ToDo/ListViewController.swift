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
    
    var saveData = UserDefaults.standard
    
    var filesDict = [String: [String]]()
    
    var listNameArray = [String]()
    var searchArray = [String]()
    
    var numberOfCellsInScreen = 0
    
    // MARK: - Basics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        
        searchBar.delegate = self
        
        table.setUp()
        searchBar.setUp()
        
        listNameArray = saveData.object(forKey: "@folders") as! [String]
        
        filesDict = saveData.object(forKey: "@dictData") as! [String: [String]]
        
        numberOfCellsInScreen = Int(ceil((view.frame.height - (UIApplication.shared.statusBarFrame.height + navBar.frame.height + searchBar.frame.height)) / table.rowHeight))
        
        navBar.topItem?.title = NSLocalizedString("NAV_TITLE_FOLDER", comment: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text!.isEmpty {
            return listNameArray.count
        } else {
            return searchArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "List")
        
        if searchBar.text!.isEmpty {
            cell?.textLabel?.text = listNameArray[indexPath.row]
        } else {
            cell?.textLabel?.text = searchArray[indexPath.row]
        }
        
        cell?.textLabel?.numberOfLines = 0
        
        if cell?.textLabel?.text == saveData.object(forKey: "@folderName") as! String? {
            cell?.selectionStyle = .none
            cell?.textLabel?.textColor = .lightGray
        } else {
            cell?.selectionStyle = .default
            cell?.textLabel?.textColor = .black
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let folderName = saveData.object(forKey: "@folderName") as! String
        
        if searchBar.text!.isEmpty {
            if listNameArray[indexPath.row] != folderName {
                return indexPath
            } else {
                return nil
            }
        } else {
            if searchArray[indexPath.row] != folderName {
                return indexPath
            } else {
                return nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let preFolderName = saveData.object(forKey: "@folderName") as! String
        let fileName = variables.shared.movingFileName
        
        let preKey = preFolderName + "@" + fileName
        
        if searchBar.text!.isEmpty {
            let fileIndex = filesDict[listNameArray[indexPath.row]]!.index(of: fileName)
            
            let postKey = listNameArray[indexPath.row] + "@" + fileName
            
            if fileIndex == nil {
                filesDict[listNameArray[indexPath.row]]!.append(fileName)
                
                let index = filesDict[preFolderName]!.index(of: fileName)!
                filesDict[preFolderName]?.remove(at: index)
                
                saveData.set(filesDict, forKey: "@dictData")
                
                resaveDate(pre: preKey, post: postKey)
                
                variables.shared.isFromListView = true
                
                self.dismiss(animated: true, completion: nil)
            } else {
                let alert = UIAlertController(
                    title: NSLocalizedString("ALERT_TITLE_REPLACE", comment: ""),
                    message: NSLocalizedString("ALERT_MESSAGE_ERROR_SAME_FILE", comment: ""),
                    preferredStyle: .alert)
                
                let replaceAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_REPLACE", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
                    self.filesDict[self.listNameArray[indexPath.row]]!.remove(at: fileIndex!)
                    self.filesDict[self.listNameArray[indexPath.row]]!.append(fileName)
                    
                    let index = self.filesDict[preFolderName]!.index(of: fileName)!
                    self.filesDict[preFolderName]?.remove(at: index)
                    
                    self.saveData.set(self.filesDict, forKey: "@dictData")
                    
                    self.resaveDate(pre: preKey, post: postKey)
                    
                    variables.shared.isFromListView = true
                    
                    self.dismiss(animated: true, completion: nil)
                }
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_CANCEL", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
                    self.table.deselectCell()
                }
                
                alert.addAction(cancelAction)
                alert.addAction(replaceAction)
                
                present(alert, animated: true, completion: nil)
            }
        } else {
            let fileIndex = filesDict[searchArray[indexPath.row]]!.index(of: fileName)
            
            let postKey = searchArray[indexPath.row] + "@" + fileName
            
            if fileIndex == nil {
                filesDict[searchArray[indexPath.row]]!.append(fileName)
                
                let index = filesDict[preFolderName]!.index(of: fileName)!
                filesDict[preFolderName]?.remove(at: index)
                
                saveData.set(filesDict, forKey: "@dictData")
                
                resaveDate(pre: preKey, post: postKey)
                
                variables.shared.isFromListView = true
                
                self.dismiss(animated: true, completion: nil)
            } else {
                let alert = UIAlertController(
                    title: NSLocalizedString("ALERT_TITLE_REPLACE", comment: ""),
                    message: NSLocalizedString("ALERT_MESSAGE_ERROR_SAME_FILE", comment: ""),
                    preferredStyle: .alert)
                
                let replaceAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_REPLACE", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
                    self.filesDict[self.searchArray[indexPath.row]]!.remove(at: fileIndex!)
                    self.filesDict[self.searchArray[indexPath.row]]!.append(fileName)
                    
                    let index = self.filesDict[preFolderName]!.index(of: fileName)!
                    self.filesDict[preFolderName]?.remove(at: index)
                    
                    self.saveData.set(self.filesDict, forKey: "@dictData")
                    
                    self.resaveDate(pre: preKey, post: postKey)
                    
                    variables.shared.isFromListView = true
                    
                    self.dismiss(animated: true, completion: nil)
                }
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_CANCEL", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
                    self.table.deselectCell()
                }
                
                alert.addAction(cancelAction)
                alert.addAction(replaceAction)
                
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func add() {
        let alert = UIAlertController(
            title: NSLocalizedString("ALERT_TITLE_ADD", comment: ""),
            message: NSLocalizedString("ALERT_MESSAGE_ENTER", comment: ""),
            preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_ADD", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let isBlank = textField.text!.components(separatedBy: .whitespaces).joined().isEmpty
            
            if !isBlank {
                if self.listNameArray.index(of: textField.text!) == nil {
                    if !textField.text!.contains("@") {
                        self.listNameArray.append(textField.text!)
                        
                        self.filesDict[textField.text!] = []
                        
                        self.saveData.set(self.filesDict, forKey: "@dictData")
                        
                        self.saveData.set(self.listNameArray, forKey: "@folders")
                        
                        if self.searchBar.text!.isEmpty {
                            if self.listNameArray.count >= self.numberOfCellsInScreen {
                                let movingHeight = self.searchBar.frame.height + self.table.rowHeight * CGFloat(self.listNameArray.count) - self.view.frame.height
                                
                                self.table.scroll(y: movingHeight)
                            }
                        } else {
                            if self.searchArray.count >= self.numberOfCellsInScreen {
                                self.showSearchResult()
                                
                                let movingHeight = self.searchBar.frame.height + self.table.rowHeight * CGFloat(self.listNameArray.count) - self.view.frame.height
                                
                                self.table.scroll(y: movingHeight)
                            }
                        }
                        
                        self.table.reloadData()
                    } else {
                        self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_ATSIGN", comment: ""))
                        
                        self.table.deselectCell()
                    }
                } else {
                    self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_SAME_FOLDER", comment: ""))
                    
                    self.table.deselectCell()
                }
            } else {
                self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_ENTER", comment: ""))
                
                self.table.deselectCell()
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_CANCEL", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextField { (textField: UITextField!) -> Void in
            textField.textAlignment = .left
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - searchBar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ListViewController.closeKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        
        self.view.gestureRecognizers?.removeAll()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            searchArray.removeAll()
            searchArray = listNameArray
        } else {
            showSearchResult()
        }
        
        table.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if !searchBar.text!.isEmpty {
            showSearchResult()
            
            table.reloadData()
            
            searchBar.becomeFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        table.reloadData()
    }
    
    @objc func closeKeyboard() {
        searchBar.endEditing(true)
    }
    
    // MARK: - Method
    
    func showalert(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("ALERT_TITLE_ERROR", comment: ""),
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_CLOSE", comment: ""), style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showSearchResult() {
        searchArray.removeAll()
        
        switch searchBar.selectedScopeButtonIndex {
        case 0:
            searchArray = listNameArray.filter {
                $0.lowercased(with: .current).contains(searchBar.text!.lowercased(with: .current))
            }
        case 1:
            searchArray = listNameArray.filter {
                $0.lowercased(with: .current) == searchBar.text!.lowercased(with: .current)
            }
        default:
            break
        }
    }
    
    func resaveDate(pre: String, post: String) {
        let savedMemoText = saveData.object(forKey: pre + "@memo") as! String
        let savedisShownParts = saveData.object(forKey: pre + "@ison") as! Bool
        let savedDate = saveData.object(forKey: pre + "@date") as! Date?
        let savedisChecked = saveData.object(forKey: pre + "@check") as! Bool
        
        saveData.set(savedMemoText, forKey: post + "@memo")
        saveData.removeObject(forKey: pre + "@memo")
        
        saveData.set(savedisShownParts, forKey: post + "@ison")
        saveData.removeObject(forKey: pre + "@ison")
        
        if savedDate != nil {
            saveData.set(savedDate, forKey: post + "@date")
            saveData.removeObject(forKey: pre + "@date")
        }
        
        saveData.set(savedisChecked, forKey: post + "@check")
        saveData.removeObject(forKey: pre + "@check")
    }
    
    // MARK: - Others
    
    @IBAction func tapCancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
