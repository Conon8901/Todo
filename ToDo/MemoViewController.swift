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
        
        hidesDateComponents(true)
        
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        placeholder.text = NSLocalizedString("メモ", comment: "")
        
        dateLabel.text = NSLocalizedString("期限", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        folderName = saveData.object(forKey: "@folderName") as! String
        fileName = saveData.object(forKey: "@fileName") as! String
        key = folderName+"@"+fileName
        
        if saveData.object(forKey: key) == nil {
            memoTextView.text = ""
        } else {
            memoTextView.text = saveData.object(forKey: key) as! String
        }
        
        if saveData.object(forKey: key+"@ison") == nil {
            dateSwitch.isOn = false
        } else {
            dateSwitch.isOn = saveData.object(forKey: key+"@ison") as! Bool
            
            setDate()
        }
        
        hidesPlaceHolder()
        
        navigationItem.title = fileName
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveData.set(memoTextView.text!, forKey: key)
        saveData.set(dateSwitch.isOn, forKey: key+"@ison")
        saveData.set(datePicker.date, forKey: key+"@date")
        saveData.removeObject(forKey: key+"@@")
        
        memoTextView.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextView
    
    func textViewDidChange(_ textView: UITextView) {
        hidesPlaceHolder()
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
            hidesDateComponents(true)
        }
    }
    
    // MARK: - Method
    
    func hidesPlaceHolder() {
        if memoTextView.text.isEmpty {
            placeholder.isHidden = false
        } else {
            placeholder.isHidden = true
        }
    }
    
    func setDate() {
        if dateSwitch.isOn {
            hidesDateComponents(false)
        } else {
            hidesDateComponents(true)
        }
        
        datePicker.minimumDate = NSDate() as Date
        
        if saveData.object(forKey: key+"@date") == nil {
            dateField.text = formatter.string(from: NSDate() as Date)
        } else {
            datePicker.date = saveData.object(forKey: key+"@date") as! Date
            
            var difference = ""
            
            let nowyear = Calendar.current.component(.year, from: Date())
            let nowmonth = Calendar.current.component(.month, from: Date())
            let nowday = Calendar.current.component(.day, from: Date())
            let nowhour = Calendar.current.component(.hour, from: Date())
            let nowminute = Calendar.current.component(.minute, from: Date())
            
            let savedyear = Calendar.current.component(.year, from: datePicker.date)
            let savedmonth = Calendar.current.component(.month, from: datePicker.date)
            let savedday = Calendar.current.component(.day, from: datePicker.date)
            let savedhour = Calendar.current.component(.hour, from: datePicker.date)
            let savedminute = Calendar.current.component(.minute, from: datePicker.date)
            
            if nowyear > savedyear {
                if (12*(nowyear-savedyear)+nowmonth)-savedmonth >= 12 {
                    difference = String(format: NSLocalizedString("年前", comment: ""), nowyear-savedyear)
                } else {
                    if (30*(nowmonth-savedmonth)+nowday)-savedday >= 30 {
                        difference = String(format: NSLocalizedString("ヶ月前", comment: ""), nowmonth-savedmonth)
                    } else {
                        if (24*(nowday-savedday)+nowhour)-savedhour >= 24 {
                            difference = String(format: NSLocalizedString("日前", comment: ""), nowday-savedday)
                        } else {
                            if (60*(nowhour-savedhour)+nowminute)-savedminute >= 60 {
                                difference = String(format: NSLocalizedString("時間前", comment: ""), nowhour-savedhour)
                            } else {
                                difference = String(format: NSLocalizedString("分前", comment: ""), nowminute-savedminute)
                            }
                        }
                    }
                }
            } else {
                if nowmonth > savedmonth {
                    if (30*(nowmonth-savedmonth)+nowday)-savedday >= 30 {
                        difference = String(format: NSLocalizedString("ヶ月前", comment: ""), nowmonth-savedmonth)
                    } else {
                        if (24*(nowday-savedday)+nowhour)-savedhour >= 24 {
                            difference = String(format: NSLocalizedString("日前", comment: ""), nowday-savedday)
                        } else {
                            if (60*(nowhour-savedhour)+nowminute)-savedminute >= 60 {
                                difference = String(format: NSLocalizedString("時間前", comment: ""), nowhour-savedhour)
                            } else {
                                difference = String(format: NSLocalizedString("分前", comment: ""), nowminute-savedminute)
                            }
                        }
                    }
                } else {
                    if nowday > savedday {
                        if (24*(nowday-savedday)+nowhour)-savedhour >= 24 {
                            difference = String(format: NSLocalizedString("日前", comment: ""), nowday-savedday)
                        } else {
                            if (60*(nowhour-savedhour)+nowminute)-savedminute >= 60 {
                                difference = String(format: NSLocalizedString("時間前", comment: ""), nowhour-savedhour)
                            } else {
                                difference = String(format: NSLocalizedString("分前", comment: ""), nowminute-savedminute)
                            }
                        }
                    } else {
                        if nowhour > savedhour {
                            if (60*(nowhour-savedhour)+nowminute)-savedminute >= 60 {
                                difference = String(format: NSLocalizedString("時間前", comment: ""), nowhour-savedhour)
                            } else {
                                difference = String(format: NSLocalizedString("分前", comment: ""), nowminute-savedminute)
                            }
                        } else {
                            if nowminute > savedminute {
                                difference = String(format: NSLocalizedString("分前", comment: ""), nowminute-savedminute)
                            }
                        }
                    }
                }
            }
            
            if difference == "" {
                dateField.text = formatter.string(from: datePicker.date)
            } else {
                dateField.text = difference
            }
        }
    }
    
    func hidesDateComponents(_ bool: Bool) {
        dateField.isHidden = bool
        datePicker.isHidden = bool
        dateLabel.isHidden = bool
    }
    
    // MARK: - Else
    
    @IBAction func tapScreen() {
        self.memoTextView.resignFirstResponder()
    }
}
