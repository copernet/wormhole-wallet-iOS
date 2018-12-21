//
/*******************************************************************************

        WhChangeIssuerViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/12/1
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import SnapKit
import Toast_Swift

class WhChangeIssuerViewController: UIViewController, UITextFieldDelegate {

    var assetInfo: Dictionary<String,Any>
    private var scrollView = UIScrollView(frame: CGRect.zero)
    var toTF: UITextField!
    var feeTF: UITextField!
    var feeRateView: WhFeeRateView!
    
    init(assetInfo:Dictionary<String,Any>) {
        self.assetInfo = assetInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        title = "Change Issuer"
        view.backgroundColor = UIColor.white
        if scrollView.superview == nil {
            view.addSubview(scrollView)
        }
        configView()
        
        fetchFeeRate()
    }
    
    func configView() {
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let container = UIView()
        scrollView.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        
        let userId = WhCommonInputRow(icon: "assert_icon_id", title: "ID", "")
        userId.tf.isUserInteractionEnabled = false
        userId.tf.text = resPonsedString(dictionary: assetInfo, key: "propertyid")
        container.addSubview(userId)
        userId.snp.makeConstraints { (make) in
            make.left.top.equalTo(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(WhCommonInputRow.defaultH).priority(500)
        }
        
        let changeIssuer = WhCommonInputRow(icon: "assert_icon_address", title: "Change Issuer", "Please Input The Address Your Want To Change")
        changeIssuer.tf.delegate = self
        container.addSubview(changeIssuer)
        changeIssuer.snp.makeConstraints { (make) in
            make.left.equalTo(userId.snp.left)
            make.right.equalTo(userId.snp.right)
            make.top.equalTo(userId.snp.bottom).offset(15)
            make.height.equalTo(userId.snp.height)
        }
        self.toTF = changeIssuer.tf
        
        let feeRate = WhCommonInputRow(icon: "assert_icon_minerfee", title: "Fee Rate (BCH/KB)", "0")
        feeRate.tf.isUserInteractionEnabled = false
        container.addSubview(feeRate)
        feeRate.snp.makeConstraints { (make) in
            make.left.equalTo(changeIssuer.snp.left)
            make.right.equalTo(changeIssuer.snp.right)
            make.top.equalTo(changeIssuer.snp.bottom).offset(15)
            make.height.equalTo(changeIssuer.snp.height)
        }
        self.feeTF = feeRate.tf
        
        let feeSelect = WhFeeRateView(textField: feeRate.tf, feeRates: nil)
        container.addSubview(feeSelect)
        feeSelect.snp.makeConstraints { (make) in
            make.left.equalTo(feeRate.snp.left)
            make.right.equalTo(feeRate.snp.right)
            make.top.equalTo(feeRate.snp.bottom).offset(10)
            make.height.equalTo(24)
        }
        feeRateView = feeSelect
        
        
        let promptIcon = UIImageView(image: UIImage(named: "wallet_create_reminder_icon"))
        container.addSubview(promptIcon)
        promptIcon.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
            make.top.equalTo(feeSelect.snp.bottom).offset(20)
            make.left.equalTo(20)
        }
        
        let promptTag = UILabel()
        promptTag.text = "Will Change Issuer, And Cannot Revoke"
        promptTag.textColor = UIColor(hex: 0x445571)
        promptTag.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        container.addSubview(promptTag)
        promptTag.snp.makeConstraints { (make) in
            make.left.equalTo(promptIcon.snp.right).offset(10)
            make.centerY.equalTo(promptIcon.snp.centerY)
        }
        
        
        let sure = UIButton.commonSure(title: "Confirm")
        container.addSubview(sure)
        sure.snp.makeConstraints { (make) in
            make.left.equalTo(80)
            make.top.equalTo(promptTag.snp.bottom).offset(80)
            make.centerX.equalToSuperview()
            make.height.equalTo(45)
            make.bottom.equalToSuperview().offset(-60)
        }
        sure.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func sureAction()  {
        let wallet = WhWalletManager.shared.whWallet!
        guard let fee = feeTF.text, let to = toTF.text, let pID = resPonsedString(dictionary: assetInfo, key: "propertyid") else {
            self.view!.makeToast("please enter required information !")
            return
        }
        
        if !to.isValidCashAddress(network: WhWalletManager.shared.network) {
            self.view!.makeToast("please enter valid address !")
        }
        
        let parameters = ["transaction_version": "0", "fee":fee, "transaction_from": wallet.cashAddr, "transaction_to    ": to, "currency_identifier": pID]
        WhHTTPRequestHandler.unsignedOperate(reqCode: 70, parameters: parameters) { (result) in
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
