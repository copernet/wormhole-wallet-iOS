//
/*******************************************************************************

        WhCloseAssetViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/12/1
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import Toast_Swift

class WhCloseAssetViewController: UIViewController {

    var assetInfo: Dictionary<String,Any>
    private var scrollView = UIScrollView(frame: CGRect.zero)
    
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
        title = "Close Token"
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
        
        
        let feeRate = WhCommonInputRow(icon: "assert_icon_minerfee", title: "Fee Rate (BCH/KB)", "0")
        feeRate.tf.isUserInteractionEnabled = false
        feeTF = feeRate.tf
        container.addSubview(feeRate)
        feeRate.snp.makeConstraints { (make) in
            make.left.top.equalTo(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(WhCommonInputRow.defaultH).priority(500)
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
        
        
        let promptIcon = UIImageView(image: UIImage(named: "wallet_create_reminder_icon"))
        container.addSubview(promptIcon)
        promptIcon.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
            make.top.equalTo(feeSelect.snp.bottom).offset(20)
            make.left.equalTo(20)
        }
        
        let promptTag = UILabel()
        promptTag.text = "Will Close Asset, And Cannot Revoke"
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
            make.bottom.equalToSuperview().offset(-60).priority(500)
        }
        sure.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        
        
    }
    
    @objc func sureAction()  {
        let wallet = WhWalletManager.shared.whWallet!
        guard let fee = feeTF.text, let pID = resPonsedString(dictionary: assetInfo, key: "propertyid") else {
            self.view!.makeToast("please enter required information !")
            return
        }
       
        let parameters = ["transaction_version": "0", "fee":fee, "transaction_from": wallet.cashAddr, "currency_identifier": pID]
        WhHTTPRequestHandler.unsignedOperate(reqCode: 53, parameters: parameters) { (result) in
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
