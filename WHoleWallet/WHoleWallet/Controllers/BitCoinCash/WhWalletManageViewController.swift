//
/*******************************************************************************

        WhWalletManageViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/11/21
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import Foundation
import MMPopupView


class WhWalletManageViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIScrollView!
    
    @IBOutlet weak var createWallet: UIButton!
    
    @IBOutlet weak var importWallet: UIButton!
    
    var allWallets: [WhWallet]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad() {
        if #available(iOS 11, *) {
            containerView.contentInsetAdjustmentBehavior = .never
        }else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        let wallets = WhWalletManager.shared.getAllWallets()
        self.allWallets = wallets
        if wallets.count > 0 {
            var preView : WhWalletButtonTwo!
            for (index,wallet) in wallets.enumerated() {
                let walletV = WhWalletButtonTwo(name: wallet.name, address: wallet.legacyAddr)
                walletV.iconImageView.addTarget(self, action: #selector(showAddress(sender:)), for:  .touchUpInside)
                walletV.tag = index
                walletV.bgButton.addTarget(self, action: #selector(changeWallet(sender:)), for: .touchUpInside)
                walletV.tag = Int.max - index
                self.containerView.addSubview(walletV)
                walletV.snp.makeConstraints { (make) in
                    if index == 0 {
                        make.top.equalTo(20)
                    }else {
                        make.top.equalTo(preView.snp.bottom).offset(15)
                    }
                    make.left.equalTo(20)
//                    make.right.equalToSuperview().offset(20)
                    make.width.equalTo(screenWidth() - 40)
                    make.height.equalTo(90)
                    preView = walletV
                }
            }
        }
        
        
        self.createWallet.backgroundColor = UIColor(hex: 0x3ED3A3)
        self.createWallet.layer.cornerRadius = 22
        
        self.importWallet.backgroundColor = UIColor(hex: 0x0C66FF)
        self.importWallet.layer.cornerRadius = 22
        
    }
    
    @objc func showAddress(sender: UIButton){
        let alert = MMAlertView(inputTitle: "请输入密码", detail:"密码", placeholder:"输入密码") { (text) in
            DLog(message: text)
        }
        alert?.show()
    }
    
    @objc func changeWallet(sender: UIButton){
        
        let index = Int.max - sender.tag
        
        guard index < allWallets.count else{
            return
        }
        
        if index == WhWalletManager.shared.whWallet?.index {
            self.navigationController?.popViewController(animated: true)
        }else {
            
        }
        
    }
    
    @IBAction func createWallet(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "CreateWallet", bundle: nil)
        let createVC = storyBoard.instantiateViewController(withIdentifier: "WhCreateWalletViewController")
        self.navigationController?.pushViewController(createVC, animated: true)
    }
    
    @IBAction func importWallet(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "CreateWallet", bundle: nil)
        let importVC = storyBoard.instantiateViewController(withIdentifier: "WhImportWalletViewController")
        self.navigationController?.pushViewController(importVC, animated: true)
    }
    
}
