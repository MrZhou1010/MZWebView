//
//  ViewController.swift
//  MZWebView
//
//  Created by Mr.Z on 2019/12/19.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 100, y: 200, width: 100, height: 30)
        btn.setTitle("webView", for: .normal)
        btn.setTitleColor(UIColor.red, for: .normal)
        btn.addTarget(self, action: #selector(btnClick(btn:)), for: .touchUpInside)
        self.view.addSubview(btn)
    }
    
    @objc func btnClick(btn: UIButton) {
        // itms-apps://itunes.apple.com/cn/app/id1456349572?mt=8
        let vc = MZWebViewController(urlString: "http://www.cocoachina.com")
        vc.progressViewFrame = CGRect(x: 0, y: 44, width: self.view.bounds.width, height: 3)
        vc.progressViewTintColor = UIColor.red
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

