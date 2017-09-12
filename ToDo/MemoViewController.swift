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
        
        dateField.isHidden = true
        datePicker.isHidden = true
        label.isHidden = true
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
        
        if saveData.object(forKey: file3+"@ison") != nil{
            dateSwitch.isOn = saveData.object(forKey: file3+"@ison") as! Bool
            
            dateShow()
        }else{
            dateSwitch.isOn = false
        }
        
        placeholderHidden()
        
        navigationItem.title = file2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveData.set(dateSwitch.isOn, forKey: file3+"@ison")
        
        memoTextView.resignFirstResponder()
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
    @IBOutlet var label: UILabel!
    
    @IBAction func changeDate(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        dateField.text = formatter.string(from: sender.date)
        
        saveData.set(memoTextView.text!, forKey: file3)
        saveData.set(dateField.text, forKey: file3+"@")
        saveData.set(datePicker.date, forKey: file3+"@@")
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender.isOn{
            dateShow()
        }else{
            dateField.isHidden = true
            datePicker.isHidden = true
            label.isHidden = true
        }
    }
    
    func dateShow() {
        dateField.isHidden = false
        datePicker.isHidden = false
        label.isHidden = false
        
        datePicker.minimumDate = NSDate() as Date
        
        if saveData.object(forKey: file3+"@") != nil{
            dateField.text = saveData.object(forKey: file3+"@") as! String!
            
            datePicker.date = saveData.object(forKey: file3+"@@") as! Date
            
            if NSDate() as Date >= saveData.object(forKey: file3+"@@") as! Date{
                dateField.text = NSLocalizedString("終了", comment: "")
            }
        }else{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            
            dateField.text = formatter.string(from: NSDate() as Date)
        }
    }
}//削除編集移動時のデータ書き換え
