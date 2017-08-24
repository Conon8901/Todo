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

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if saveData.object(forKey: "text") != nil{
//            memoArray = saveData.object(forKey: "text") as! [String : String]
//        }else{
//            self.saveData.set(memoArray, forKey: "text")
//        }
        
        memoTextView.delegate = self
        
        memoTextView.text = ""
        memoTextView.layer.borderColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1.0).cgColor
        memoTextView.layer.borderWidth = 0.5
        memoTextView.layer.cornerRadius = 6
        memoTextView.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //memoArrayからmemoTextViewに引っ張ってくる
        
        navTitle.topItem?.title = saveData.object(forKey: "memo") as! String?
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func backFolder() {
        //memoArrayにmemoTextView.textを追加または上書き
        //saveData.setValue(memoArray, forKeyPath: "memo")
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
