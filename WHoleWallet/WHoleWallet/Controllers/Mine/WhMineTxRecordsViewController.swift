//
/*******************************************************************************

        WhMineTxRecordsViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/12/5
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import MJRefresh
import Alamofire

class WhMineTxRecordsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //table
    let footer = MJRefreshAutoNormalFooter()
    var displayNum = 0
    var dataSource = [Dictionary<String,Any>]()
    var pageNo = 0
    var pageSize: Int {
        return 20
    }
    var total = 0
    var tableView = UITableView(frame: .zero, style: .plain)
    
    
    @IBOutlet var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        //avoid
        if #available(iOS 11, *) {
            self.tableView.estimatedRowHeight = 0;
            self.tableView.estimatedSectionFooterHeight = 0;
            self.tableView.estimatedSectionHeaderHeight = 0;
        }
        self.view.addSubview(tableView)
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        tableView.register(WhTransHistoryCell.self, forCellReuseIdentifier: WhTransHistoryCell.cellIdentifier)
        
        
        //refresh control top and bottom
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        refreshControl.backgroundColor = UIColor(hex: 0x0C66FF)
        refreshControl.addTarget(self, action: #selector(headerRefresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
        
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        self.tableView.mj_footer = footer
        
        fetch(direction: .none)
        
        
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
    
    
    
    //fetch data
    func fetch(direction: WhPullDirection) {
        guard WhWalletManager.shared.whWallet != nil else {
            return
        }
        
        let parameters = ["address": WhWalletManager.shared.whWallet!.cashAddr, "pageSize":pageSize, "pageNo": pageNo] as [String : Any]
        let subAddress = "history/list?pageSize=\(pageSize)&pageNo=\(pageNo)"
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
    
    
    
    //delegate & datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WhTransHistoryCell.cellIdentifier, for: indexPath) as! WhTransHistoryCell
        
        cell.accessoryType = .disclosureIndicator
        cell.setWithDictionary(dictionary: self.dataSource[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "MineTxDetail", sender: dataSource[indexPath.row])
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detail = segue.destination as! WhTxDetailViewController
        let txInfo = sender as! Dictionary<String,Any>
        detail.txHash = resPonsedString(dictionary: txInfo, key: "tx_hash")
    }

    

}
