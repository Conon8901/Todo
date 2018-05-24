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
    @IBOutlet var doneButton: UIBarButtonItem!
    
    var saveData = UserDefaults.standard
    
    var key = ""
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTextView.delegate = self
        
        doneButton.title = "NAV_BUTTON_DONE".localized
        doneButton.hide(true)
        
        placeHolder.text = "LABEL_NOTE".localized
        
        let categoryName = variables.shared.currentCategory
        let taskName = variables.shared.currentTask
        key = categoryName + "@" + taskName
        
        navigationItem.title = taskName
        
        memoTextView.text = saveData.object(forKey: key + "@memo") as! String
        
        checkShowsPlaceHolder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        memoTextView.resignFirstResponder()
        
        variables.shared.isFromNoteView = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextView
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        doneButton.hide(false)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        doneButton.hide(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkShowsPlaceHolder()
        
        saveData.set(memoTextView.text, forKey: key + "@memo")
    }
    
    // MARK: - Methods
    
    func checkShowsPlaceHolder() {
        if memoTextView.text == "" {
            placeHolder.isHidden = false
        } else {
            placeHolder.isHidden = true
        }
    }
    
    @IBAction func tapDone() {
       memoTextView.resignFirstResponder()
    }
    
    // MARK: - Gesture
    
    @IBAction func tapScreen() {
        memoTextView.resignFirstResponder()
    }
}
