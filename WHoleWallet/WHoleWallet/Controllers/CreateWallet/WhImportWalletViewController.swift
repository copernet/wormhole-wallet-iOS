//
/*******************************************************************************

        WhImportWalletViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/11/20
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import Foundation
import BitcoinKit


class WhImportWalletViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {
    
    var agree: Bool = true
    
    @IBOutlet weak var walletNameTF: WhCPTextField!
    
    @IBOutlet weak var mnemonicTextView: UITextView!
    
    @IBOutlet weak var passwordTF: WhCPTextField!
    
    @IBOutlet weak var repeatPassTF: WhCPTextField!
    
    @IBOutlet weak var readIcon: UIImageView!
    
    
    override func viewDidLoad() {
        self.mnemonicTextView.layer.borderWidth = 1
        self.mnemonicTextView.layer.borderColor = UIColor.gray.cgColor
    }
    
    
    func isValidInputs() -> Bool {
        guard walletNameTF.text != nil, passwordTF.text != nil,repeatPassTF.text != nil, mnemonicTextView.text != nil else {
            self.view!.makeToast("please enter required information !")
            return false
        }
        let valid = walletNameTF.text!.count>0 && validMnemonic(str: mnemonicTextView.text) && validAlphanumericAndNumber(str: passwordTF.text!, minLen: 8, maxLen: 32) && passwordTF.text == repeatPassTF.text!
        if !valid {
            self.view!.makeToast("please enter valid information !")
        }
        return valid
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func readAction(_ sender: Any) {
        if agree {
            self.readIcon.image = UIImage(named: "wallet_protocol_unread_icon")
        }else {
            self.readIcon.image = UIImage(named: "wallet_protocol_read_icon")
        }
        agree = !agree
    }
    
    @IBAction func serviceProtocol(_ sender: Any) {
        //show service and private protocol
        
    }
    
    @IBAction func walletImport(_ sender: Any) {
        if !agree {
            self.view!.makeToast("please read and agree private protocol")
            return
        }
        if isValidInputs() {
            let seed = Mnemonic.seed(mnemonic: mnemonicTextView.text.components(separatedBy: " "))
            DLog(message: seed)
            WhWalletManager.shared.importWhWallet(mnemonic:mnemonicTextView.text, seed: seed, name: walletNameTF.text!, password: passwordTF.text!, network: .testnet)
            if let nav = self.navigationController {
                nav.popToRootViewController(animated: true)
            }
        }
    }
    
}
