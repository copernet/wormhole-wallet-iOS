//
/*******************************************************************************

        WhWebViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/12/17
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import WebKit
import SnapKit

class WhWebViewController: UIViewController {

    var url: URL!
    private var webView: WKWebView!
    
    init(urlString:String) {
        super.init(nibName: nil, bundle: nil)
        url = URL(string: urlString)
        webView = WKWebView(frame: .zero)
        view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        self.webView.load(URLRequest(url: url))
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            self.title = webView.title
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
