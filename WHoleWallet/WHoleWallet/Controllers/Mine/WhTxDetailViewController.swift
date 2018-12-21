//
/*******************************************************************************

        WhTxDetailViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/12/5
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import Alamofire

class WhTxDetailViewController: UITableViewController {

    var txHash: String!
    var txDetail: Dictionary<String,Any>?
    
    var dataSource = Array<Dictionary<String, String>>()
    
    
    init(txHash: String) {
        self.txHash = txHash
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        
        self.tableView.register(WhTransactionDetailCell.self, forCellReuseIdentifier: WhTransactionDetailCell.reuseIdentifier)
        
        guard let hash = txHash else{
            return
        }
        
        let path = "history/detail?tx_hash=\(hash)"
        Alamofire.request(fullAddress(relaAddress: path), method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            DLog(message: response)
            //success handle
            if response.result.isSuccess {
                let value  = response.result.value as! Dictionary<String,Any>
                if let result:Dictionary<String,Any> = resPonsedResult(dictionary: value) {
                    self.txDetail = result
                    self.handleFetchedDetail()
                }
                
            }
            
        }
        
        
    }
    
    
    func handleFetchedDetail() {
        guard let info = self.txDetail else {
            return
        }
        if info.count > 0 {
            for key in info.keys {
                if let strValue = resPonsedString(dictionary: info, key: key) {
                    dataSource.append(["key": key, "value": strValue])
                }
            }
        }
        DLog(message: dataSource)
        self.tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 51
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WhTransactionDetailCell.reuseIdentifier, for: indexPath) as! WhTransactionDetailCell
        var cellInfo = dataSource[indexPath.row]
        cell.configWithTitleAndValue(title: cellInfo["key"], value: cellInfo["value"])
        
        return cell
    }
    

}


class WhTransactionDetailCell: UITableViewCell {
    static let reuseIdentifier = "WhTransactionDetailCell"
    
    weak var titleLabel: UILabel!
    weak var valueLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func configViews() {
        var label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor.theme
        
        contentView.addSubview(label)
        titleLabel = label
        label.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(110)
        }
        
        label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        label.textColor = UIColor(hex: 0x8A94A6)
        label.textAlignment = .right
        label.numberOfLines = 0
        
        contentView.addSubview(label)
        valueLabel = label
        label.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.left.equalTo(titleLabel.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
    }
    
    func configWithTitleAndValue(title: String?, value: String?) {
        titleLabel.text = title
        valueLabel.text = value
    }
    
}
