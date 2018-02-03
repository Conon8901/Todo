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
    @IBOutlet var placeHolder: UILabel!
    @IBOutlet var dateSwitch: UISwitch!
    @IBOutlet var dateField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var dateLabel: UILabel!
    
    var saveData = UserDefaults.standard
    
    var key = ""
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTextView.delegate = self
        memoTextView.setUp()
        
        datePicker.minimumDate = Date()
        datePicker.maximumDate = Date(timeInterval: 60*60*24*2000, since: Date())
        
        placeHolder.text = NSLocalizedString("LABEL_NOTE", comment: "")
        dateLabel.text = NSLocalizedString("LABEL_DUE", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let folderName = saveData.object(forKey: "@folderName") as! String
        let fileName = saveData.object(forKey: "@fileName") as! String
        key = folderName + "@" + fileName
        
        memoTextView.text = saveData.object(forKey: key + "@memo") as! String
        
        dateSwitch.isOn = saveData.object(forKey: key + "@ison") as! Bool
        
        checkShowsPlaceHolder()
        
        if dateSwitch.isOn {
            showsDateParts(true)
        } else {
            showsDateParts(false)
        }
        
        setDatePicker()
        
        setDateText()
        
        navigationItem.title = fileName
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        memoTextView.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextView
    
    func textViewDidChange(_ textView: UITextView) {
        checkShowsPlaceHolder()
        
        saveData.set(memoTextView.text!, forKey: key + "@memo")
    }
    
    // MARK: DatePicker
    
    @IBAction func changeDate() {
        setDateText(span: Date().timeIntervalSince(datePicker.date))
        
        saveData.set(datePicker.date, forKey: key + "@date")
    }

    // MARK: Switch
    
    @IBAction func switchChanged() {
        if dateSwitch.isOn {
            showsDateParts(true)
            
            setDatePicker()
        } else {
            showsDateParts(false)
        }
        
        saveData.set(dateSwitch.isOn, forKey: key + "@ison")
    }
    
    // MARK: - Methods
    
    func setDateText() {
        setDateText(span: Date().timeIntervalSince(datePicker.date))
        
        saveData.set(datePicker.date, forKey: key + "@date")
    }
    
    func showsDateParts(_ bool: Bool) {
        dateField.isHidden = !bool
        datePicker.isHidden = !bool
    }
    
    func checkShowsPlaceHolder() {
        if memoTextView.text == "" {
            placeHolder.isHidden = false
        } else {
            placeHolder.isHidden = true
        }
    }
    
    func setDatePicker() {
        if saveData.object(forKey: key + "@date") == nil {
            datePicker.date = Date()
            
            dateField.text = ""
        } else {
            let savedDate = saveData.object(forKey: key + "@date") as! Date
            
            let span = Date().timeIntervalSince(savedDate)
            
            setDateText(span: span)
            
            if span > 60 {
                datePicker.minimumDate = savedDate
            }
            
            datePicker.date = savedDate
        }
    }
    
    func setDateText(span: TimeInterval) {
        if span > 0 {
            if span > 60 {
                if span > 60*60 {
                    if span > 60*60*24 {
                        if span > 60*60*24*30 {
                            if span > 60*60*24*365 {
                                dateField.text = String(format: NSLocalizedString("TEXT_DUE_PAST_YEAR", comment: ""), Int(span/31536000))
                            } else {
                                dateField.text = String(format: NSLocalizedString("TEXT_DUE_PAST_MONTH", comment: ""), Int(span/2592000))
                            }
                        } else {
                            dateField.text = String(format: NSLocalizedString("TEXT_DUE_PAST_DAY", comment: ""), Int(span/86400))
                        }
                    } else {
                        dateField.text = String(format: NSLocalizedString("TEXT_DUE_PAST_HOUR", comment: ""), Int(span/3600))
                    }
                } else {
                    dateField.text = String(format: NSLocalizedString("TEXT_DUE_PAST_MINUTE", comment: ""), Int(span/60))
                }
            } else {
                dateField.text = NSLocalizedString("TEXT_DUE_PRESENT", comment: "")
            }
        } else if span < 0 {
            if span < -60 {
                if span < -60*60 {
                    if span < -60*60*24 {
                        if span < -60*60*24*30 {
                            if span < -60*60*24*365 {
                                dateField.text = String(format: NSLocalizedString("TEXT_DUE_FUTURE_YEAR", comment: ""), Int(-span/31536000))
                            } else {
                                dateField.text = String(format: NSLocalizedString("TEXT_DUE_FUTURE_MONTH", comment: ""), Int(-span/2592000))
                            }
                        } else {
                            dateField.text = String(format: NSLocalizedString("TEXT_DUE_FUTURE_DAY", comment: ""), Int(-span/86400))
                        }
                    } else {
                        dateField.text = String(format: NSLocalizedString("TEXT_DUE_FUTURE_HOUR", comment: ""), Int(-span/3600))
                    }
                } else {
                    dateField.text = String(format: NSLocalizedString("TEXT_DUE_FUTURE_MINUTE", comment: ""), Int(-span/60))
                }
            } else {
                dateField.text = NSLocalizedString("TEXT_DUE_PRESENT", comment: "")
            }
        } else {
            dateField.text = NSLocalizedString("TEXT_DUE_PRESENT", comment: "")
        }
    }
    
    // MARK: - Others
    
    @IBAction func tapScreen() {
        memoTextView.resignFirstResponder()
    }
}
