//
/*******************************************************************************

        WhBackupMnemonicViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/11/20
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import Foundation
import BitcoinKit

class WhBackupMnemonicViewController: UIViewController {
    
    var walletName: String!
    var password: String?
    var mnemonic: [String]!
    
    @IBOutlet weak var mnemonicLabel: UILabel!
    override func viewDidLoad() {
        
//        let alert = WhCustomAlertView.createBackupMnemonicFirstAlert { (popView, flag) in
//            print("oo")
//        }
//        alert.show()
        
        //create mnemonic
        do {
            self.mnemonic = try Mnemonic.generate()
            self.mnemonicLabel.text = self.mnemonic.joined(separator: " ")
        } catch  {
            DLog(message: error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let input = segue.destination as! WhInputMnemonicViewController
        input.password = password
        input.mnemonic  = mnemonic
        input.walletName = walletName
    }
    
}
