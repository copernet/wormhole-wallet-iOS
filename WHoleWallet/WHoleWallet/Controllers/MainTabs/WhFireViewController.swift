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

    
    @IBOutlet weak var sendAddress: UILabel!
    
    @IBOutlet weak var transferAmountTF: WhCPTextField!
    @IBOutlet weak var feeRateTF: WhCPTextField!
    @IBOutlet weak var fastBtn: UIButton!
    @IBOutlet weak var normalBtn: UIButton!
    @IBOutlet weak var slowBtn: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    var feeIndex = 101
    var feeDictionary = Dictionary<String,Double>()
    
    var fee: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.sendAddress.text = WhWalletManager.shared.whWallet?.cashAddr
        
        WhHTTPRequestHandler.getFeeRate { (dictionary,fees) in
            if dictionary.count > 0 {
                self.feeDictionary = dictionary
                self.updateFee()
            }
        }
        
    }
    
    @IBAction func changeFee(_ sender: Any) {
        
        let btn = sender as! UIButton
        if !btn.isSelected {
            btn.isSelected = true;
            
        }
        for index in 0...3 {
            let tag = 100 + index
            let view = self.containerView.viewWithTag(tag)
            if tag != btn.tag {
                view?.backgroundColor = UIColor(hex: 0x8A94A6)
            }else {
                view?.backgroundColor = UIColor(hex: 0x0C66FF)
            }
            
        }
        
        feeIndex = btn.tag
        
        updateFee()
    }
    
    func updateFee()  {
        var fee : Double!
        switch feeIndex {
        case 100:
            fee = feeDictionary["Fast"]
        case 101:
            fee = feeDictionary["Normal"]
        case 102:
            fee = feeDictionary["Slow"]
        default:
            fee = feeDictionary["Normal"]
        }
        
        self.feeRateTF.text = fee.toString()
    }
    
    @IBAction func sureAction(_ sender: Any) {
        guard let amountText = transferAmountTF!.text, let txFee = feeRateTF.text else {
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
