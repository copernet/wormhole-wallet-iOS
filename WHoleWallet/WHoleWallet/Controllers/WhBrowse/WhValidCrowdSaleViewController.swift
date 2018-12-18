//
/*******************************************************************************

        WhValidCrowdSaleViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/12/3
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import SnapKit
import XLPagerTabStrip
import MJRefresh
import Alamofire

class WhValidCrowdSaleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, IndicatorInfoProvider, UISearchBarDelegate {
    static let barHight = 50
    var searchBar: UISearchBar!
    
    let tableView:UITableView = UITableView(frame: CGRect.zero, style: .plain)
    let footer = MJRefreshAutoNormalFooter()
    var emptyView: UIView!
    
    var dataSource = [Dictionary<String,Any>]()
    var pageNo = 0
    var pageSize: Int {
        return 20
    }
    var total = 0
    
    var itemInfo: IndicatorInfo = "All"
    
    init(itemInfo: IndicatorInfo) {
        self.itemInfo = itemInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.searchBar.aTap = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func walletChanged(notification: Notification) {
        fetch(direction: .none, serach: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(walletChanged(notification:)), name: Notification.Name.AppController.walletChanged, object: nil)
        
        //empty view
        if emptyView == nil {
            let container = UIView()
            container.isHidden = true
            self.emptyView = container
            let iconView = UIImageView(image: UIImage(named: "pic-nomessage"))
            container.addSubview(iconView)
            iconView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            
            self.view.addSubview(container)
            container.snp.makeConstraints { (make) in
                make.top.equalTo(WhValidCrowdSaleViewController.barHight)
                make.left.right.bottom.equalToSuperview()
            }
        }
        
        //tableview
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        if #available(iOS 11, *) {
            self.tableView.estimatedRowHeight = 0;
            self.tableView.estimatedSectionFooterHeight = 0;
            self.tableView.estimatedSectionHeaderHeight = 0;
        }
        tableView.register(WhAssetCell.self, forCellReuseIdentifier: WhAssetCell.reuseIdentifier)
        tableView.register(WhAssetCrowdSaleCell.self, forCellReuseIdentifier: WhAssetCrowdSaleCell.reuseIdentifier)
        
        //refresh control top
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.theme
        refreshControl.addTarget(self, action: #selector(headerRefresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
        
        // refresh bottom
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        self.tableView.mj_footer = footer
        
        //avoid empty row
        self.tableView.tableFooterView = UIView()
        
        //searchbar
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: Int(screenWidth()), height: WhValidCrowdSaleViewController.barHight))
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        self.searchBar = searchBar
        tableView.tableHeaderView = searchBar
        
        
        
        fetch(direction: .none, serach: nil)
    }
    
    
    //search delegeate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if searchBar.aTap == nil {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapToDismiss(tapGesture:)))
            self.view.addGestureRecognizer(tap)
            searchBar.aTap = tap
        }else if searchBar.aTap?.view == nil{
            self.view.addGestureRecognizer(searchBar.aTap!)
        }
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool{
        if let tap = searchBar.aTap {
            tap.view?.removeGestureRecognizer(tap)
        }
        
        if let searchText = searchBar.text {
            if searchText.count > 0 {
                total  = 0
                pageNo = 0
                fetch(direction: .none, serach: searchText)
            }
        }
        
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    @objc func tapToDismiss(tapGesture: UITapGestureRecognizer)  {
        self.view.endEditing(true)
        tapGesture.view?.removeGestureRecognizer(tapGesture)
    }
    
    @objc func headerRefresh() {
        pageNo = 0
        fetch(direction: .down, serach: searchBar.text)
    }
    
    @objc func footerRefresh() {
        pageNo += 1
        fetch(direction: .up, serach: searchBar.text)
    }
    
    func updateViewWithData() {
        //have load all data
        if self.dataSource.count >= total {
            footer.endRefreshingWithNoMoreData()
        }
        tableView.reloadData()
        
        if dataSource.count == 0 {
            if self.emptyView.isHidden{
                self.emptyView.isHidden = false
                self.view.bringSubviewToFront(self.emptyView)
            }
        }else {
            self.emptyView.isHidden = true
            self.view.bringSubviewToFront(self.tableView)
        }
    }
    
    //fetch data
    func fetch(direction: WhPullDirection, serach: String?) {
        guard WhWalletManager.shared.whWallet != nil else {
            return
        }
        var path: String
        if let searchKey = serach {
            if searchKey.count > 0 {
                path = "crowdsale/list/active?pageSize=\(pageSize)&pageNo=\(pageNo)&keyword=\(searchKey)"
            }else{
                path = "crowdsale/list/active?pageSize=\(pageSize)&pageNo=\(pageNo)"
            }
        }else {
            path = "crowdsale/list/active?pageSize=\(pageSize)&pageNo=\(pageNo)"
        }
        
        Alamofire.request(fullAddress(relaAddress: path), method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            DLog(message: response)
            //success handle
            if response.result.isSuccess {
                let value  = response.result.value as! Dictionary<String,Any>
                if let result:Dictionary<String,Any> = resPonsedResult(dictionary: value) {
                    DLog(message: result)
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
    
    
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let propertyData =  dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: WhAssetCrowdSaleCell.reuseIdentifier) as! WhAssetCrowdSaleCell
        cell.setDataWithInfo(info: propertyData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let propertyData =  dataSource[indexPath.row]
        guard let propertyID = resPonsedInt(dictionary: propertyData, key: "propertyid") else {
            return
        }
        let assetType:AssetType = .crowdsale
     
        let assetDetail = WhAssetDetailViewController(type: assetType, propertyID: propertyID, dictionary: propertyData,  txData: Dictionary<String,Any>())
        assetDetail.hidesBottomBarWhenPushed = true
        assetDetail.canJoin = true
        self.navigationController?.pushViewController(assetDetail, animated: true)
    }
    
    
  
    
}

