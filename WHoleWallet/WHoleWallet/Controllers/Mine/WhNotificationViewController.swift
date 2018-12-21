//
/*******************************************************************************

        WhNotificationViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/12/5
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import XLPagerTabStrip
import Alamofire
import MJRefresh

class WhNotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView:UITableView = UITableView(frame: CGRect.zero, style: .plain)

    @IBOutlet weak var emptyView: UIView!
    
    var dataSource = [Dictionary<String,Any>]()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableview
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        if #available(iOS 11, *) {
            self.tableView.estimatedRowHeight = 0;
            self.tableView.estimatedSectionFooterHeight = 0;
            self.tableView.estimatedSectionHeaderHeight = 0;
        }
        tableView.register(WhNotificationMessageCell.self, forCellReuseIdentifier: WhNotificationMessageCell.reuseIdentifier)
        
        //avoid empty row
        self.tableView.tableFooterView = UIView()
        
        fetch(direction: .none)
    }
    
    func updateViewWithData() {
        //have load all data
        if dataSource.count == 0 {
            if self.emptyView.isHidden{
                self.emptyView.isHidden = false
                self.view.bringSubviewToFront(self.emptyView)
            }
        }else {
            self.emptyView.isHidden = true
            self.view.bringSubviewToFront(self.tableView)
        }
        
        tableView.reloadData()
        
    }
    
    //fetch data
    func fetch(direction: WhPullDirection) {
        guard let wallet = WhWalletManager.shared.whWallet else {
            return
        }
        let parameters = ["address": wallet.cashAddr, "from": "1", "to": Int(NSTimeIntervalSince1970)] as [String : Any]
        let path = "notify"
        Alamofire.request(fullAddress(relaAddress: path), method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            DLog(message: response)
            //success handle
            if response.result.isSuccess {
                let value  = response.result.value as! Dictionary<String,Any>
                if let result:Dictionary<String,Any> = resPonsedResult(dictionary: value) {
                    DLog(message: result)
                    if let total: Int = resPonsedInt(dictionary: result, key: "total"){
                     
                        if total > 0 {
                            
                            if let source = resPonsedDicArray(dictionary: result, key: "list") {
                                self.dataSource = source
                                //end refresh
                                DispatchQueue.main.async {
                                    if self.tableView.refreshControl!.isRefreshing {
                                        self.tableView.refreshControl!.endRefreshing()
                                    }
                                    self.updateViewWithData()
                                }
                                return
                                
                            }
                        }
                    }
                }
                
            }
            
            //default handle
            self.update()
            
        }
    }
    
    
    func update() {
        self.dataSource = [Dictionary<String,Any>]()
        updateViewWithData()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message =  dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: WhNotificationMessageCell.reuseIdentifier, for: indexPath) as! WhNotificationMessageCell
        cell.setWithMessage(message: message)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

}



class WhNotificationMessageCell: UITableViewCell {
    static let reuseIdentifier = "WhNotificationMessageCell"
    
    var iconView: UIImageView!
    var addressLabel: UILabel!
    var assetTypeLabel: UILabel!
    var timeLabel: UILabel!
    var amountLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configSubViews() {
        let iconView = UIImageView(frame: .zero)
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.left.top.equalTo(10)
            make.width.height.equalTo(30)
        }
        self.iconView = iconView
        
        var label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: 0xA6AEBC)
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(iconView.snp.top)
            make.left.equalTo(iconView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        self.addressLabel = label
        
        label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: 0x53627C)
        label.font = UIFont.systemFont(ofSize: 9, weight: .medium)
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(addressLabel.snp.bottom).offset(2)
            make.left.equalTo(addressLabel.snp.left)
        }
        self.assetTypeLabel = label
        
        label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: 0xC9CED6)
        label.font = UIFont.systemFont(ofSize: 9, weight: .regular)
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(assetTypeLabel.snp.bottom).offset(15)
            make.left.equalTo(assetTypeLabel.snp.left)
            make.bottom.equalTo(10)
        }
        self.timeLabel = label
        
        
        label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: 0x53627C)
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.right.equalTo(addressLabel.snp.right)
            make.bottom.equalTo(timeLabel.snp.bottom)
        }
        self.amountLabel = label
        
    }
    
    
    func setWithMessage(message: Dictionary<String, Any>) {
        if let amount = resPonsedDouble(dictionary: message, key: "balance_available_credit_debit") {
            amountLabel.text = "\(amount) Token"
            if amount > 0 {
                iconView.image = UIImage(named: "my_icon_input")
            }else {
                iconView.image = UIImage(named: "my_icon_output")
            }
        }
        
        addressLabel.text = resPonsedString(dictionary: message, key: "address")
        timeLabel.text = resPonsedString(dictionary: message, key: "timestamp")
        if let role = resPonsedString(dictionary: message, key: "address_role") {
            assetTypeLabel.text = "[\(role)]"
        }
        
    }
}
