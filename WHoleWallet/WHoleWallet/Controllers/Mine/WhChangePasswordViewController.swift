//
/*******************************************************************************

        WhChangePasswordViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/12/5
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import SnapKit
import KeychainAccess
import BitcoinKit

class WhChangePasswordViewController: UIViewController {


    var passwordTF: UITextField!
    var repeatPassTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //password
        let passwordRow = WhCommonInputRow(icon: "wallet_password_icon", title: "Set New Password", "Please Input Password")
        view.addSubview(passwordRow)
        passwordRow.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalTo(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(WhCommonInputRow.defaultH)
        }
        
        passwordTF = passwordRow.tf
        
        //repeat password
        let repeatPasswordRow = WhCommonInputRow(icon: "wallet_password_repeat_icon", title: "Repeat New Password", "Please Repeat Input New Password ")
        view.addSubview(repeatPasswordRow)
        repeatPasswordRow.snp.makeConstraints { (make) in
            make.top.equalTo(passwordRow.snp.bottom).offset(15)
            make.left.equalTo(passwordRow.snp.left)
            make.centerX.equalTo(passwordRow.snp.centerX)
            make.height.equalTo(passwordRow.snp.height)
        }
        repeatPassTF = repeatPasswordRow.tf
        
        
        //confirm
        let confirmButton = UIButton(type: .custom)
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.setTitleColor(UIColor.white, for: .normal)
        confirmButton.layer.cornerRadius = 22.5
        confirmButton.backgroundColor = UIColor(hex: 0x0C66FF)
        confirmButton.addTarget(self, action: #selector(confirmToChange), for: .touchUpInside)
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { (make) in
            make.left.equalTo(80)
            make.bottom.equalToSuperview().offset(-80)
            make.centerX.equalToSuperview()
            make.height.equalTo(45)
        }
    }
    

    @objc func confirmToChange()  {
        guard let newPassword = passwordTF.text else {
            return
        }
        guard let repeatPassword = repeatPassTF.text else {
            return
        }
        guard newPassword == repeatPassword else {
            return
        }
        guard let whWallet = WhWalletManager.shared.whWallet else {
            return
        }
        let alert = WhInputAlertView.defaultAuthAlert { (pop, flag) in
            let popUp = pop as! WhInputAlertView
            let index = whWallet.index
            let (seedData, ivData, _) = WhWalletManager.shared.getSeed(index: index, password: popUp.password!)
            guard let seed = seedData, let iv = ivData else {
                return
            }
            let hash = Crypto.sha256(newPassword.data(using: .utf8)!)
            
            let keychain = Keychain()
            //reset data and hash
            let seedPath = "\(WhKeyChainkey.WhWalletSeed)_\(index)"
            let hashPath = "\(WhKeyChainkey.WhWalletHash)_\(index)"
            guard let encrypted = cryptoAESCBCEncryptData(iv: iv, data: seed, key: hash[8...23]) else{
                return
            }
            keychain[data: seedPath] = encrypted
            keychain[data: hashPath] = Crypto.sha256(hash)
        }
        alert.show()
        
        
    }
}
