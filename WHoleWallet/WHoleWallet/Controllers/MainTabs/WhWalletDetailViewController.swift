//
/*******************************************************************************

        WhWalletDetailViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/11/23
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import Foundation
import UIKit
import MJRefresh
import Alamofire
import BitcoinKit

enum WalletType:Int {
    case bch = 0
    case whc = 1
    case other = 2
}

enum AddressRole:String {
    case sender = "sender"
    case recipient = "recipient"
}

enum WhPullDirection {
    case up
    case down
    case none
}

class  WhWalletDetailViewController: UIViewController, UITableViewDataSource,UITableViewDelegate{

    var walletType:WalletType!
    let footer = MJRefreshAutoNormalFooter()
    
    var propertyID : Int! // 0 bch, 1 whc
    var amountString: String!
    var tokenName: String?
    
    //for bch
    var payMents = [Payment]()
    var displayNum = 0
    
    //for normal token
    var tokenInfo: Dictionary<String,Any>?
    
    var dataSource = [Dictionary<String,Any>]()
    var pageNo = 0
    var pageSize: Int {
        return 20
    }
    
    var total = 0
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var receiveAction: UIButton!
    
    @IBOutlet weak var sendAction: UIButton!
    
    
    @IBOutlet var header: UIView!
    
    override func viewDidLoad() {
        //add headerview
        configViews()
        
        //fetchData
        fetch(direction: .none)
    }
    
    func configViews()  {
        self.tableView.delegate   = self
        self.tableView.dataSource = self
        self.tableView.tableHeaderView = header
        if #available(iOS 11, *) {
            self.tableView.estimatedRowHeight = 0;
            self.tableView.estimatedSectionFooterHeight = 0;
            self.tableView.estimatedSectionHeaderHeight = 0;
        }
        tableView.register(WhTransHistoryCell.self, forCellReuseIdentifier: WhTransHistoryCell.cellIdentifier)
        
        //refresh control top and bottom
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.addTarget(self, action: #selector(headerRefresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
        
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        self.tableView.mj_footer = footer
        
        //avoid empty row
        self.tableView.tableFooterView = UIView()
        
        //round button
        self.sendAction.layer.cornerRadius = 22
        self.receiveAction.layer.cornerRadius = 22
        
        
        //set data
        self.nameLabel.text   = self.tokenName
        self.amountLabel.text = self.amountString
        
        //title
        self.title = self.nameLabel.text
    }
    
    @objc func headerRefresh() {
        pageNo = 0
        fetch(direction: .down)
    }
    
    @objc func footerRefresh() {
        pageNo += 1
        fetch(direction: .up)
    }
    
    
    func updateViewWithData() {
        //have load all data
        if self.dataSource.count >= total {
            footer.endRefreshingWithNoMoreData()
        }
        tableView.reloadData()
    }

    
    //fetch data
    func fetch(direction: WhPullDirection) {
        guard WhWalletManager.shared.whWallet != nil else {
            return
        }
        //, "pageSize":pageSize, "pageNo": pageNo]
        let parameters = ["address": WhWalletManager.shared.whWallet!.cashAddr, "property_id": propertyID] as [String : Any]
        let subAddress = "history/list?pageSize=\(pageSize)&pageNo=\(pageNo)"
        var path: String!
        if propertyID == 0 {
            path = "https://dev.wormhole.cash/" + subAddress
        }else {
            path = fullAddress(relaAddress: subAddress)
        }
        Alamofire.request(path, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            DLog(message: response)
            //success handle
            if response.result.isSuccess {
                let value  = response.result.value as! Dictionary<String,Any>
                if let result:Dictionary<String,Any> = resPonsedResult(dictionary: value) {
                    if let total: Int = resPonsedInt(dictionary: result, key: "total"){
                        self.total = total
                        if total > 0 {
                            if let source = resPonsedDicArray(dictionary: result, key: "list") {
                                
                                if direction != .up {
                                    self.dataSource = source
                                    
                                }else {
                                    self.dataSource.append(contentsOf: source)
                                }
                                
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
        //end refresh
        DispatchQueue.main.async {
            if self.tableView.refreshControl!.isRefreshing {
                self.tableView.refreshControl!.endRefreshing()
            }
            self.updateViewWithData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.dataSource.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WhTransHistoryCell.cellIdentifier) as! WhTransHistoryCell
        cell.setWithDictionary(dictionary: self.dataSource[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detail = storyboard.instantiateViewController(withIdentifier: "WhTxDetailViewController") as! WhTxDetailViewController
        detail.txHash = resPonsedString(dictionary: dataSource[indexPath.row], key: "tx_hash")
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    
    @IBAction func receiveAction(_ sender: Any) {
        
    }
    
    
    @IBAction func sendAction(_ sender: Any) {
        self.performSegue(withIdentifier: "WhSendViewController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination
        if dest is WhSendViewController {
            let sendVC = dest as! WhSendViewController
            sendVC.propertyID = self.propertyID
        }
        
        if dest is WhTxDetailViewController {
            let sendVC = dest as! WhTxDetailViewController
            let txdetail = sender as! Dictionary<String,Any>
            sendVC.txHash = resPonsedString(dictionary: txdetail, key: "tx_hash")
        }
    }
    
}


class WhTransHistoryCell: UITableViewCell {
    static let cellIdentifier = "DetailCell"
    
    var addressLabel: UILabel!
    
    var amountLabel: UILabel!
    
    var dateLabel: UILabel!
    
    var useLabel: UILabel!
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configViews()
    }
    
    func setWithDictionary(dictionary: Dictionary<String,Any>) {
        //address
        self.addressLabel.text = resPonsedString(dictionary: dictionary, key: "tx_hash")
        
        //amount
        let amount = resPonsedString(dictionary: dictionary, key: "balance_available_credit_debit")
        let name = resPonsedString(dictionary: dictionary, key: "property_name")
        if let cellAmount = amount {
            if cellAmount.hasPrefix("-") {
                self.amountLabel.text = "\(cellAmount) \(name ?? "")"
                self.amountLabel.textColor = UIColor(hex: 0xF03D3D)
            } else{
                self.amountLabel.text = "+\(cellAmount) \(name ?? "")"
                self.amountLabel.textColor = UIColor(hex: 0x22C993)
            }
        }
        
        //date
        let timeInterval = resPonsedInt64(dictionary: dictionary, key: "created")
        let date = Date(timeIntervalSince1970: Double(timeInterval!))
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy MM dd HH:mm:ss"
        self.dateLabel.text = dateformatter.string(from: date)
        
        //sure
        if let valid = resPonsedString(dictionary: dictionary, key: "tx_state"){
            self.useLabel.text = valid
        }
        self.useLabel.text = " "
        
    }
    
    
    func setWithPayMent(payMent: Payment) {
        //address
        self.addressLabel.text = payMent.txid.reversed().toHexString()
        
        //amount
        let amount = Decimal(payMent.amount) / Decimal(100_000_000)
        
        if payMent.state == .sent{
            self.amountLabel.text = "-\(amount) BCH"
            self.amountLabel.textColor = UIColor(hex: 0xF03D3D)
        } else{
            self.amountLabel.text = "+\(amount) BCH"
            self.amountLabel.textColor = UIColor(hex: 0x22C993)
        }
        
        self.dateLabel.text = " "
//        //date
//        let timeInterval = resPonsedInt64(dictionary: dictionary, key: "created")
//        let date = Date(timeIntervalSince1970: Double(timeInterval!))
//        let dateformatter = DateFormatter()
//        dateformatter.dateFormat = "yyyy MM dd HH:mm:ss"
//        self.dateLabel.text = dateformatter.string(from: date)
//
//        //sure
//        if let valid = resPonsedString(dictionary: dictionary, key: "valid"){
//            if valid.compare("valid") == .orderedSame {
//                self.useLabel.text = "已确认"
//                return
//            }
//        }
        
        self.useLabel.text = "不可用"
    }
    
    func configViews() {
        
        var label = UILabel()
        label.textColor = UIColor(hex: 0x53627C)
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(10)
        }
        self.addressLabel = label
        
        label = UILabel()
        label.textColor = UIColor(hex: 0x22C993)
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.top.equalTo(10)
            make.width.equalTo(addressLabel.snp.width)
            make.left.equalTo(addressLabel.snp.right).offset(15)
        }
        self.amountLabel = label
        
        label = UILabel()
        label.textColor = UIColor(hex: 0xC9CED6)
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(addressLabel.snp.bottom).offset(3)
        }
        self.dateLabel = label
        
        label = UILabel()
        label.textColor = UIColor(hex: 0xC9CED6)
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.top.equalTo(dateLabel.snp.top)
            make.width.equalTo(dateLabel.snp.width)
        }
        self.useLabel = label
    }
    
}
