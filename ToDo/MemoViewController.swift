//
//  MemoViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/08/24.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class MemoViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Declare
    
    @IBOutlet var memoTextView: UITextView!
    @IBOutlet var placeholder: UILabel!
    @IBOutlet var fileName: UITextField!
    
    var saveData = UserDefaults.standard
    
    var file1 = ""
    var file2 = ""
    var file3 = ""
    
    // MARK: - Basics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTextView.delegate = self
        
        memoTextView.text = ""
        memoTextView.layer.borderColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1.0).cgColor
        memoTextView.layer.borderWidth = 0.5
        memoTextView.layer.cornerRadius = 6
        memoTextView.layer.masksToBounds = true
        
        memoTextView.becomeFirstResponder()
        
        datePicker.minimumDate = NSDate() as Date
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        file1 = saveData.object(forKey: "@move") as! String
        file2 = saveData.object(forKey: "@memo") as! String
        file3 = file1+file2
        
        if saveData.object(forKey: file3) != nil{
            memoTextView.text = saveData.object(forKey: file3) as! String!
        }else{
            memoTextView.text = ""
        }
        
        if saveData.object(forKey: file3+"@") != nil{
            dateField.text = saveData.object(forKey: file3+"@") as! String!
            
            let dateString = dateField.text
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            
            datePicker.date = dateFormatter.date(from: dateString!)!
        }else{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            
            dateField.text = formatter.string(from: NSDate() as Date)
        }
        
        placeholderHidden()
        
        //navigationItem.title = file2
        fileName.text = file2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        memoTextView.resignFirstResponder()
        
        if fileName.text != ""{
            var dict = saveData.object(forKey: "@ToDoList") as! [String : Array<String>]
            
            var bool = true
            
            for data in dict[file1]!{
                if data == fileName.text!{
                    bool = false
                }
            }
            
            if bool{
                dict[file1]?[(dict[file1]?.index(of: file2))!] = fileName.text!
                saveData.set(dict, forKey: "@ToDoList")
                
                saveData.set("", forKey: file3)
                saveData.set(memoTextView.text!, forKey: file1+fileName.text!)
                
                saveData.set("", forKey: file3+"@")
                saveData.set(dateField.text, forKey: file1+fileName.text!+"@")
            }else{
                saveData.set(memoTextView.text!, forKey: file3)
                saveData.set(dateField.text, forKey: file3+"@")
            }
        }else{
            saveData.set(memoTextView.text!, forKey: file3)
            saveData.set(dateField.text, forKey: file3+"@")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextView
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderHidden()
    }
    
    // MARK: - Method
    
    func placeholderHidden() {
        if memoTextView.text.isEmpty{
            placeholder.isHidden = false
        }else{
            placeholder.isHidden = true
        }
    }
    
    // MARK: - Else
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.memoTextView.resignFirstResponder()
    }
    
    @IBOutlet var dateField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBAction func changeDate(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        dateField.text = formatter.string(from: sender.date)
    }
    
    
}
