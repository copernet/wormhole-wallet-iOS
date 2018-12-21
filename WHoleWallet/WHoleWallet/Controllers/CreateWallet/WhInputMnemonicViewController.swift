//
/*******************************************************************************

        WhInputMnemonicViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/11/20
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import Foundation
import BitcoinKit
import Toast_Swift

class WhInputMnemonicViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    var walletName: String!
    var password: String!
    var mnemonic: [String]!
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func sure(_ sender: Any) {
        guard password!.count >= 10 && validAllInuts() else {
            self.view!.makeToast("please enter required information !")
            return
        }
        
        let seed = Mnemonic.seed(mnemonic: mnemonic)
        WhWalletManager.shared.importWhWallet(mnemonic:mnemonic.joined(separator: " ") , seed: seed, name: walletName, password: password, network: .testnet)
        
        if WhWalletManager.shared.whWallet != nil {
            if let nav = self.navigationController {
                nav.popToRootViewController(animated: true)
            }
        }
    }
    
    
    func validAllInuts() -> Bool {
        if textView.text.count < 12 {
            return false
        }
        
        let inputs = textView.text.components(separatedBy: " ")
        guard inputs.count == 12 else {
            return false
        }
        for (index,value) in inputs.enumerated() {
            guard value.compare(mnemonic[index]) == .orderedSame else {
                return false
            }
        }
        return true
    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
}
