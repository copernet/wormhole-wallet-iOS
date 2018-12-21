//
/*******************************************************************************

        WhFireViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/11/27
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import Alamofire
import BitcoinKit



class WhFireViewController: UIViewController,UITextFieldDelegate {

//    var feeIndex = 101
//    var feeDictionary = Dictionary<String,Double>()
//    var fee: Double?
    
    private var scrollView = UIScrollView(frame: CGRect.zero)
    var feeTF: UITextField!
    var amountTF: UITextField!
    var feeRateView: WhFeeRateView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
        
        WhHTTPRequestHandler.getFeeRate { (dictionary,fees) in
            if dictionary.count > 0 {
                DispatchQueue.main.async {
                    self.feeRateView.feeRates = fees
                }
            }
        }

        
    }
    
    
    func configViews()  {
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
        
        let burnAmount = WhCommonInputRow(icon: "main_icons_burn_money", title: "Burn Amount", "Please Input The Number Your Want To Burn", .numberPad )
        burnAmount.tf.delegate = self
        self.amountTF = burnAmount.tf
        
        container.addSubview(burnAmount)
        burnAmount.snp.makeConstraints { (make) in
            make.left.equalTo(addressView.snp.left)
            make.top.equalTo(addressView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
//            make.height.equalTo(WhCommonInputRow.defaultH).priority(500)
        }
        
        let feeRate = WhCommonInputRow(icon: "assert_icon_minerfee", title: "Fee Rate (BCH/KB)", "0")
        feeRate.tf.delegate = self
        feeRate.tf.isUserInteractionEnabled = false
        self.feeTF = feeRate.tf
        container.addSubview(feeRate)
        feeRate.snp.makeConstraints { (make) in
            make.left.equalTo(burnAmount.snp.left)
            make.right.equalTo(burnAmount.snp.right)
            make.top.equalTo(burnAmount.snp.bottom).offset(15)
            make.height.equalTo(burnAmount.snp.height)
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
    
    
    @objc func sureAction(_ sender: Any) {
        guard let amountText = amountTF!.text, let txFee = feeTF.text else {
            return
        }
        
        //input amount too large
        if Double(WhWalletManager.shared.getBalancePure())!.isLess(than: Double(amountText)!){
            self.view!.makeToast("invalid amount !")
            return
        }
        
        burn(amount: amountText, fee: txFee)
    }
    
    
    func burn(amount:String, fee:String) {
        let wallet = WhWalletManager.shared.whWallet!
        let parameters = ["transaction_version":0, "fee":fee, "transaction_from": wallet.cashAddr, "amount_for_burn":amount] as [String : Any]
        WhHTTPRequestHandler.unsignedOperate(reqCode: 68, parameters: parameters) { (result) in
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
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
