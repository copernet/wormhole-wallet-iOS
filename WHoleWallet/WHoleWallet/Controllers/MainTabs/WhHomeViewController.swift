//
/*******************************************************************************

        WhHomeViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/11/19
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import Foundation
import MJRefresh
import BitcoinKit
import Alamofire


let CURRENTADDRESS = "bchtest:qq2j9gp97gm9a6lwvhxc4zu28qvqm0x4j5e72v7ejg"

class WhHomeViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    static let cellIdentifier = "HomeCell"
    let footer = MJRefreshAutoNormalFooter()
    let tableView = UITableView(frame: CGRect.zero, style: .plain)
    var bchWalletBtn: WhWalletButton = WhWalletButton(bg: "main_bch_bg", icon: "main_bch", name: "BCH Wallet", amount: "0")
    var whWalletBtn: WhWalletButton  = WhWalletButton(bg: "main_whc_bg", icon: "main_whc", name: "WHC Wallet", amount: "0")
    var accountNameLabel: UILabel!
    var addressLabel: UILabel!
    var balanceLabel: UILabel!
    
    var payments = [Payment]()
    
    var wallets: [WhWallet]?
    
    var whcBalance: String?
    
    var dataSource = [Dictionary<String,Any>]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var whcText: String {
        get {
            guard let amount = whcBalance else {
                return "0 WHC"
            }
            return amount + " WHC"
        }
    }
    
    func configViews() {
        //tableview
        self.tableView.delegate   = self
        self.tableView.dataSource = self
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        if #available(iOS 11, *) {
            self.tableView.estimatedRowHeight = 0;
            self.tableView.estimatedSectionFooterHeight = 0;
            self.tableView.estimatedSectionHeaderHeight = 0;
        }
        
        
        //refresh control top and bottom
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(WhHomeViewController.headerRefresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
        
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        self.tableView.mj_footer = footer
        self.tableView.mj_footer.isHidden = true
        
        //avoid empty row
        self.tableView.tableFooterView = UIView()
        
        //config header
        createHeader()
    }
    
    
    func createHeader() {
        let tableHeader = UIView()
        tableHeader.snp.makeConstraints { (make) in
            make.width.equalTo(screenWidth())
            make.height.greaterThanOrEqualTo(100).priority(500)
        }
        self.tableView.refreshControl?.backgroundColor = UIColor(hex: 0x125fff)
        
        let blueBg = UIImageView(image: UIImage(named: "main_blue_bg"))
        blueBg.contentMode = .scaleAspectFill
        blueBg.isUserInteractionEnabled = true
        tableHeader.addSubview(blueBg)
        blueBg.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalToSuperview().offset(-10)
        }
        
        let photoView = UIButton(type: .custom)
        photoView.addTarget(self, action: #selector(changePhoto), for: .touchUpInside)
        photoView.setImage(UIImage(named: "main_icon_photo"), for: .normal)
        blueBg.addSubview(photoView)
        photoView.snp.makeConstraints { (make) in
            make.width.height.equalTo(68)
            make.left.top.equalTo(20)
        }
        
        var label = UILabel(frame: CGRect.zero)
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.text = "HAHA"
        blueBg.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(photoView.snp.right).offset(5)
            make.top.equalTo(photoView.snp.top)
        }
        self.accountNameLabel = label
        
        label = UILabel(frame: CGRect.zero)
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "fdalaldafdffdfdueorueorueofff"
        blueBg.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.left.equalTo(photoView.snp.right).offset(5)
            make.bottom.equalTo(photoView.snp.bottom).offset(-10)
        }
        self.addressLabel = label
        
        let qrCodeView = UIButton(type: .custom)
        qrCodeView.addTarget(self, action: #selector(showQRCode), for: .touchUpInside)
        qrCodeView.setImage(UIImage(named: "main_button_QR"), for: .normal)
        blueBg.addSubview(qrCodeView)
        qrCodeView.snp.makeConstraints { (make) in
            make.centerY.equalTo(label.snp.centerY)
            make.left.equalTo(label.snp.right).offset(5)
            make.right.equalTo(-20)
            make.width.height.equalTo(14)
        }
        
        let accountMgView = UIButton(type: .custom)
        accountMgView.addTarget(self, action: #selector(manageAccount), for: .touchUpInside)
        accountMgView.setImage(UIImage(named: "main_iicon_wallet"), for: .normal)
        accountMgView.isUserInteractionEnabled = true
        blueBg.addSubview(accountMgView)
        accountMgView.snp.makeConstraints { (make) in
            make.top.equalTo(photoView.snp.top)
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(19)
        }
        
        
        let myBalanceTag = UILabel(frame: CGRect.zero)
        myBalanceTag.textColor = UIColor.white
        myBalanceTag.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        myBalanceTag.text = "My Balance"
        blueBg.addSubview(myBalanceTag)
        myBalanceTag.snp.makeConstraints { (make) in
            make.left.equalTo(photoView.snp.right).offset(5)
            make.top.equalTo(photoView.snp.bottom)
        }
        
        let eyeView = UIButton(type: .custom)
        eyeView.addTarget(self, action: #selector(showAccount(sender:)), for: .touchUpInside)
        eyeView.setImage(UIImage(named: "main_icon_open_eyes"), for: .normal)
        eyeView.setImage(UIImage(named: "main_icon_close_eyes"), for: .selected)
        blueBg.addSubview(eyeView)
        eyeView.snp.makeConstraints { (make) in
            make.centerY.equalTo(myBalanceTag.snp.centerY)
            make.left.equalTo(myBalanceTag.snp.right).offset(5)
            make.width.height.equalTo(14)
        }
        
        
        let balanceLabel = UILabel(frame: CGRect.zero)
        balanceLabel.textColor = UIColor.white
        balanceLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        balanceLabel.text = "0 WHC"
        blueBg.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(myBalanceTag.snp.left)
            make.top.equalTo(myBalanceTag.snp.bottom).offset(15)
        }
        self.balanceLabel = balanceLabel
        
        let fireView = UIButton(type: .custom)
        fireView.addTarget(self, action: #selector(fireBitCoinCash), for: .touchUpInside)
        fireView.setImage(UIImage(named: "main_button_burn_nor"), for: .normal)
        blueBg.addSubview(fireView)
        fireView.snp.makeConstraints { (make) in
            make.width.height.equalTo(63)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(balanceLabel.snp.bottom)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        // two row view
        self.bchWalletBtn.bgButton.addTarget(self, action: #selector(showBitCoinCash), for: .touchUpInside)
        tableHeader.addSubview(self.bchWalletBtn)
        self.bchWalletBtn.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(blueBg.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
        }
        
        tableHeader.addSubview(self.whWalletBtn)
        self.whWalletBtn.bgButton.addTarget(self, action: #selector(showWhc), for: .touchUpInside)
        self.whWalletBtn.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(self.bchWalletBtn.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        //set header
        tableHeader.setNeedsLayout()
        tableHeader.layoutIfNeeded()
        self.tableView.tableHeaderView = tableHeader
        
    }
    
    func setTextWithWallet() {
        let wallet = WhWalletManager.shared.whWallet
        accountNameLabel.text = wallet?.name
        addressLabel.text = wallet?.cashAddr
        bchWalletBtn.amountLabel.text = WhWalletManager.shared.getBalancePure().toDouble().toString()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(walletChanged(notification:)), name: Notification.Name.AppController.walletChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(transactionsChange(notification:)), name: Notification.Name.AppController.transactionListChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(balanceChange(notification:)), name: Notification.Name.AppController.balanceChange, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(blockHeadersChange(notification:)), name: Notification.Name.AppController.blockHeadersChanged, object: nil)
        
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        print("box: " + paths[0]);
        
        configViews()
        
        guard let _ = WhWalletManager.shared.whWallet else {
            let storyBoard = UIStoryboard(name: "CreateWallet", bundle: nil)
            self.navigationController?.pushViewController(storyBoard.instantiateInitialViewController()!, animated: false) 
            return
        }
        
        //start fetch bitcoin cash data
        WhWalletManager.shared.afterWalletSet()
        
        DLog(message: WhMerkleVerify.headerCount)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.updateUI()
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    func updateUI() {
        setTextWithWallet()
        fetch()
    }
    
    
    @objc func blockHeadersChange(notification: Notification){
        
    }
    
    @objc func walletChanged(notification: Notification) {
        setTextWithWallet()
        fetch()
    }
    
    
    @objc func transactionsChange(notification: Notification) {
        
    }
    
    @objc func balanceChange(notification: Notification) {
//        balanceLabel.text = WhWalletManager.shared.getBalanceString() + " WHC"
        self.bchWalletBtn.amountLabel.text = WhWalletManager.shared.getBalancePure().toDouble().toString()
    }

    
    @objc func changePhoto() {
        
    }
    
    @objc func showQRCode() {
        guard let whwallet = WhWalletManager.shared.whWallet else {
            return
        }
        let pic = generateVisualQRCode(address: whwallet.cashAddr)
        let alert = WhQRCodeAlertView(bg: "main_qr_bg", pic: pic!, subTitle: whwallet.cashAddr, completeBlock:nil)
        alert.show()
    }
    
    @objc func showAccount(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if !sender.isSelected {
            balanceLabel.text = whcText
        }else{
            balanceLabel.text = "***************** WHC"
        }
    }
    
    @objc func manageAccount() {
        self.performSegue(withIdentifier: "WhWalletManageViewController", sender: nil)
    }
    
    @objc func fireBitCoinCash() {
        //WhFireViewController
        self.performSegue(withIdentifier: "WhFireViewController", sender: nil)
    }
    
    @objc func showBitCoinCash() {
        self.performSegue(withIdentifier: "WhWalletDetailViewController", sender: "BCH")
    }
    
    @objc func showWhc() {
        self.performSegue(withIdentifier: "WhWalletDetailViewController", sender: "WHC")
    }
    
    @objc func headerRefresh() {
        fetch()
    }
    
    @objc func footerRefresh() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let flag:String = sender as? String {
            if flag.compare("BCH") == .orderedSame {
                let detail = segue.destination as! WhWalletDetailViewController
                detail.walletType = .bch
                detail.propertyID = 0
                detail.amountString = bchWalletBtn.amountLabel.text
                detail.tokenName = "BCH"
            }else if flag.compare("WHC") == .orderedSame {
                let detail = segue.destination as! WhWalletDetailViewController
                detail.walletType = .whc
                detail.propertyID = 1
                detail.amountString = whcBalance
                detail.tokenName = "WHC"
            }
        }
        
        if let tokenDetail = sender as? Dictionary<String,Any> {
            let detail = segue.destination as! WhWalletDetailViewController
            detail.walletType = .other
            detail.amountString = resPonsedDouble(dictionary: tokenDetail, key: "balance_available")?.toString()
            detail.propertyID = resPonsedInt(dictionary: tokenDetail, key: "property_id")
            detail.tokenName = tokenDetail["property_name"] as? String
        }
    }
    
    func updateViewWithData() {
        var whc = Dictionary<String,Any>()
        var pid:Any?
        for dic in dataSource {
            pid = dic["property_id"]
            if pid is Int {
                let pi = pid as! Int
                if pi == 1 {
                    whc = dic
                    break;
                }
                
            }else if pid is String {
                if Int(pid as! String) == 1 {
                    whc = dic
                    break;
                }
            }
        }
        
        if whc.count > 0 {
            whcBalance = (whc["balance_available"] as! String).toDouble().toString()
            balanceLabel.text = whcText
            whWalletBtn.amountLabel.text = whcBalance
        }
        
        tableView.reloadData()
    }
    
    
    //fetch data
    func fetch() {
        guard WhWalletManager.shared.whWallet != nil else {
            return
        }
        let parameters = ["address": (WhWalletManager.shared.whWallet?.cashAddr)!]
        Alamofire.request(fullAddress(relaAddress: "balance/addresses"), method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            DLog(message: response)
            response.result.ifSuccess {
                let value  = response.result.value as! Dictionary<String,Any>
                if let result:Dictionary<String,Any> = resPonsedResult(dictionary: value) {
                    let array = result[(WhWalletManager.shared.whWallet?.cashAddr)!]
                    if array is Array<Dictionary<String,Any>>  {
                        let source = array as! Array<Dictionary<String,Any>>
                        self.dataSource = source
                        
                    }
                }
            }
            //end refresh
            if self.tableView.refreshControl!.isRefreshing {
                DispatchQueue.main.async {
                    self.tableView.refreshControl!.endRefreshing()
                }
            }
            
            //update ui
            self.updateViewWithData()
            
        }
    }
    
    //delegate and source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: WhHomeViewController.cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: WhHomeViewController.cellIdentifier)
        }
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.text = (dataSource[indexPath.row]["property_name"] as! String)
        cell?.textLabel?.textColor = UIColor(hex: 0x445571)
        cell?.detailTextLabel?.text = (dataSource[indexPath.row]["balance_available"] as! String)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "WhWalletDetailViewController", sender: self.dataSource[indexPath.row]);
    }
    
    
}
