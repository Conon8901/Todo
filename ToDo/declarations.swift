//
//  declarations.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/10/31.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

extension UITableView {
    func scroll(x: CGFloat = 0, y: CGFloat) {
        let offset = CGPoint(x: Int(x), y: Int(y))
        setContentOffset(offset, animated: true)
    }
}
