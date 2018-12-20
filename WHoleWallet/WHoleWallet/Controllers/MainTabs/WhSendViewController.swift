//
/*******************************************************************************

        WhSendViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/11/26
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import BitcoinKit
import Alamofire


class WhSendViewController: UIViewController,UITextFieldDelegate {
    
    var propertyID: Int!
    
    private var scrollView = UIScrollView(frame: CGRect.zero)
    var toTF: UITextField!
    var feeTF: UITextField!
    var amountTF: UITextField!
    var feeRateView: WhFeeRateView!
    
    var payMents: [Payment]!
    var feeDictionary = Dictionary<String,Double>()
    
    @objc func sureAction(_ sender: Any) {
        guard let whWallet = WhWalletManager.shared.whWallet else {
            return
        }
        guard let amountString = amountTF.text  else {
            return
        }
        let amount = Int64(amountString.toDouble() * 10_000_000)
        guard let fee = feeTF.text, let to = toTF.text, let pID = propertyID else {
            return
        }
        
        if propertyID == 0 {//bch
            //input datas valid
            let alert = WhInputAlertView(icon: "main_icon_lock", title: "Please enter your password", promot: "Password invalid,Please check them and try again", sure: "Sure", closeBtn: true, completeBlock: { (popupView, flag) in
                let popView = popupView as! WhInputAlertView
                //use password
                DLog(message: popView.password)
                
                
                //creaet a hd wallet
                let hdWallet = WhWalletManager.shared.getHDWallet(index: whWallet.index, password: popView.password!)
                if let wallet = hdWallet {
                    self.sendToSomeAddress(wallet: wallet, amount: amount, address: to, feeRate: fee)
                }
                
            })
            alert.show()

        }else {//other
            let parameters = ["transaction_version": "0", "fee":fee, "transaction_from": whWallet.cashAddr, "transaction_to    ": to, "currency_identifier": pID] as [String : Any]
            WhHTTPRequestHandler.unsignedOperate(reqCode: 0, parameters: parameters) { (result) in
                if result.count > 0 {
                    WormHoleSignUnSignedTxFlow.handleResult(result: result, complete: {
                        DispatchQueue.main.async {
                            [weak self] in
                            if let weakSelf = self {
                                weakSelf.view!.makeToast("transaction success !", duration: 2.0, title: nil, image: nil) { didTap in
                                    weakSelf.navigationController?.popToRootViewController(animated: true)
                                }
                            }
                            
                        }
                    }, failure: {
                        [weak self] in
                        if let weakSelf = self {
                            weakSelf.view!.makeToast("transaction failed !")
                        }
                    })
                }
                
                //do somthing
                DispatchQueue.main.async {
                    [weak self] in
                    if let weakSelf = self {
                        weakSelf.view!.makeToast("transaction failed !")
                    }
                }
                return
                
            }
        }
        
    }
    
    func fetchFeeRate()  {
        WhHTTPRequestHandler.getFeeRate { (dictionary,fees) in
            if dictionary.count > 0 {
                DispatchQueue.main.async {
                    self.feeRateView.feeRates = fees
                }
            }
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
        fetchFeeRate()
    }
    
    
    func configViews() {
        if scrollView.superview == nil {
            self.view.addSubview(scrollView)
        }
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let container = UIView()
        scrollView.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        let addressView = WhAddressView(address: (WhWalletManager.shared.whWallet?.cashAddr)!)
        container.addSubview(addressView)
        addressView.snp.makeConstraints { (make) in
            make.left.top.equalTo(20)
            make.centerX.equalToSuperview()
        }
        
        
        let receiveAddrL = WhCommonInputRow(icon: "main_icon_input_address", title: "Receive Address", "Please Input Receive Address")
        self.toTF = receiveAddrL.tf
        container.addSubview(receiveAddrL)
        receiveAddrL.snp.makeConstraints { (make) in
            make.left.equalTo(addressView.snp.left)
            make.top.equalTo(addressView.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(WhCommonInputRow.defaultH).priority(500)
        }
        
        let transferAmount = WhCommonInputRow(icon: "assert_icon_number", title: "Transer Amount", "Please Input The Number Your Want To Send")
        self.amountTF = transferAmount.tf
        container.addSubview(transferAmount)
        transferAmount.snp.makeConstraints { (make) in
            make.left.equalTo(receiveAddrL.snp.left)
            make.right.equalTo(receiveAddrL.snp.right)
            make.top.equalTo(receiveAddrL.snp.bottom).offset(15)
            make.height.equalTo(receiveAddrL.snp.height)
        }
        
        let feeRate = WhCommonInputRow(icon: "assert_icon_minerfee", title: "Fee Rate (BCH/KB)", "0")
        self.feeTF = feeRate.tf
        container.addSubview(feeRate)
        feeRate.snp.makeConstraints { (make) in
            make.left.equalTo(transferAmount.snp.left)
            make.right.equalTo(transferAmount.snp.right)
            make.top.equalTo(transferAmount.snp.bottom).offset(15)
            make.height.equalTo(transferAmount.snp.height)
        }
        
        let feeSelect = WhFeeRateView(textField: feeRate.tf, feeRates: nil)
        container.addSubview(feeSelect)
        feeSelect.snp.makeConstraints { (make) in
            make.left.equalTo(feeRate.snp.left)
            make.right.equalTo(feeRate.snp.right)
            make.top.equalTo(feeRate.snp.bottom).offset(10)
            make.height.equalTo(24)
        }
        feeRateView = feeSelect
        
        
        let sure = UIButton.commonSure(title: "Confirm")
        container.addSubview(sure)
        sure.snp.makeConstraints { (make) in
            make.left.equalTo(80)
            make.top.equalTo(feeSelect.snp.bottom).offset(80)
            make.centerX.equalToSuperview()
            make.height.equalTo(45)
            make.bottom.equalToSuperview().offset(-60)
        }
        sure.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        
    }
    
    
    private func usedKeys(awallet: HDWallet?) -> [PrivateKey] {
        var keys = [PrivateKey]()
        guard let wallet = awallet else {
            return []
        }
        // Receive key
        for index in 0..<(AppController.shared.externalIndex + 1) {
            if let key = try? wallet.privateKey(index: index) {
                keys.append(key)
            }
        }
        
        return keys
    }
    
    
    private func sendToSomeAddress(wallet:HDWallet?, amount: Int64, address: String, feeRate:String) {
        
        guard let signedTx = WhBitCoinCashTransactionHandler.sendToAddress(wallet: wallet, amount: amount, address: address, payMents: WhWalletManager.shared.utxos(), feeRate: feeRate) else {
            self.view.makeToast("transaction failed !")
            return
        }
        let sm = WhSocketManager.share()
        sm.publishTransition(withRawData: signedTx.serialized().hex)
        self.view.makeToast("transaction success!")
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
