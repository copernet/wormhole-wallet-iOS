//
//  HomeViewController.swift
//
//  Copyright © 2018 Kishikawa Katsumi
//  Copyright © 2018 BitcoinKit developers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import Dispatch
import BitcoinKit

class HomeViewController: UITableViewController, PeerGroupDelegate {
    var peerGroup: PeerGroup?
    var payments = [Payment]()

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var syncButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(walletChanged(notification:)), name: Notification.Name.AppController.walletChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(transactionsChange(notification:)), name: Notification.Name.AppController.transactionListChange, object: nil)
        
        
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true);
        print("box: " + paths[0]);
        
        guard let _ = AppController.shared.wallet else {
            return
        }
        
        //start fetch datas async
//        self.fetchDataAsync()
        
//        self.tests()
        
        DispatchQueue.global().async {
            self.testBlockHeaders()
        }
    }
    
    func tests()  {
        let sm = WhSocketManager.share()
        let height = 1267652
        sm.getBlockHeader(withHeight: height, cpHeight: 0) { (header:WhJSONRPCInterface) in
            print("header: \(header.result)")
        }
    }
    
    func testBlockHeaders()  {
        do {
            let datas = try Data(contentsOf: Bundle.main.url(forResource: "blockchain_headers", withExtension: nil)!, options: Data.ReadingOptions.dataReadingMapped)
            print(datas)
            
        } catch  {
            print(error)
        }
    }
    
    func subScribeTransactionState() {
        let sm = WhSocketManager.share()
        guard let wallet = AppController.shared.wallet else {
            return;
        }
        do {
            let legacyAddress = try wallet.receiveLegacyAddress()
            sm.subScribeMessages(withBase58Address: legacyAddress.base58, maintain: true) { (subScribeObj:WhJSONRPCInterface) in
                NotificationCenter.default.post(name: Notification.Name.AppController.transactionListChange, object: nil)
            }
        } catch  {
            print(error)
        }
        
        sm.doHeartSkip()
        
    }
    
    func fetchTranactionHistory()  {
        let sm = WhSocketManager.share()
        guard let wallet = AppController.shared.wallet else {
            return;
        }
        do {
            //mnS2geiaHgzxfa6GyXPQ1WhgEGbZyNuuGK
            let legacyAddress = try wallet.receiveLegacyAddress()
            sm.getConfirmedHistory(withAddress: legacyAddress.base58) { (historyObj: WhJSONRPCInterface) in
                if let result = historyObj.result as? Array<Dictionary<String, Any>>{
                    
                    let first = result.first!
                    
                    sm.getMerkleWithTransaction(first["tx_hash"] as! String, andHeight: first["height"] as! Int, responseBlock: { (obj:WhJSONRPCInterface) in
                        print("merkel: \(obj.result)")
                    })
                    
                    for dic in result{
                        let txHash = dic["tx_hash"] as! String
                        sm.getTransactionWithAddress(txHash, withResponseBlock: { (transactionObj:WhJSONRPCInterface) in
                            
                            if let hexString = transactionObj.result as? String {
                                
                                let rawData = hexString.hexToData()!
                                let transaction = Transaction.deserialize(rawData)
                                
                                do {
                                    let blockStore = try! SQLiteBlockStore.default()
                                    let hashData = txHash.hexToData()!
                                    try blockStore.writeQueue.sync {
                                        try blockStore.addTransaction(transaction, hash: Data(hashData.reversed()))
                                        DispatchQueue.main.async {
                                            self.updateBalance()
                                        }
                                        
                                    }
                                    
                                }catch{
                                    print(error)
                                }
                                
                            }
                        })
                    }
                    
                    
                }
            }
            
        } catch  {
            print(error);
        }
    }
    
    func fetchDataAsync() {
        let deadline = DispatchTime.now() + .seconds(4)
        DispatchQueue.global().asyncAfter(deadline: deadline) {
            self.fetchTranactionHistory()
            self.subScribeTransactionState()
        }
        
    }
    
    
    func fetchBalance() {
        let sm = WhSocketManager.share()
        guard let wallet = AppController.shared.wallet else {
            return;
        }
        do {
            let legacyAddress = try wallet.receiveLegacyAddress()
            sm.getBananceWithAddress(legacyAddress.base58) { (balanceObj:WhJSONRPCInterface) in
                let result = balanceObj.result as! Dictionary<String,UInt64>
//                let balance = Int64(String(describing: result["confirmed"]))
                let balance = result["confirmed"]
                let decimal = Decimal(balance!)
                self.balanceLabel.text = "\(decimal / Decimal(100000000)) BCH"
            }
        } catch  {
            print(error)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let _ = AppController.shared.wallet else {
            performSegue(withIdentifier: "createWallet", sender: self)
            return
        }
        
//        fetchBalance()
    }
    
    @IBAction func sync(_ sender: UIButton) {
        if let peerGroup = peerGroup {
            print("stop sync")
            peerGroup.stop()
            syncButton.setTitle("Sync", for: .normal)
        } else {
            print("start sync")
            let blockStore = try! SQLiteBlockStore.default()
            let blockChain = BlockChain(network: AppController.shared.network, blockStore: blockStore)

            peerGroup = PeerGroup(blockChain: blockChain)
            peerGroup?.delegate = self

            for address in usedAddresses() {
                if let publicKey = address.publicKey {
                    peerGroup?.addFilter(publicKey)
                }
                peerGroup?.addFilter(address.data)
            }

            peerGroup?.start()
            syncButton.setTitle("Stop", for: .normal)
        }
    }
    
    @objc
    func walletChanged(notification: Notification) {
        
        self.fetchDataAsync()
        tableView.reloadData()
    }
    
    @objc func transactionsChange(notification: Notification) {
        //fetch transactions
        fetchTranactionHistory()
        
        //fetch balcance
//        fetchBalance()
        
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Transactions"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath)

        let payment = payments[indexPath.row]
        let decimal = Decimal(payment.amount)
        let amountCoinValue = decimal / Decimal(100000000)
        let txid = payment.txid.hex
        cell.textLabel?.text = "\(amountCoinValue) BCH"
        cell.detailTextLabel?.text = txid
        print(txid, amountCoinValue, payment.from, payment.to)

        return cell
    }

    func peerGroupDidStop(_ peerGroup: PeerGroup) {
        peerGroup.delegate = nil
        self.peerGroup = nil
    }
    
    func peerGroupDidReceiveTransaction(_ peerGroup: PeerGroup) {
        updateBalance()
    }

    private func usedAddresses() -> [Address] {
        var addresses = [Address]()
        guard let wallet = AppController.shared.wallet else {
            return []
        }
        
//        if let address = try? wallet.receiveAddress() {
//            addresses.append(address)
//        }
        
        for index in 0..<(AppController.shared.externalIndex + 20) {
            if let address = try? wallet.receiveAddress(index: index) {
                addresses.append(address)
            }
        }
        
        for index in 0..<(AppController.shared.internalIndex + 20) {
            if let address = try? wallet.changeAddress(index: index) {
                addresses.append(address)
            }
        }
        
        return addresses
    }
    
    func transactions() -> [Payment] {
        let blockStore = try! SQLiteBlockStore.default()

        var payments = [Payment]()
        for address in usedAddresses() {
            let newPayments = try! blockStore.transactions(address: address.base58)
            for p in newPayments where !payments.contains(p){
                payments.append(p)
            }
        }
        return payments
    }

    private func updateBalance() {
        let blockStore = try! SQLiteBlockStore.default()

        var balance: Int64 = 0
        for address in usedAddresses() {
            balance += try! blockStore.calculateBalance(address: address.base58)
        }

        let decimal = Decimal(balance)
        balanceLabel.text = "\(decimal / Decimal(100000000)) BCH"

        payments = transactions()
        tableView.reloadData()
    }
    
}
