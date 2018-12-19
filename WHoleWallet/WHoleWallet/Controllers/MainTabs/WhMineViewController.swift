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
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func walletChanged(notification: Notification) {
        walletNameLabel.text = WhWalletManager.shared.whWallet?.name
        addressLabel.text = WhWalletManager.shared.whWallet?.cashAddr
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(walletChanged(notification:)), name: Notification.Name.AppController.walletChanged, object: nil)
        walletNameLabel.text = WhWalletManager.shared.whWallet?.name
        addressLabel.text = WhWalletManager.shared.whWallet?.cashAddr
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let toViewController = segue.destination
        toViewController.view.backgroundColor = UIColor.white
        toViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    
}
