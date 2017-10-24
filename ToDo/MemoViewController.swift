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
        datePicker.maximumDate = Date(timeInterval: 60*60*24*2000, since: Date())
        
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        placeholder.text = NSLocalizedString("NOTE", comment: "")
        
        dateLabel.text = NSLocalizedString("LIMIT", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let folderName = saveData.object(forKey: "@folderName") as! String
        let fileName = saveData.object(forKey: "@fileName") as! String
        key = folderName + "@" + fileName
        
        memoTextView.text = saveData.object(forKey: key + "@memo") as! String
        
        dateSwitch.isOn = saveData.object(forKey: key + "@ison") as! Bool
        
        if dateSwitch.isOn {
            showsDateParts(true)
        } else {
            showsDateParts(false)
        }
        
        setDate()
        
        chackShowPlaceHolder()
        
        navigationItem.title = fileName
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveData.set(memoTextView.text!, forKey: key + "@memo")
        saveData.set(dateSwitch.isOn, forKey: key + "@ison")
        saveData.set(datePicker.date, forKey: key + "@date")
        
        memoTextView.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextView
    
    func textViewDidChange(_ textView: UITextView) {
        chackShowPlaceHolder()
    }
    
    // MARK: DatePicker
    
    @IBAction func changeDate() {
        if datePicker.date < Date() {
            setText(span: Date().timeIntervalSince(datePicker.date))
        } else {
            dateField.text = formatter.string(from: datePicker.date)
        }
    }
    
    // MARK: Switch
    
    @IBAction func switchChanged() {
        if dateSwitch.isOn {
            showsDateParts(true)
            
            setDate()
        } else {
            showsDateParts(false)
        }
    }
    
    // MARK: - Method
    
    func chackShowPlaceHolder() {
        if memoTextView.text.isEmpty {
            placeholder.isHidden = false
        } else {
            placeholder.isHidden = true
        }
    }
    
    func showsDateParts(_ bool: Bool) {
        dateField.isHidden = !bool
        datePicker.isHidden = !bool
        dateLabel.isHidden = !bool
    }
    
    func setDate() {
        if saveData.object(forKey: key + "@date") == nil {
            datePicker.date = Date()
            
            dateField.text = formatter.string(from: Date())
        } else {
            let savedDate = saveData.object(forKey: key + "@date") as! Date
            
            datePicker.date = savedDate
            
            let span = Date().timeIntervalSince(savedDate)
            
            setText(span: span)
            
            if span > 60 {
                datePicker.minimumDate = savedDate
                datePicker.date = savedDate
            }
        }
    }
    
    // MARK: - Else
    
    func setText(span: TimeInterval) {
        if span > 60 {
            if span > 3600 {
                if span > 86400 {
                    if span > 2592000 {
                        if span > 31536000 {
                            dateField.text = String(format: NSLocalizedString("AGO_YEAR", comment: ""), Int(span/31536000))
                        } else {
                            dateField.text = String(format: NSLocalizedString("AGO_MONTH", comment: ""), Int(span/2592000))
                        }
                    } else {
                        dateField.text = String(format: NSLocalizedString("AGO_DAY", comment: ""), Int(span/86400))
                    }
                } else {
                    dateField.text = String(format: NSLocalizedString("AGO_HOUR", comment: ""), Int(span/3600))
                }
            } else {
                dateField.text = String(format: NSLocalizedString("AGO_MINUTE", comment: ""), Int(span/60))
            }
        } else {
            dateField.text = formatter.string(from: datePicker.date)
        }
    }
    
    @IBAction func tapScreen() {
        self.memoTextView.resignFirstResponder()
    }
}
