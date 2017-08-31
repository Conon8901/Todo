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
    
    @IBOutlet var navTitle: UINavigationBar!
    @IBOutlet var memoTextView: UITextView!
    @IBOutlet var placeholder: UILabel!
    
    var saveData = UserDefaults.standard
    
    var memoArray = [String:String]()
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        file1 = saveData.object(forKey: "foldername") as! String
        file2 = saveData.object(forKey: "memo") as! String
        file3 = file1+file2
        
        if saveData.object(forKey: file3) != nil{
            memoTextView.text = saveData.object(forKey: file3) as! String!
        }else{
            memoTextView.text = ""
        }
        
        placeholder.isHidden = memoTextView.text.isEmpty ? false : true
        
        navTitle.topItem?.title = file2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TextView
    
    func textViewDidChange(_ textView: UITextView) {
        placeholder.isHidden = memoTextView.text.isEmpty ? false : true
    }
    
    // MARK: - Method
    
    func backFolder() {
        memoArray[file3] = memoTextView.text!
        saveData.set(memoArray[file3], forKey: file3)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Else
    
//    @IBAction func panLeft(_ sender: UIScreenEdgePanGestureRecognizer) {
//        print("backWithGesture")
//        backFolder()
//    }
//    
//    @IBAction func back() {
//        print("backWithButton")
//        backFolder()
//    }
    
    //Delete this after solve the problem which it isn't using 'back' method
    override func viewWillDisappear(_ animated: Bool) {
        memoArray[file3] = memoTextView.text!
        saveData.set(memoArray[file3], forKey: file3)
    }
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.memoTextView.resignFirstResponder()
    }
}
