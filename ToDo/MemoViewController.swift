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
    
    var folderName = ""
    var fileName = ""
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
        
        datePicker.minimumDate = NSDate() as Date
        datePicker.maximumDate = NSDate(timeInterval: 60*60*24*10000, since: NSDate() as Date) as Date
        
        dateField.isHidden = true
        datePicker.isHidden = true
        dateLabel.isHidden = true
        
        placeholder.text = NSLocalizedString("メモ", comment: "")
        
        dateLabel.text = NSLocalizedString("期限", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        folderName = saveData.object(forKey: "@move") as! String
        fileName = saveData.object(forKey: "@memo") as! String
        key = folderName+"@"+fileName
        
        if saveData.object(forKey: key) != nil {
            memoTextView.text = saveData.object(forKey: key) as! String!
        } else {
            memoTextView.text = ""
        }
        
        if saveData.object(forKey: key+"@ison") != nil {
            dateSwitch.isOn = saveData.object(forKey: key+"@ison") as! Bool
            
            dateShow()
        } else {
            dateSwitch.isOn = false
        }
        
        placeholderHidden()
        
        navigationItem.title = fileName
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveData.set(memoTextView.text!, forKey: key)
        saveData.set(dateSwitch.isOn, forKey: key+"@ison")
        saveData.set(dateField.text, forKey: key+"@")
        saveData.set(datePicker.date, forKey: key+"@@")
        
        memoTextView.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextView
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderHidden()
    }
    
    // MARK: DatePicker
    
    @IBAction func changeDate(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        dateField.text = formatter.string(from: sender.date)
    }
    
    // MARK: Switch
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            dateShow()
        } else {
            dateField.isHidden = true
            datePicker.isHidden = true
            dateLabel.isHidden = true
        }
    }
    
    // MARK: - Method
    
    func placeholderHidden() {
        if memoTextView.text.isEmpty {
            placeholder.isHidden = false
        } else {
            placeholder.isHidden = true
        }
    }
    
    func dateShow() {
        if dateSwitch.isOn {
            dateField.isHidden = false
            datePicker.isHidden = false
            dateLabel.isHidden = false
        } else {
            dateField.isHidden = true
            datePicker.isHidden = true
            dateLabel.isHidden = true
        }
        
        datePicker.minimumDate = NSDate() as Date
        
        if saveData.object(forKey: key+"@") != nil, saveData.object(forKey: key+"@@") != nil {
            dateField.text = saveData.object(forKey: key+"@") as! String!
            
            datePicker.date = saveData.object(forKey: key+"@@") as! Date
            
            if NSDate() as Date >= saveData.object(forKey: key+"@@") as! Date {
                dateField.text = NSLocalizedString("終了", comment: "")
            }
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            
            dateField.text = formatter.string(from: NSDate() as Date)
        }
    }
    
    // MARK: - Else
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.memoTextView.resignFirstResponder()
    }
}
