//
/*******************************************************************************

        WhSeeMnemonicViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/12/5
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import BitcoinKit
import KeychainAccess

class WhSeeMnemonicViewController: UIViewController {

    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet weak var contentView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentView.isUserInteractionEnabled = false
        self.contentView.backgroundColor = UIColor.lightGray
        
        guard let whWallet = WhWalletManager.shared.whWallet else {
            return
        }
        let alert = WhInputAlertView.defaultAuthAlert { (pop, flag) in
            let popUp = pop as! WhInputAlertView
            let index = whWallet.index
            let (_, _, mnemonic) = WhWalletManager.shared.getSeed(index: index, password: popUp.password!)
            self.contentView.text = mnemonic
        }
        alert.show()

    }
    
    
    @IBAction func confirmAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
