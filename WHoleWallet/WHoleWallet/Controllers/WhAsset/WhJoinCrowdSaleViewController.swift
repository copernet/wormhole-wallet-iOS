//
/*******************************************************************************

        WhJoinCrowdSaleViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/12/6
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import SnapKit

class WhJoinCrowdSaleViewController: UIViewController, UITextFieldDelegate {

    var assetInfo: Dictionary<String,Any>?
    let scrollView = UIScrollView(frame: .zero)
    var feeTF: UITextField!
    var amoutTF: UITextField!
    var feeRateView: WhFeeRateView!
    
    
    func fetchFeeRate()  {
        WhHTTPRequestHandler.getFeeRate { (dictionary,fees) in
            if dictionary.count > 0 {
                DispatchQueue.main.async {
                    self.feeRateView.feeRates = fees
                }
            }
        }
    }
    
    
    func configViews()  {
        view.addSubview(scrollView)
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
        
        let rateTag = UILabel(frame: .zero)
        rateTag.textColor = UIColor(hex: 0x53627C)
        rateTag.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        rateTag.text = "rate: "
        container.addSubview(rateTag)
        rateTag.snp.makeConstraints { (make) in
            make.left.equalTo(addressView.snp.left)
            make.top.equalTo(addressView.snp.bottom).offset(10)
        }
        
        
        let rateLabel = UILabel(frame: .zero)
        rateLabel.textColor = UIColor(hex: 0x8A94A6)
        rateLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        rateLabel.text = " "
        if let info = assetInfo {
            rateLabel.text = resPonsedString(dictionary: info, key: "tokensperunit")
        }
        container.addSubview(rateLabel)
        rateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(rateTag.snp.right).offset(2)
            make.centerY.equalTo(rateTag.snp.centerY)
        }
        
        let amountRow = WhCommonInputRow(icon: "main_icon_dollar", title: "Amount (WHC)", "0.1WHC", .numberPad)
        amountRow.tf.delegate = self
        self.amoutTF = amountRow.tf
        container.addSubview(amountRow)
        amountRow.snp.makeConstraints { (make) in
            make.left.equalTo(rateTag.snp.left)
            make.top.equalTo(rateTag.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            //            make.height.equalTo(WhCommonInputRow.defaultH)
        }
        
        let feeRate = WhCommonInputRow(icon: "assert_icon_minerfee", title: "Fee Rate (BCH/KB)", "0")
        feeRate.tf.isUserInteractionEnabled = false
        self.feeTF = feeRate.tf
        container.addSubview(feeRate)
        feeRate.snp.makeConstraints { (make) in
            make.left.equalTo(amountRow.snp.left)
            make.right.equalTo(amountRow.snp.right)
            make.top.equalTo(amountRow.snp.bottom).offset(15)
            make.height.equalTo(amountRow.snp.height)
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
        
        
        //add join crowdsale button
        let confirmButton = UIButton(type: .custom)
        confirmButton.backgroundColor = UIColor(hex: 0x0C66FF)
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        confirmButton.layer.cornerRadius = 22.5
        confirmButton.layer.shadowColor = UIColor(hex: 0x0C66FF).cgColor
        confirmButton.layer.shadowOffset = CGSize(width: 5, height: 8)
        confirmButton.layer.shadowRadius = 22.5
        confirmButton.layer.shadowOpacity = 0.5;
        confirmButton.addTarget(self, action: #selector(joinCrowdSale), for: .touchUpInside)
        container.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { (make) in
            make.left.equalTo(80)
            make.centerX.equalToSuperview()
            make.top.equalTo(feeRate.snp.bottom).offset(80)
            make.height.equalTo(45)
            make.bottom.equalToSuperview().offset(-60)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        DLog(message: assetInfo)
        self.title = "Join CrowdSale"
        configViews()
        fetchFeeRate()
    }
    
    
    @objc func joinCrowdSale() {
        let wallet = WhWalletManager.shared.whWallet!
        guard let fee = feeTF.text,  let amount = amoutTF.text else {
            self.view!.makeToast("please enter required information !")
            return
        }
        
        let parameters = ["transaction_version": "0", "fee":fee, "transaction_from": wallet.cashAddr,"transaction_to": wallet.cashAddr, "amount_to_transfer": amount]
        WhHTTPRequestHandler.unsignedOperate(reqCode: 1, parameters: parameters) { (result) in
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
