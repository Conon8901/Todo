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
    @IBOutlet var dateSwitch: UISwitch!
    @IBOutlet var dateField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var dateLabel: UILabel!
    
    var saveData = UserDefaults.standard
    
    let formatter = DateFormatter()
    
    var key = ""
    
    // MARK: - Basics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTextView.delegate = self
        
        memoTextView.text = ""
        memoTextView.layer.borderColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1.0).cgColor
        memoTextView.layer.borderWidth = 0.5
        memoTextView.layer.cornerRadius = 6
        memoTextView.layer.masksToBounds = true
        memoTextView.autocapitalizationType = .none
        
        datePicker.minimumDate = Date()
        datePicker.maximumDate = Date(timeInterval: 60*60*24*10000, since: Date())
        
        showsDateComponents(true)
        
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        placeholder.text = NSLocalizedString("メモ", comment: "")
        
        dateLabel.text = NSLocalizedString("期限", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let folderName = saveData.object(forKey: "@folderName") as! String
        let fileName = saveData.object(forKey: "@fileName") as! String
        key = folderName + "@" + fileName
        
        if saveData.object(forKey: key) == nil {
            memoTextView.text = ""
        } else {
            memoTextView.text = saveData.object(forKey: key) as! String
        }
        
        if saveData.object(forKey: key + "@ison") == nil {
            dateSwitch.isOn = false
        } else {
            dateSwitch.isOn = saveData.object(forKey: key + "@ison") as! Bool
            
            setDate()
        }
        
        chackIsShowPlaceHolder()
        
        navigationItem.title = fileName
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveData.set(memoTextView.text!, forKey: key)
        saveData.set(dateSwitch.isOn, forKey: key + "@ison")
        saveData.set(datePicker.date, forKey: key + "@date")
        
        memoTextView.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextView
    
    func textViewDidChange(_ textView: UITextView) {
        chackIsShowPlaceHolder()
    }
    
    // MARK: DatePicker
    
    @IBAction func changeDate() {
        dateField.text = formatter.string(from: datePicker.date)
    }
    
    // MARK: Switch
    
    @IBAction func switchChanged() {
        if dateSwitch.isOn {
            setDate()
        } else {
            showsDateComponents(true)
        }
    }
    
    // MARK: - Method
    
    func chackIsShowPlaceHolder() {
        if memoTextView.text.isEmpty {
            placeholder.isHidden = false
        } else {
            placeholder.isHidden = true
        }
    }
    
    func showsDateComponents(_ bool: Bool) {
        dateField.isHidden = bool
        datePicker.isHidden = bool
        dateLabel.isHidden = bool
    }
    
    func setDate() {
        if dateSwitch.isOn {
            showsDateComponents(false)
        } else {
            showsDateComponents(true)
        }
        
        if saveData.object(forKey: key + "@date") == nil {
            dateField.text = formatter.string(from: Date())
        } else {
            let savedDate = saveData.object(forKey: key + "@date") as! Date
            
            datePicker.date = savedDate
            
            let span = Date().timeIntervalSince(savedDate)
            
            if span > 60 {
                if span > 3600 {
                    if span > 86400 {
                        if span > 2592000 {
                            if span > 31536000 {
                                dateField.text = String(format: NSLocalizedString("年前", comment: ""), Int(span/31536000))
                            } else {
                                dateField.text = String(format: NSLocalizedString("月前", comment: ""), Int(span/2592000))
                            }
                        } else {
                            dateField.text = String(format: NSLocalizedString("日前", comment: ""), Int(span/86400))
                        }
                    } else {
                        dateField.text = String(format: NSLocalizedString("時間前", comment: ""), Int(span/3600))
                    }
                } else {
                    dateField.text = String(format: NSLocalizedString("分前", comment: ""), Int(span/60))
                }
            } else {
                dateField.text = formatter.string(from: datePicker.date)
            }
        }
    }
    
    // MARK: - Else
    
    @IBAction func tapScreen() {
        self.memoTextView.resignFirstResponder()
    }
}
