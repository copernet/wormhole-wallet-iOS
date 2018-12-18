//
/*******************************************************************************

        WhCreateWalletViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/11/20
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import Foundation
import Toast_Swift

class WhCreateWalletViewController: UIViewController,UITextFieldDelegate {
    
    var agree = true
    
    @IBOutlet weak var walletNameTF: WhCPTextField!
    
    @IBOutlet weak var passwordTF: WhCPTextField!
    
    @IBOutlet weak var repeatPassTF: WhCPTextField!
    
    
    @IBOutlet weak var readIcon: UIImageView!
    override func viewDidLoad() {
        if let nav = self.navigationController {
            nav.setNavigationBarHidden(false, animated: false)
        }
        
        //config views
    }
    
    
    func isValidInputs() -> Bool {
        guard walletNameTF.text != nil,passwordTF.text != nil,repeatPassTF.text != nil else {
            self.view!.makeToast("please enter required information !")
            return false
        }
        if walletNameTF.text!.count>0 && validAlphanumericAndNumber(str: passwordTF.text!, minLen: 10, maxLen: 32) && passwordTF.text == repeatPassTF.text! {
            return true
        }else {
            self.view!.makeToast("please enter valid information !")
            return false
        }
        
    }
    
    
    
    @IBAction func serviceProtocol(_ sender: Any) {
    }
    
    
    @IBAction func createWallet(_ sender: Any) {
        if isValidInputs() {
            self.performSegue(withIdentifier: "WhBackupMnemonic", sender: nil)
        }
    }
    
    
    @IBAction func readAction(_ sender: Any) {
        if agree {
            self.readIcon.image = UIImage(named: "wallet_protocol_unread_icon")
        }else {
            self.readIcon.image = UIImage(named: "wallet_protocol_read_icon")
        }
        agree = !agree
    }
    
    
    //delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backup = segue.destination as! WhBackupMnemonicViewController
        backup.password = passwordTF.text
        backup.walletName = walletNameTF.text
    }
}
