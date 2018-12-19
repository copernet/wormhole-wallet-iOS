//
/*******************************************************************************

        WhAssetDetailViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/11/30
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import SnapKit
import MJRefresh
import Alamofire

let baseTag = 10000

class WhAssetDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextViewDelegate {
  
    //can create crowdsale
    var canJoin = false
    
    var assetType: AssetType
    var propertyID: Int // 0 bch, 1 whc
    var dataDictionary: Dictionary<String,Any>
    var txData: Dictionary<String,Any>
    var tableView: UITableView!
    
    //table
    let footer = MJRefreshAutoNormalFooter()
    var displayNum = 0
    var dataSource = [Dictionary<String,Any>]()
    var pageNo = 0
    var pageSize: Int {
        return 20
    }
    var total = 0
    
    
    
    init(type: AssetType, propertyID: Int, dictionary: Dictionary<String,Any>, txData: Dictionary<String,Any>) {
        self.assetType = type
        self.propertyID = propertyID
        self.dataDictionary = dictionary
        self.txData = txData
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool{
        let webView = WhWebViewController(urlString: URL.absoluteString)
        self.navigationController?.pushViewController(webView, animated: true)
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true
        self.view.backgroundColor = UIColor.white
        self.title = "Token Detail"
        configTableView()
        fetch(direction: .none)
    }
    
    
    func configTableView()  {
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
        let headerView = createHeaderView(dictionary: dataDictionary)
        tableView.tableHeaderView = headerView
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
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
        
    }
    
    
    func createHeaderView(dictionary: Dictionary<String, Any>) -> UIView {
        let headerView = UIView()
        headerView.snp.makeConstraints { (make) in
            make.width.equalTo(screenWidth())
            make.height.greaterThanOrEqualTo(100).priority(500)
        }
        
        let topBg = UIImageView(image: UIImage(named: "browse_blue_bg"))
        topBg.contentMode = .scaleAspectFill
        headerView.addSubview(topBg)
        topBg.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
        }
        
        let typeNameLabel = UILabel()
        typeNameLabel.text = self.assetType.rawValue
        typeNameLabel.textColor = UIColor.white
        typeNameLabel.font = UIFont.systemFont(ofSize: 18)
        headerView.addSubview(typeNameLabel)
        typeNameLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(20)
        }
        
        //top card
        let cardView = UIView()
        cardView.backgroundColor = UIColor.white
        cardView.layer.cornerRadius = 8
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 2, height: 3)
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOpacity = 0.5;
        headerView.addSubview(cardView)
        cardView.snp.makeConstraints { (make) in
            make.left.equalTo(typeNameLabel.snp.left)
            make.top.equalTo(typeNameLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        
        let assetNameLabel = UILabel()
        assetNameLabel.text = resPonsedString(dictionary: dictionary, key: "name")
        assetNameLabel.textColor = UIColor(hex: 0x182C4F)
        assetNameLabel.font = UIFont.systemFont(ofSize: 23)
        cardView.addSubview(assetNameLabel)
        assetNameLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(20)
        }
        
        let assetIDLabel = UILabel()
        assetIDLabel.text = "(ID\(resPonsedString(dictionary: dictionary, key: "propertyid")!))"
        assetIDLabel.textColor = UIColor(hex: 0x8A94A6)
        assetIDLabel.font = UIFont.systemFont(ofSize: 13)
        cardView.addSubview(assetIDLabel)
        assetIDLabel.snp.makeConstraints { (make) in
            make.left.equalTo(assetNameLabel.snp.right).offset(15)
            make.centerY.equalTo(assetNameLabel.snp.centerY)
        }
        
        
        
        let assetDesLabel = UITextView()
        assetDesLabel.textColor = UIColor.darkTextColor
        let data = resPonsedString(dictionary: dataDictionary, key: "data")!
        let url  = resPonsedString(dictionary: dataDictionary, key:  "url")!
        let fullString = data + " " + url
        let range = fullString.range(of: url)
        let attributeString = NSMutableAttributedString(string: fullString)
        attributeString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.theme, NSAttributedString.Key.link: url], range: NSRange(range!, in: fullString))
        assetDesLabel.font = UIFont.systemFont(ofSize: 12)
        assetDesLabel.attributedText = attributeString
        assetDesLabel.delegate = self
        assetDesLabel.isEditable = false
        assetDesLabel.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.theme]
        let size = assetDesLabel.sizeThatFits(CGSize(width: screenWidth() - 40 * 2, height: CGFloat.greatestFiniteMagnitude))
        cardView.addSubview(assetDesLabel)
        assetDesLabel.snp.makeConstraints { (make) in
            make.left.equalTo(assetNameLabel.snp.left)
            make.top.equalTo(assetNameLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(size.height)
        }
        
//        let assetDesLabel = UILabel()
//        assetDesLabel.text = resPonsedString(dictionary: dataDictionary, key: "data")
//        assetDesLabel.textColor = UIColor(hex: 0x0C66FF)
//        assetDesLabel.font = UIFont.systemFont(ofSize: 12)
//        assetDesLabel.numberOfLines = 0
//
//        cardView.addSubview(assetDesLabel)
//        assetDesLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(assetNameLabel.snp.left)
//            make.top.equalTo(assetNameLabel.snp.bottom).offset(20)
//            make.centerX.equalToSuperview()
//        }
        
        
        
        let aSpace = 12
        
        //address
        let creatorAddressLabel = UILabel()
        creatorAddressLabel.text = "发行者地址:"
        creatorAddressLabel.textColor = UIColor(hex: 0x445571)
        creatorAddressLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        cardView.addSubview(creatorAddressLabel)
        creatorAddressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(aSpace)
            make.top.equalTo(assetDesLabel.snp.bottom).offset(40)
        }
        
        let addrBg = UIView()
        addrBg.backgroundColor = UIColor(hex: 0xF9F9F9)
        cardView.addSubview(addrBg)
        addrBg.snp.makeConstraints { (make) in
            make.left.equalTo(creatorAddressLabel.snp.left)
            make.top.equalTo(creatorAddressLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        let bchAddressLabel = UILabel()
        bchAddressLabel.text = WhWalletManager.shared.whWallet?.cashAddr
        bchAddressLabel.textColor = UIColor(hex: 0x8A94A6)
        bchAddressLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        addrBg.addSubview(bchAddressLabel)
        bchAddressLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(10)
            make.centerY.equalToSuperview()
        }
        
        let addressShow = UIButton(type: .custom)
        addressShow.addTarget(self, action: #selector(showQRCode), for: .touchUpInside)
        addrBg.addSubview(addressShow)
        addressShow.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.centerY.equalTo(bchAddressLabel.snp.centerY)
            make.right.equalTo(13)
            make.left.equalTo(bchAddressLabel.snp.right).offset(15)
        }
        
        let itemSpaceH = 15
        
        // category
        let categoryView = WhAssetDetailItem(title: "Category:", value: resPonsedString(dictionary: dictionary, key: "category"))
        cardView.addSubview(categoryView)
        categoryView.snp.makeConstraints { (make) in
            make.left.equalTo(addrBg.snp.left)
            make.top.equalTo(addrBg.snp.bottom).offset(itemSpaceH)
        }
        
        // number
        let tokenNumberView = WhAssetDetailItem(title: "Total:", value: resPonsedString(dictionary: dictionary, key: "totaltokens"))
        cardView.addSubview(tokenNumberView)
        tokenNumberView.snp.makeConstraints { (make) in
            make.left.equalTo(categoryView.snp.left)
            make.right.equalTo(categoryView.snp.right)
            make.top.equalTo(categoryView.snp.bottom).offset(itemSpaceH)
        }
        
        if assetType == .crowdsale {
            // deadline
            let deadLineView = WhAssetDetailItem(title: "DeadLine Time:", value: resPonsedString(dictionary: dictionary, key: "totaltokens"))
            cardView.addSubview(deadLineView)
            deadLineView.snp.makeConstraints { (make) in
                make.left.equalTo(tokenNumberView.snp.left)
                make.right.equalTo(tokenNumberView.snp.right)
                make.top.equalTo(tokenNumberView.snp.bottom).offset(itemSpaceH)
            }
            
            // rates
            let rateView = WhAssetDetailItem(title: "Rates(tokens/whc):", value: resPonsedString(dictionary: dictionary, key: "totaltokens"))
            cardView.addSubview(rateView)
            rateView.snp.makeConstraints { (make) in
                make.left.equalTo(deadLineView.snp.left)
                make.right.equalTo(deadLineView.snp.right)
                make.top.equalTo(deadLineView.snp.bottom).offset(itemSpaceH)
            }
        }
        
        
        //subcategory
        let subCategoryView = WhAssetDetailItem(title: "SubCategory:", value: resPonsedString(dictionary: dictionary, key: "subcategory"))
        cardView.addSubview(subCategoryView)
        subCategoryView.snp.makeConstraints { (make) in
            make.right.equalTo(addrBg.snp.right)
            make.top.equalTo(categoryView.snp.top)
            make.width.equalTo(categoryView.snp.width)
            make.left.equalTo(categoryView.snp.right).offset(aSpace)
        }
        
        //precision
        let precisionView = WhAssetDetailItem(title: "Precision:", value: resPonsedString(dictionary: dictionary, key: "precision"))
        cardView.addSubview(precisionView)
        
        
       
        if assetType != .crowdsale {
            precisionView.snp.makeConstraints { (make) in
                make.left.equalTo(subCategoryView.snp.left)
                make.right.equalTo(subCategoryView.snp.right)
                make.top.equalTo(subCategoryView.snp.bottom).offset(aSpace)
                make.bottom.equalToSuperview().offset(-itemSpaceH)
            }
            
        } else {
            //buy token number
            let purchaseNumberView = WhAssetDetailItem(title: "Purchase Tokens:", value: resPonsedString(dictionary: dictionary, key: "precision"))
            cardView.addSubview(purchaseNumberView)
            purchaseNumberView.snp.makeConstraints { (make) in
                make.left.equalTo(subCategoryView.snp.left)
                make.right.equalTo(subCategoryView.snp.right)
                make.top.equalTo(subCategoryView.snp.bottom).offset(aSpace)
            }
            
            
            //early bird
            let earlyBirdView = WhAssetDetailItem(title: "Early Bird Bonus(%)", value: resPonsedString(dictionary: dictionary, key: "precision"))
            cardView.addSubview(earlyBirdView)
            earlyBirdView.snp.makeConstraints { (make) in
                make.left.equalTo(purchaseNumberView.snp.left)
                make.right.equalTo(purchaseNumberView.snp.right)
                make.top.equalTo(purchaseNumberView.snp.bottom).offset(aSpace)
            }
            
            precisionView.snp.makeConstraints { (make) in
                make.left.equalTo(earlyBirdView.snp.left)
                make.right.equalTo(earlyBirdView.snp.right)
                make.top.equalTo(earlyBirdView.snp.bottom).offset(aSpace)
                make.bottom.equalToSuperview().offset(-itemSpaceH)
            }
            
        }
        
        
    
        
        if canJoin {
            //add join crowdsale button
            let joinCrowSale = UIButton(type: .custom)
            joinCrowSale.backgroundColor = UIColor(hex: 0x0C66FF)
            joinCrowSale.setTitle("Join CrowdSale", for: .normal)
            joinCrowSale.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            joinCrowSale.addTarget(self, action: #selector(toJoinPage), for: .touchUpInside)
            joinCrowSale.layer.cornerRadius = 22.5
            joinCrowSale.layer.shadowColor = UIColor(hex: 0x0C66FF).cgColor
            joinCrowSale.layer.shadowOffset = CGSize(width: 5, height: 8)
            joinCrowSale.layer.shadowRadius = 22.5
            joinCrowSale.layer.shadowOpacity = 0.5;
            headerView.addSubview(joinCrowSale)
            joinCrowSale.snp.makeConstraints { (make) in
                make.left.equalTo(80)
                make.centerX.equalToSuperview()
                make.top.equalTo(cardView.snp.bottom).offset(30)
                make.height.equalTo(45)
            }
            
            //transaction record tag
            let txRecordIcon = UIImageView(image: UIImage(named: "main_icon_history"))
            headerView.addSubview(txRecordIcon)
            txRecordIcon.snp.makeConstraints { (make) in
                make.left.equalTo(cardView.snp.left)
                make.top.equalTo(joinCrowSale.snp.bottom).offset(30)
                make.bottom.equalToSuperview().offset(-20)
            }
            
            let txRecordTag = UILabel()
            txRecordTag.text = "Transaction Record:"
            txRecordTag.textColor = UIColor(hex: 0x445571)
            txRecordTag.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            headerView.addSubview(txRecordTag)
            txRecordTag.snp.makeConstraints { (make) in
                make.left.equalTo(txRecordIcon.snp.right).offset(10)
                make.centerY.equalTo(txRecordIcon.snp.centerY)
            }
            
            
        } else {
            
            //asset operate
            let operateContainer = UIView()
            operateContainer.backgroundColor = UIColor.white
            operateContainer.layer.cornerRadius = 8
            operateContainer.layer.shadowColor = UIColor.gray.cgColor
            operateContainer.layer.shadowOffset = CGSize(width: 2, height: 3)
            operateContainer.layer.shadowRadius = 8
            operateContainer.layer.shadowOpacity = 0.5;
            headerView.addSubview(operateContainer)
            operateContainer.snp.makeConstraints { (make) in
                make.left.equalTo(cardView.snp.left)
                make.top.equalTo(cardView.snp.bottom).offset(15)
                make.right.equalTo(cardView.snp.right)
                
            }
            
            
            let operateTag = UILabel()
            operateTag.text = "Asset Operate"
            operateTag.textColor = UIColor(hex: 0x445571)
            operateTag.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            operateContainer.addSubview(operateTag)
            operateTag.snp.makeConstraints { (make) in
                make.left.top.equalTo(aSpace)
            }
            
            // change issuer
            let  issuerChange = WhAssetOperateView(title: "Change Issuer", iconName: "assert_button_change_nor",highLight: "assert_button_change_sel")
            issuerChange.operateBtn.tag = baseTag
            issuerChange.operateBtn.addTarget(self, action: #selector(doAction(sender:)), for: .touchUpInside)
            operateContainer.addSubview(issuerChange)
            issuerChange.snp.makeConstraints { (make) in
                make.left.equalTo(30)
                make.top.equalTo(operateTag.snp.bottom).offset(aSpace)
            }
            
            // change issuer
            let  transRecord = WhAssetOperateView(title: "Send", iconName: "assert_button_output_nor" ,highLight: "assert_button_output_sel")
            transRecord.operateBtn.tag = baseTag + 1
            transRecord.operateBtn.addTarget(self, action: #selector(doAction(sender:)), for: .touchUpInside)
            operateContainer.addSubview(transRecord)
            transRecord.snp.makeConstraints { (make) in
                make.top.equalTo(issuerChange)
                make.left.equalTo(issuerChange.snp.right).offset(30)
                make.width.equalTo(issuerChange)
            }
            
            // change issuer
            let  tokenAirDrop = WhAssetOperateView(title: "Airdrop Token", iconName: "assert_button_airdrop_nor",highLight: "assert_button_airdrop_sel" )
            tokenAirDrop.operateBtn.tag = baseTag + 2
            tokenAirDrop.operateBtn.addTarget(self, action: #selector(doAction(sender:)), for: .touchUpInside)
            operateContainer.addSubview(tokenAirDrop)
            tokenAirDrop.snp.makeConstraints { (make) in
                make.top.equalTo(transRecord)
                make.left.equalTo(transRecord.snp.right).offset(30)
                make.width.equalTo(transRecord)
                make.right.equalToSuperview().offset(-30)
                if assetType == .fixed {
                    make.bottom.equalToSuperview().offset(-aSpace)
                }
            }
            
            if assetType == .managed {
                // grant token
                let  tokenGrant = WhAssetOperateView(title: "Grant Token", iconName: "assert_button_add_nor",highLight: "assert_button_add_sel")
                tokenGrant.operateBtn.tag = baseTag + 3
                tokenGrant.operateBtn.addTarget(self, action: #selector(doAction(sender:)), for: .touchUpInside)
                operateContainer.addSubview(tokenGrant)
                tokenGrant.snp.makeConstraints { (make) in
                    make.left.equalTo(issuerChange.snp.left)
                    make.top.equalTo(issuerChange.snp.bottom).offset(aSpace)
                    make.width.equalTo(issuerChange.snp.width)
                }
                
                // destroy token
                let  tokenDestroy = WhAssetOperateView(title: "Destroy", iconName: "assert_button_distroy_nor", highLight: "assert_button_distroy_nor_sel")
                tokenDestroy.operateBtn.tag = baseTag + 4
                tokenDestroy.operateBtn.addTarget(self, action: #selector(doAction(sender:)), for: .touchUpInside)
                operateContainer.addSubview(tokenDestroy)
                tokenDestroy.snp.makeConstraints { (make) in
                    make.top.equalTo(tokenGrant)
                    make.left.equalTo(tokenGrant.snp.right).offset(30)
                    make.width.equalTo(tokenGrant)
                    make.bottom.equalToSuperview().offset(-aSpace)
                }
            } else if assetType == .crowdsale {
                // close token
                let  tokenClose = WhAssetOperateView(title: "Close Token", iconName: "assert_button_close_nor", highLight: "assert_button_close_nor_sel")
                tokenClose.operateBtn.tag = baseTag + 5
                tokenClose.operateBtn.addTarget(self, action: #selector(doAction(sender:)), for: .touchUpInside)
                operateContainer.addSubview(tokenClose)
                tokenClose.snp.makeConstraints { (make) in
                    make.left.equalTo(issuerChange.snp.left)
                    make.top.equalTo(issuerChange.snp.bottom).offset(aSpace)
                    make.width.equalTo(issuerChange.snp.width)
                    make.bottom.equalToSuperview().offset(-aSpace)
                }
            }
            
            
            //transaction record tag
            let txRecordIcon = UIImageView(image: UIImage(named: "main_icon_history"))
            headerView.addSubview(txRecordIcon)
            txRecordIcon.snp.makeConstraints { (make) in
                make.left.equalTo(operateContainer.snp.left)
                make.top.equalTo(operateContainer.snp.bottom).offset(20)
                make.bottom.equalToSuperview().offset(-20)
            }
            
            let txRecordTag = UILabel()
            txRecordTag.text = "Transaction Record:"
            txRecordTag.textColor = UIColor(hex: 0x445571)
            txRecordTag.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            headerView.addSubview(txRecordTag)
            txRecordTag.snp.makeConstraints { (make) in
                make.left.equalTo(txRecordIcon.snp.right).offset(10)
                make.centerY.equalTo(txRecordIcon.snp.centerY)
            }
        }
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        return headerView
        
    }
    
    
    
    
    @objc func toJoinPage() {
        let joinPage = WhJoinCrowdSaleViewController()
        joinPage.assetInfo = dataDictionary
        self.navigationController?.pushViewController(joinPage, animated: true)
    }
    
    
    @objc func showQRCode () {
        
    }
    
    @objc func doAction(sender: UIButton) {
        var dest:UIViewController?
        switch sender.tag {
        case baseTag:
            dest = WhChangeIssuerViewController(assetInfo: txData)
            break
        case baseTag + 1:
            dest = WhSendAssetViewController(assetInfo: txData)
            break
        case baseTag + 2:
            dest = WhAirDropAssetViewController(assetInfo: txData)
            break
        case baseTag + 3:
            dest = WhGrantAssetViewController(assetInfo: txData)
            break
        case baseTag + 4:
            dest = WhDestroyAssetViewController(assetInfo: txData)
            break
        case baseTag + 5:
            dest = WhCloseAssetViewController(assetInfo: txData)
            break
        default:
            break
        }
        
        guard let destVC = dest else {
            return
        }
        self.navigationController?.pushViewController(destVC, animated: true)
        
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
        
        let parameters = ["address": WhWalletManager.shared.whWallet!.cashAddr, "property_id": propertyID, "pageSize":pageSize, "pageNo": pageNo] as [String : Any]
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
        let cell = tableView.dequeueReusableCell(withIdentifier: WhTransHistoryCell.cellIdentifier) as! WhTransHistoryCell
        cell.setWithDictionary(dictionary: self.dataSource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }


}
