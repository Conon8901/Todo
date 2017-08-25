//
//  MemoViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/08/24.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class MemoViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var navTitle: UINavigationBar!
    @IBOutlet var memoTextView: UITextView!
    @IBOutlet var placeholder: UILabel!
    
    var saveData: UserDefaults = UserDefaults.standard
    
    var memoArray = [String: String]()
    
    var file1 = ""
    var file2 = ""
    var file3 = ""

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
        
        if memoTextView.text.isEmpty{
            placeholder.isHidden = false
        }else{
            placeholder.isHidden = true
        }
        
        navTitle.topItem?.title = file2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func backFolder() {
        memoArray[file3] = memoTextView.text!
        saveData.set(memoArray[file3], forKey: file3)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func panLeft(_ sender: UIScreenEdgePanGestureRecognizer) {
        backFolder()
    }
    
    @IBAction func back() {
        backFolder()
    }
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        self.memoTextView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if memoTextView.text.isEmpty{
            placeholder.isHidden = false
        }else{
            placeholder.isHidden = true
        }
    }
}
