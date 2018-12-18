//
/*******************************************************************************

        WhMineViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/11/19
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import Foundation

class WhMineViewController: UITableViewController {
    
    @IBOutlet weak var walletNameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var notificationFlag: UIImageView!
    
    
    deinit {
        
    }
    
    @objc func walletChanged(notification: Notification) {
        walletNameLabel.text = WhWalletManager.shared.whWallet?.name
        addressLabel.text = WhWalletManager.shared.whWallet?.cashAddr
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(walletChanged(notification:)), name: Notification.Name.AppController.walletChanged, object: nil)
        walletNameLabel.text = WhWalletManager.shared.whWallet?.name
        addressLabel.text = WhWalletManager.shared.whWallet?.cashAddr
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let toViewController = segue.destination
        toViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.isNavigationBarHidden = false
    }
    
}
