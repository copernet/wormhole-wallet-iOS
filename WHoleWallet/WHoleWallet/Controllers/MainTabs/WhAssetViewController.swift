//
/*******************************************************************************

        WhAssetViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/11/19
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import Foundation
import SnapKit
import MJRefresh
import Alamofire


class WhAssetViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var addButton: UIButton!
    let footer = MJRefreshAutoNormalFooter()
    var propertyID : Int! // 0 bch, 1 whc
    
    var displayNum = 0
    
    var dataSource = [Dictionary<String,Any>]()
    var pageNo = 0
    var pageSize: Int {
        return 20
    }
    var total = 0
    
    deinit {
        fetch(direction: .none)
    }
    
    
    @objc func walletChanged(notification: Notification) {
        fetch(direction: .none)
    }
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(walletChanged(notification:)), name: Notification.Name.AppController.walletChanged, object: nil)
        configView()
        
        //fetchData
        fetch(direction: .none)
    }
    
    func configView() {
        
        if #available(iOS 11, *) {
            self.tableView.estimatedRowHeight = 0;
            self.tableView.estimatedSectionFooterHeight = 0;
            self.tableView.estimatedSectionHeaderHeight = 0;
        }
        
        //refresh control top and bottom
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.addTarget(self, action: #selector(headerRefresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
        
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        self.tableView.mj_footer = footer
        
        //avoid empty row
        self.tableView.tableFooterView = UIView()
    
        
        
        tableView.register(WhAssetCell.self, forCellReuseIdentifier: WhAssetCell.reuseIdentifier)
        tableView.register(WhAssetCrowdSaleCell.self, forCellReuseIdentifier: WhAssetCrowdSaleCell.reuseIdentifier)
        
        let add = UIButton(type: .custom)
        add.setImage(UIImage(named: "asset_icon_add"), for: .normal)
        add.addTarget(self, action: #selector(addAsset), for: .touchUpInside)
        self.view.addSubview(add)
        add.snp.makeConstraints { (make) in
            make.width.height.equalTo(45)
            make.right.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-80)
        }
        self.addButton = add
        
    }
    
    @objc func addAsset() {
        self.performSegue(withIdentifier: "WhCreateAssetViewController", sender: nil)
    }
    
    
    @IBAction func transferAll(_ sender: Any) {
        let transferAll = WhTransferAllViewController(assetInfo: nil)
        self.navigationController?.pushViewController(transferAll, animated: true)
    }
    
    
    @IBAction func toCreate(_ sender: Any) {
        self.performSegue(withIdentifier: "WhCreateAssetViewController", sender: nil)
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
        
        if  total == 0 {
            if emptyView.isHidden == true {
                tableView.isHidden = true
                emptyView.isHidden = false
                view.bringSubviewToFront(emptyView)
            }
            
        } else {
            if tableView.isHidden == true {
                emptyView.isHidden = true
                tableView.isHidden = false
                view.bringSubviewToFront(tableView)
                view.bringSubviewToFront(addButton)
            }
        }
        
        tableView.reloadData()
        
    }
    
    //fetch data
    func fetch(direction: WhPullDirection) {
        guard WhWalletManager.shared.whWallet != nil else {
            return
        }
        
        let parameters = ["address": WhWalletManager.shared.whWallet!.cashAddr]
        let subAddress = "property/listbyowner?pageSize=\(pageSize)&pageNo=\(pageNo)"
        Alamofire.request(fullAddress(relaAddress: subAddress), method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let propertyData = resPonsedDictionary(dictionary: dataSource[indexPath.row], key: "PropertyData") else {
            return tableView.dequeueReusableCell(withIdentifier: WhAssetCell.reuseIdentifier, for: indexPath)
        }
        
        guard let fixed = resPonsedBool(dictionary: propertyData, key: "fixedissuance"), let managed =  resPonsedBool(dictionary: propertyData, key: "managedissuance") else {
            return tableView.dequeueReusableCell(withIdentifier: WhAssetCell.reuseIdentifier, for: indexPath)
        }
        
        if fixed || managed {
            let cell = tableView.dequeueReusableCell(withIdentifier: WhAssetCell.reuseIdentifier) as! WhAssetCell
            cell.setDataWithInfo(info: propertyData)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: WhAssetCrowdSaleCell.reuseIdentifier) as! WhAssetCrowdSaleCell
            cell.setDataWithInfo(info: propertyData)
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let propertyData = resPonsedDictionary(dictionary: dataSource[indexPath.row], key: "PropertyData"), let txData =  resPonsedDictionary(dictionary: dataSource[indexPath.row], key: "TxData") else {
            return
        }
        
        guard let fixed = resPonsedBool(dictionary: propertyData, key: "fixedissuance"), let managed =  resPonsedBool(dictionary: propertyData, key: "managedissuance"), let propertyID = resPonsedInt(dictionary: propertyData, key: "propertyid") else {
            return
        }
        var assetType:AssetType!
        if fixed {
            assetType = .fixed
        } else if managed {
            assetType = .managed
        } else {
            assetType = .crowdsale
        }
        let assetDetail = WhAssetDetailViewController(type: assetType, propertyID: propertyID, dictionary: propertyData,  txData: txData)
        assetDetail.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(assetDetail, animated: true)
    }
    
}


class WhAssetCell: UITableViewCell {
    static let reuseIdentifier = "WhAssetCell"
    
    var iconIV: UIImageView!
    var nameLabel:UILabel!
    var idLabel:UILabel!
    var totalLabel:UILabel!
    var typeLabel:UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configSubViews()  {
        let iconView = UIImageView(frame: CGRect.zero)
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(36)
            make.left.top.equalTo(20)
        }
        self.iconIV = iconView
        
        let nameLabel = UILabel()
        nameLabel.text = "ABCDEFG"
        nameLabel.textColor = UIColor(hex: 0x53627C)
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(5)
            make.centerY.equalTo(iconView.snp.centerY)
        }
        self.nameLabel = nameLabel
        
        let idLabel = UILabel()
        idLabel.text = "(ID: 234)"
        idLabel.textColor = UIColor(hex: 0x53627C)
        idLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        contentView.addSubview(idLabel)
        idLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(5)
            make.centerY.equalTo(nameLabel.snp.centerY)
        }
        self.idLabel = idLabel
        
        let typeLabel = UILabel()
        typeLabel.text = "xxx资产"
        typeLabel.textColor = UIColor(hex: 0x53627C)
        typeLabel.textAlignment = .center
        typeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        contentView.addSubview(typeLabel)
        typeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(idLabel.snp.centerY)
            make.width.equalTo(110)
            make.height.equalTo(30)
        }
        self.typeLabel = typeLabel
        
        let container = UIView()
        contentView.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.top.equalTo(iconView.snp.bottom).offset(5)
            make.left.equalTo(iconView.snp.left)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        let assetTotalLabel = UILabel()
        assetTotalLabel.text = "total: 123729173"
        assetTotalLabel.textColor = UIColor(hex: 0xC9CED6)
        assetTotalLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        container.addSubview(assetTotalLabel)
        assetTotalLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        self.totalLabel = assetTotalLabel
        
    }
    
    func setDataWithInfo(info: Dictionary<String,Any>) {
        guard let fixed = resPonsedBool(dictionary: info, key: "fixedissuance"), let managed =  resPonsedBool(dictionary: info, key: "managedissuance") else {
            return
        }
        if fixed {
            self.iconIV.image   = UIImage(named: "browse_icon_smart")
            self.typeLabel.text = "Fixed"
            self.typeLabel.textColor = UIColor(hex: 0x0BB07B)
            self.typeLabel.backgroundColor = UIColor(hex: 0x0BB07B, alpha: 0.1)
        } else if managed {
            self.iconIV.image   = UIImage(named: "browse_icon_management")
            self.typeLabel.text = "Managed"
            self.typeLabel.textColor = UIColor(hex: 0x0C66FF)
            self.typeLabel.backgroundColor = UIColor(hex: 0x0C66FF, alpha: 0.1)
        }
        self.nameLabel.text = resPonsedString(dictionary: info, key: "name")
        self.idLabel.text =  "(ID: \(resPonsedString(dictionary: info, key: "propertyid")!))"
        self.totalLabel.text = "total: \(resPonsedString(dictionary: info, key: "totaltokens")!)"
        
    }
    
}


class WhAssetCrowdSaleCell: UITableViewCell {
    static let reuseIdentifier = "WhAssetCrowdSaleCell"
    var iconIV: UIImageView!
    var nameLabel:UILabel!
    var idLabel:UILabel!
    var totalLabel:UILabel!
    var typeLabel:UILabel!
    var timeLabel: UILabel!
    var purchaseLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configSubViews()  {
        let iconView = UIImageView(frame: CGRect.zero)
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(36)
            make.left.top.equalTo(10)
        }
        self.iconIV = iconView
        
        let nameLabel = UILabel()
        nameLabel.text = "ABCDEFG"
        nameLabel.textColor = UIColor(hex: 0x53627C)
        nameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(5)
            make.centerY.equalTo(iconView.snp.centerY)
        }
        self.nameLabel = nameLabel
        
        let idLabel = UILabel()
        idLabel.text = "(ID: 234)"
        idLabel.textColor = UIColor(hex: 0x53627C)
        idLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        contentView.addSubview(idLabel)
        idLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(5)
            make.centerY.equalTo(nameLabel.snp.centerY)
        }
        self.idLabel = idLabel
        
        let typeLabel = UILabel()
        typeLabel.text = "xxx资产"
        typeLabel.textColor = UIColor(hex: 0x53627C)
        typeLabel.textAlignment = .center
        typeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        contentView.addSubview(typeLabel)
        typeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(idLabel.snp.centerY)
            make.width.equalTo(110)
            make.height.equalTo(30)
        }
        self.typeLabel = typeLabel
        
        let container = UIView()
        contentView.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.top.equalTo(iconView.snp.bottom).offset(5)
            make.left.equalTo(iconView.snp.left)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        let assetTotalLabel = UILabel()
        assetTotalLabel.text = "total: 123729173"
        assetTotalLabel.textColor = UIColor(hex: 0xC9CED6)
        assetTotalLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        container.addSubview(assetTotalLabel)
        assetTotalLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        self.totalLabel = assetTotalLabel
        
        let purchaseLabel = UILabel()
        purchaseLabel.text = "purchase: 123729173"
        purchaseLabel.textColor = UIColor(hex: 0xC9CED6)
        purchaseLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        container.addSubview(purchaseLabel)
        purchaseLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.purchaseLabel = purchaseLabel
        
        
        let timeLabel = UILabel()
        timeLabel.textColor = UIColor(hex: 0xC9CED6)
        timeLabel.textAlignment = .right
        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        container.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(typeLabel.snp.right)
            make.bottom.equalTo(container.snp.bottom)
        }
        self.timeLabel = timeLabel
        
    }
    
    func setDataWithInfo(info: Dictionary<String,Any>) {
        guard let fixed = resPonsedBool(dictionary: info, key: "fixedissuance"), let managed =  resPonsedBool(dictionary: info, key: "managedissuance") else {
            return
        }
        if !fixed || !managed {
            self.iconIV.image   = UIImage(named: "browse_icon_crowd")
            self.typeLabel.text = "Crowd Sale"
            self.typeLabel.textColor = UIColor(hex: 0xF07300)
            self.typeLabel.backgroundColor = UIColor(hex: 0xF07300, alpha: 0.1)
        }
        self.nameLabel.text = resPonsedString(dictionary: info, key: "name")
        self.idLabel.text =  "(ID: \(resPonsedString(dictionary: info, key: "propertyid")!))"
        self.totalLabel.text = "(ID: \(resPonsedString(dictionary: info, key: "totaltokens")!))"
        self.timeLabel.text = resPonsedString(dictionary: info, key: "time")
    }
    
}
