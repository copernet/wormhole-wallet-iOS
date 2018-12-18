//
/*******************************************************************************

        WhPopContentViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/11/29
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import SnapKit

public protocol WhPopContentSelectProtocol {
    func didSlectedRowData(row: Int, data: String, pop: UIViewController) -> Void
}

class WhPopContentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    public var selectedDelegate: WhPopContentSelectProtocol?
    private var tableView: UITableView!
    var source: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        tableView.reloadData()
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "popcell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "popcell")
        }
        
        cell?.textLabel?.text = source[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = source[indexPath.row]
        if let sDelegate = selectedDelegate {
            sDelegate.didSlectedRowData(row: indexPath.row, data: result, pop: self)
        }
        dismiss(animated: true, completion: nil)
    }
    
}
