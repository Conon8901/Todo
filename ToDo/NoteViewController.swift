//
//  MemoViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/08/24.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Declare
    
    @IBOutlet var memoTextView: UITextView!
    @IBOutlet var placeHolder: UILabel!
    @IBOutlet var dateSwitch: UISwitch!
    @IBOutlet var dateField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var dateLabel: UILabel!
    var doneButton: UIBarButtonItem?
    
    var saveData = UserDefaults.standard
    
    var key = ""
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTextView.delegate = self
        
        datePicker.maximumDate = Date(timeInterval: 60*60*24*2000, since: Date())
        
        placeHolder.text = "LABEL_NOTE".localized
        dateLabel.text = "LABEL_DUE".localized
        
        let categoryName = saveData.object(forKey: "folderName") as! String
        let taskName = saveData.object(forKey: "fileName") as! String
        key = categoryName + "@" + taskName
        
        navigationItem.title = taskName
        
        memoTextView.text = saveData.object(forKey: key + "@memo") as! String
        
        tryShowsPlaceHolder()
        
        let isSwitchOn = saveData.object(forKey: key + "@ison") as! Bool
        
        dateSwitch.isOn = isSwitchOn
        
        showsDateParts(isSwitchOn)
        
        doneButton = UIBarButtonItem(title: "NAV_BUTTON_DONE".localized, style: .done, target: self, action: #selector(NoteViewController.saveMemo))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //カレンダー形式にするならここで
        if dateSwitch.isOn {
            setDatePicker()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        memoTextView.resignFirstResponder()
        
        variables.shared.isFromNoteViewController = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextView
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        navigationItem.rightBarButtonItem = nil
    }
    
    func textViewDidChange(_ textView: UITextView) {
        tryShowsPlaceHolder()
        
        saveData.set(memoTextView.text!, forKey: key + "@memo")
    }
    
    // MARK: DatePicker
    
    @IBAction func changeDate() {
        setDateText(span: Date().timeIntervalSince(datePicker.date))
        
        saveData.set(datePicker.date, forKey: key + "@date")
    }

    // MARK: Switch
    
    @IBAction func switchChanged() {
        memoTextView.resignFirstResponder()
        
        if dateSwitch.isOn {
            showsDateParts(true)
            
            datePicker.maximumDate = Date(timeInterval: 60*60*24*2000, since: Date())
            
            if saveData.object(forKey: key + "@date") == nil {
                datePicker.date = Date()
                
                dateField.text = "TEXT_DUE_PRESENT".localized
            } else {
                setDatePicker()
            }
        } else {
            showsDateParts(false)
            
            saveData.set(datePicker.date, forKey: key + "@date")
        }
        
        saveData.set(dateSwitch.isOn, forKey: key + "@ison")
        saveData.set(datePicker.date, forKey: key + "@date")
    }
    
    // MARK: - Methods
    
    func showsDateParts(_ showing: Bool) {
        dateField.isHidden = !showing
        datePicker.isHidden = !showing
    }
    
    func tryShowsPlaceHolder() {
        if memoTextView.text == "" {
            placeHolder.isHidden = false
        } else {
            placeHolder.isHidden = true
        }
    }
    
    func setDatePicker() {
        let savedDate = saveData.object(forKey: key + "@date") as! Date
        let span = Date().timeIntervalSince(savedDate)
        
        setDateText(span: span)
        
        if span > 0 {
            datePicker.minimumDate = savedDate
        } else {
            datePicker.minimumDate = Date()
        }
        
        datePicker.date = savedDate
    }
    
    func setDateText(span: TimeInterval) {
        if span > 0 {
            if span > 60 {
                if span > 60*60 {
                    if span > 60*60*24 {
                        if span > 60*60*24*30 {
                            dateField.text = String(format: "TEXT_DUE_PAST_MONTH".localized, Int(span/2592000))
                        } else {
                            dateField.text = String(format: "TEXT_DUE_PAST_DAY".localized, Int(span/86400))
                        }
                    } else {
                        dateField.text = String(format: "TEXT_DUE_PAST_HOUR".localized, Int(span/3600))
                    }
                } else {
                    dateField.text = String(format: "TEXT_DUE_PAST_MINUTE".localized, Int(span/60))
                }
            } else {
                dateField.text = "TEXT_DUE_PRESENT".localized
            }
        } else if span < 0 {
            if span < -60 {
                if span < -60*60 {
                    if span < -60*60*24 {
                        if span < -60*60*24*30 {
                            dateField.text = String(format: "TEXT_DUE_FUTURE_MONTH".localized, Int(-span/2592000))
                        } else {
                            dateField.text = String(format: "TEXT_DUE_FUTURE_DAY".localized, Int(-span/86400))
                        }
                    } else {
                        dateField.text = String(format: "TEXT_DUE_FUTURE_HOUR".localized, Int(-span/3600))
                    }
                } else {
                    dateField.text = String(format: "TEXT_DUE_FUTURE_MINUTE".localized, Int(-span/60))
                }
            } else {
                dateField.text = "TEXT_DUE_PRESENT".localized
            }
        } else {
            dateField.text = "TEXT_DUE_PRESENT".localized
        }
    }
    
    @objc func saveMemo() {
        saveData.set(memoTextView.text!, forKey: key + "@memo")
        
        memoTextView.resignFirstResponder()
    }
    
    // MARK: - Others
    
    @IBAction func tapScreen() {
        memoTextView.resignFirstResponder()
    }
}
