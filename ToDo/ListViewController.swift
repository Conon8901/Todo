//
//  ListViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/09/08.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    // MARK: - Declare
    
    @IBOutlet var table: UITableView!
    @IBOutlet var navBar: UINavigationBar!
    
    var searchController = UISearchController(searchResultsController: nil)
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var listNameArray = [String]()
    var searchArray = [String]()
    
    var filesDict = [String: [String]]()
    
    var saveData = UserDefaults.standard
    
    var numberOfCellsInScreen = 0
    
    var statusNavHeight: CGFloat = 0.0
    
    // MARK: - Basics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 60
        
        listNameArray = saveData.object(forKey: "@folders") as! [String]
        
        filesDict = saveData.object(forKey: "@dictData") as! [String: [String]]
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        table.tableHeaderView = searchController.searchBar
        
        table.keyboardDismissMode = .interactive
        table.allowsSelectionDuringEditing = true
        
        numberOfCellsInScreen = Int(ceil((view.frame.height - (UIApplication.shared.statusBarFrame.height + navBar.frame.height + searchController.searchBar.frame.height)) / table.rowHeight))
        
        navBar.topItem?.title = NSLocalizedString("FOLDER", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.searchBar.text!.isEmpty {
            return listNameArray.count
        } else {
            return searchArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "List")
        
        if searchController.searchBar.text!.isEmpty {
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
        
        if searchController.searchBar.text!.isEmpty {
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
        let fromFolderName = saveData.object(forKey: "@folderName") as! String
        let fileName = self.appDelegate.movingFileName
        
        let formerKey = fromFolderName + "@" + fileName
        
        if searchController.searchBar.text!.isEmpty {
            let fileIndex = filesDict[listNameArray[indexPath.row]]!.index(of: fileName)
            
            let latterKey = self.listNameArray[indexPath.row] + "@" + fileName
            
            if fileIndex == nil {
                self.filesDict[self.listNameArray[indexPath.row]]!.append(fileName)
                
                let index = self.filesDict[fromFolderName]!.index(of: fileName)!
                self.filesDict[fromFolderName]?.remove(at: index)
                
                resaveDate(pre: formerKey, post: latterKey)
                
                self.saveData.set(self.filesDict, forKey: "@dictData")
                
                appDelegate.isFromListView = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(
                    title: NSLocalizedString("REPLACE_TITLE", comment: ""),
                    message: NSLocalizedString("SAME_FILE", comment: ""),
                    preferredStyle: .alert)
                
                let replaceAction = UIAlertAction(title: NSLocalizedString("REPLACE_BUTTON", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
                    self.filesDict[self.listNameArray[indexPath.row]]!.remove(at: fileIndex!)
                    self.filesDict[self.listNameArray[indexPath.row]]!.append(fileName)
                    
                    let index = self.filesDict[fromFolderName]!.index(of: fileName)!
                    self.filesDict[fromFolderName]?.remove(at: index)
                    
                    self.resaveDate(pre: formerKey, post: latterKey)
                    
                    self.saveData.set(self.filesDict, forKey: "@dictData")
                    
                    self.appDelegate.isFromListView = true
                    
                    self.dismiss(animated: true, completion: nil)
                }
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
                    self.deselectCell()
                }
                
                alert.addAction(cancelAction)
                alert.addAction(replaceAction)
                
                present(alert, animated: true, completion: nil)
            }
        } else {
            let fileIndex = filesDict[searchArray[indexPath.row]]!.index(of: fileName)
            
            let latterKey = searchArray[indexPath.row] + "@" + fileName
            
            if fileIndex == nil {
                filesDict[searchArray[indexPath.row]]!.append(fileName)
                
                let index = filesDict[fromFolderName]!.index(of: fileName)!
                filesDict[fromFolderName]?.remove(at: index)
                
                resaveDate(pre: formerKey, post: latterKey)
                
                saveData.set(filesDict, forKey: "@dictData")
                
                appDelegate.isFromListView = true
                
                searchController.isActive = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                let alert = UIAlertController(
                    title: NSLocalizedString("REPLACE_TITLE", comment: ""),
                    message: NSLocalizedString("SAME_FILE", comment: ""),
                    preferredStyle: .alert)
                
                let replaceAction = UIAlertAction(title: NSLocalizedString("REPLACE_BUTTON", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
                    self.filesDict[self.searchArray[indexPath.row]]!.remove(at: fileIndex!)
                    self.filesDict[self.searchArray[indexPath.row]]!.append(fileName)
                    
                    let index = self.filesDict[fromFolderName]!.index(of: fileName)!
                    self.filesDict[fromFolderName]?.remove(at: index)
                    
                    self.resaveDate(pre: formerKey, post: latterKey)
                    
                    self.saveData.set(self.filesDict, forKey: "@dictData")
                    
                    self.appDelegate.isFromListView = true
                    
                    self.dismiss(animated: true, completion: nil)
                }
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
                    self.deselectCell()
                }
                
                alert.addAction(cancelAction)
                alert.addAction(replaceAction)
                
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func add() {
        let alert = UIAlertController(
            title: NSLocalizedString("ADD_TITLE", comment: ""),
            message: NSLocalizedString("ENTER-TITLE", comment: ""),
            preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: NSLocalizedString("ADD", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let isBlank = textField.text!.components(separatedBy: .whitespaces).joined().isEmpty
            
            if !isBlank {
                if self.listNameArray.index(of: textField.text!) == nil {
                    if !textField.text!.contains("@") {
                        self.listNameArray.append(textField.text!)
                        
                        self.saveData.set(self.listNameArray, forKey: "@folders")
                        
                        self.table.reloadData()
                        
                        self.filesDict[textField.text!] = []
                        
                        self.saveData.set(self.filesDict, forKey: "@dictData")
                        
                        if self.listNameArray.count >= self.numberOfCellsInScreen {
                                let movingHeight = self.searchController.searchBar.frame.height + self.table.rowHeight * CGFloat(self.listNameArray.count) - self.view.frame.height
                                
                                let location = CGPoint(x: 0, y: movingHeight)
                                self.table.setContentOffset(location, animated: true)
                            }
                    } else {
                        self.showalert(message: NSLocalizedString("UNUSABLE-ATSIGN", comment: ""))
                        
                        self.deselectCell()
                    }
                } else {
                    self.showalert(message: NSLocalizedString("SAME_FOLDER", comment: ""))
                    
                    self.deselectCell()
                }
            } else {
                self.showalert(message: NSLocalizedString("PLEASE-ENTER", comment: ""))
                
                self.deselectCell()
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextField { (textField: UITextField!) -> Void in
            textField.textAlignment = .left
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchArray.removeAll()
        
        searchArray = listNameArray.filter {
            $0.lowercased(with: .current).contains(searchController.searchBar.text!.lowercased(with: .current))
        }
        
        table.reloadData()
    }
    
    // MARK: - Method
    
    func showalert(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("ERROR", comment: ""),
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deselectCell() {
        if let indexPathForSelectedRow = self.table.indexPathForSelectedRow {
            self.table.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    func resaveDate(pre: String, post: String) {
        let savedMemoText = saveData.object(forKey: pre + "@memo") as! String
        let isShownParts = saveData.object(forKey: pre + "@ison") as! Bool
        let savedDate = saveData.object(forKey: pre + "@date") as! Date?
        let isChecked = saveData.object(forKey: pre + "@check") as! Bool
        
        self.saveData.set(savedMemoText, forKey: post + "@memo")
        self.saveData.removeObject(forKey: pre + "@memo")
        
        self.saveData.set(isShownParts, forKey: post + "@ison")
        self.saveData.removeObject(forKey: pre + "@ison")
        
        if savedDate != nil {
            self.saveData.set(savedDate, forKey: post + "@date")
            self.saveData.removeObject(forKey: pre + "@date")
        }
        
        self.saveData.set(isChecked, forKey: post + "@check")
        self.saveData.removeObject(forKey: pre + "@check")
    }
    
    // MARK: - Else
    
    @IBAction func tapCancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
