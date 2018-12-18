//
/*******************************************************************************

        WhWalletManager.swift
        WHoleWallet
   
        Created by ffy on 2018/11/16
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/

//some constants

struct WhKeyChainkey {
    static let WhWalletMain  = "mainwallet"
    static let WhWalletCount = "walletcount"
    static let WhWalletNamePre = "wallet"
    static let WhWalletNetwork = "walletnetwork"
    static let WhWalletLegacyAddr = "walletlegacyaddress"
    static let WhWalletcashAddr = "walletbitcoincashaddress"
    
    static let WhWalletIva   = "walletiva"
    static let WhWalletHash  = "wallethash"
    
    static let WhWalletSeed  = "walletseed"
    
    static let WhWalletMnemonic    = "walletmnemonic"
}

struct WhWallet {
    let index: Int
    let name: String
    let networkScheme:String
    let legacyAddr: String
    let cashAddr: String
    let pHash:Data
    
    let hdWallet:HDWallet? = nil
    
    var addresses = [String]()
    
    init(index:Int, name:String, networkScheme:String, legacyAddr:String, cashAddr:String, pHash:Data) {
        self.index    = index
        self.name     = name
        self.networkScheme = networkScheme
        self.legacyAddr  = legacyAddr
        self.cashAddr    = cashAddr
        self.pHash = pHash
    }
}




import Foundation
import BitcoinKit
import KeychainAccess

enum TXFeeType:String {
    case fast = "Fast"
    case normal = "Normal"
    case slow = "Slow"
}

class WhWalletManager {
    
    static let shared:WhWalletManager = WhWalletManager()
    
    var network = Network.testnet
    
    var requestHandler: WhWalletRequestHandler?
    
    //wallet's manage
    private(set) var whWallet: WhWallet? {
        didSet {
            //store main wallet
            let keychain = Keychain()
            keychain[WhKeyChainkey.WhWalletMain] = String(whWallet!.index)
            afterWalletSet()
        }
    }
    
    func afterWalletSet() {
        NotificationCenter.default.post(name: Notification.Name.AppController.walletChanged, object: self)
        self.requestHandler = WhWalletRequestHandler(address: (whWallet?.legacyAddr)!)
        //if has been connected, fetch data
        if WhSocketManager.share().isConnected {
            self.requestHandler?.fetchDataAsync()
        }else {//start connect
            WhSocketManager.share().connect()
        }
    }
    
    var currentIndex: Int {
        get {
            let keychain = Keychain()
            if let current = keychain[WhKeyChainkey.WhWalletMain] {
                return Int(current)!
            }
            return Int.max
        }
    }
    
    var walletMaxIndex: Int {
        get {
            let keychain = Keychain()
            if let current = keychain[WhKeyChainkey.WhWalletCount] {
                return Int(current)!
            }
            return Int.max
        }
    }
    
    var fastFeeRate:  Double = 0
    var normalFeeRate:Double = 0
    var slowFeeRate:  Double = 0
    
    func feeTorType(feeType: TXFeeType) -> Double {
        switch feeType {
        case .fast:
            return fastFeeRate
        case .normal:
            return normalFeeRate
        case .slow:
            return slowFeeRate
        }
    }
    
    private init() {
        if let wallet = getCurrentWallet() {
            self.whWallet = wallet
            print("leg: " + wallet.legacyAddr);
            print("bch: " + wallet.cashAddr);
        }
        //add register
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reveivedBlockHeader(notification:)), name: Notification.Name.AppController.insertedNewHeaderSucc, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rpcSocketConnected(notification:)), name: Notification.Name.AppController.rpcSocketConnectSuccess, object: nil)
    }
    
    
    @objc func applicationDidBecomeActive(notification: Notification) {
        guard let _ = self.whWallet else {
            return
        }
        if !WhSocketManager.share().isConnected {
            WhSocketManager.share().connect()
        }
    }
    //notify socket connected
    @objc func rpcSocketConnected(notification: Notification){
        self.requestHandler?.fetchDataAsync()
    }
    //new block inserted
    @objc func reveivedBlockHeader(notification: Notification){
        self.requestHandler?.fetchTranactionHistory()
    }
    
    //get utxos
    func transactions() -> [Payment] {
        let blockStore = try! SQLiteBlockStore.default()
        var payments = [Payment]()
        if let usedAddresses = self.whWallet?.addresses  {
            for address in usedAddresses {
                let newPayments = try! blockStore.transactions(address: address)
                for p in newPayments where !payments.contains(p){
                    payments.append(p)
                }
            }
        }
        
        for payment in payments {
            print("\(payment.state == .received ? "received " : "send ")value: \(payment.amount)")
        }
        
        return payments
    }
    
    //get balance
    func updateBalance() -> Int64 {
        let blockStore = try! SQLiteBlockStore.default()
        
        var balance: Int64 = 0
        if let usedAddresses = self.whWallet?.addresses  {
            for address in usedAddresses {
                balance += try! blockStore.calculateBalance(address: address)
            }
        }
        return balance
    }
    
    func getBalanceString() -> String {
        let balance = updateBalance()
        let decimal = Decimal(balance)
        return "\(decimal / Decimal(100000000)) BCH"
    }
    
    func getBalancePure() -> String {
        let balance = updateBalance()
        let decimal = Decimal(balance)
        return "\(decimal / Decimal(100000000))"
    }
    
    
    //store private data and create a whwallet
    func importWhWallet(mnemonic:String, seed: Data, name:String, password:String, network: Network) {
        let keychain = Keychain()
        let index = walletMaxIndex != Int.max ? walletMaxIndex+1 : 0
        do {
            let hdWallet = HDWallet(seed: seed, network: network)
            let legacyAddress = try hdWallet.receiveAddress().base58
            let cashAddress   = try hdWallet.receiveAddress().cashaddr
            let hash = Crypto.sha256(password.data(using: .utf8)!)
            guard let iv = generateCroyptNumber(bytesLen: 16) else {
                return
            }
            guard let encrypted = cryptoAESCBCEncryptData(iv: iv, data: seed, key: hash[8...23]) else{
                return
            }
            guard let dmnemonic = mnemonic.data(using: .utf8) else {
                return
            }
            
            guard let enMnemonic = cryptoAESCBCEncryptData(iv: iv, data:dmnemonic , key: hash[8...23]) else{
                return
            }
            
            keychain[data: "\(WhKeyChainkey.WhWalletSeed)_\(index)"] = encrypted
            keychain[data: "\(WhKeyChainkey.WhWalletMnemonic)_\(index)"] = enMnemonic
            keychain[data: "\(WhKeyChainkey.WhWalletIva)_\(index)"]  = iv
            
            keychain[data: "\(WhKeyChainkey.WhWalletHash)_\(index)"] = Crypto.sha256(hash)
            keychain["\(WhKeyChainkey.WhWalletLegacyAddr)_\(index)"] = legacyAddress
            keychain["\(WhKeyChainkey.WhWalletcashAddr)_\(index)"] = cashAddress
            keychain["\(WhKeyChainkey.WhWalletNetwork)_\(index)"] = network.scheme
            keychain["\(WhKeyChainkey.WhWalletNamePre)_\(index)"] = name
            keychain[WhKeyChainkey.WhWalletCount] = String(index)
            
            var wallet = WhWallet(index: index, name: name, networkScheme: network.scheme, legacyAddr: legacyAddress, cashAddr: cashAddress,  pHash:hash)
            wallet.addresses = [legacyAddress]
            self.whWallet = wallet
      
        } catch  {
            print(error)
        }
        
    }
    
    
    func getCurrentWallet() -> WhWallet? {
        return getWallet(index: currentIndex)
    }
    
    //get a whwallet
    func getWallet(index: Int) -> WhWallet? {
        let keychain = Keychain()
        if let name = keychain["\(WhKeyChainkey.WhWalletNamePre)_\(index)"] {
            let legacy = keychain["\(WhKeyChainkey.WhWalletLegacyAddr)_\(index)"]
            let cash   = keychain["\(WhKeyChainkey.WhWalletcashAddr)_\(index)"]
            let scheme = keychain["\(WhKeyChainkey.WhWalletNetwork)_\(index)"]
            let hash  = keychain[data: "\(WhKeyChainkey.WhWalletHash)_\(index)"]
            if let legacyAddr = legacy, let cashAddr = cash, let nwScheme = scheme, let wHash = hash {
                var wallet = WhWallet(index: Int(index), name: name, networkScheme: nwScheme, legacyAddr:legacyAddr , cashAddr: cashAddr, pHash: wHash)
                wallet.addresses = [legacyAddr]
                return wallet
            }
        }
        return nil
    }
    
    func getAllWallets() -> [WhWallet] {
        let keychain = Keychain()
        var wallets = [WhWallet]()
        if let count = keychain[WhKeyChainkey.WhWalletCount] {
            if var wCount = Int(count) {
                while(wCount>=0){
                    if let wallet = getWallet(index: wCount){
                        wallets.append(wallet)
                    }
                    wCount -= 1
                }
            }
        }
        return wallets
    }
    
    
    func getCurrentAesIva() -> Data! {
        if currentIndex == Int.max {
            return nil
        }
        let keychain = Keychain()
        let iva = keychain[data: "\(WhKeyChainkey.WhWalletIva)_\(currentIndex)"]
        return iva
    }
    
    func getCurrentSeedHash() -> Data! {
        if currentIndex == Int.max {
            return nil
        }
        let keychain = Keychain()
        let hash = keychain[data: "\(WhKeyChainkey.WhWalletHash)_\(currentIndex)"]
        return hash
    }
    
    //get hd wallet
    func getHDWallet(index: Int, password: String) -> HDWallet? {
        let keychain = Keychain()
        let hash  = keychain[data: "\(WhKeyChainkey.WhWalletHash)_\(index)"]
        let pData = password.data(using: .utf8)
        guard password.count >= 10 && hash != nil && pData != nil else {
            return nil
        }
        guard hash == Crypto.sha256sha256(pData!) else {
            return nil
        }
        
        let seedPath = "\(WhKeyChainkey.WhWalletSeed)_\(index)"
        let netPath  = "\(WhKeyChainkey.WhWalletNetwork)_\(index)"
        let ivPath = "\(WhKeyChainkey.WhWalletIva)_\(index)"
        
        DLog(message: keychain[data: seedPath])
        DLog(message: keychain[netPath])
        DLog(message: keychain[data: ivPath])
        
        
        if let seed = keychain[data: "\(WhKeyChainkey.WhWalletSeed)_\(index)"], let scheme = keychain["\(WhKeyChainkey.WhWalletNetwork)_\(index)"], let iv = keychain[data: "\(WhKeyChainkey.WhWalletIva)_\(index)"]{
            let decrypted = cryptoAESCBCDecryptData(iv: iv, encryptedData: seed, key: Crypto.sha256(pData!)[8...23])
            var network: Network?
            if scheme == Network.mainnet.scheme{
                network = Network.mainnet
            }else if scheme == Network.testnet.scheme {
                network = Network.testnet
            }
            if let net = network, let dSeed = decrypted {
                return HDWallet(seed: dSeed, network: net)
            }
        }
        
        return nil
    }
    
    
    func getSeed(index: Int, password: String) -> (seed: Data?, iv: Data?, mnemonic: String?) {
        let keychain = Keychain()
        let hash  = keychain[data: "\(WhKeyChainkey.WhWalletHash)_\(index)"]
        let pData = password.data(using: .utf8)
        guard password.count >= 10 && hash != nil && pData != nil else {
            return (nil,nil,nil)
        }
        guard hash == Crypto.sha256sha256(pData!) else {
            return (nil,nil,nil)
        }
        
        let seedPath = "\(WhKeyChainkey.WhWalletSeed)_\(index)"
        let netPath  = "\(WhKeyChainkey.WhWalletNetwork)_\(index)"
        let ivPath = "\(WhKeyChainkey.WhWalletIva)_\(index)"
        
        DLog(message: keychain[data: seedPath])
        DLog(message: keychain[netPath])
        DLog(message: keychain[data: ivPath])
        
        
        if let seed = keychain[data: "\(WhKeyChainkey.WhWalletSeed)_\(index)"], let iv = keychain[data: "\(WhKeyChainkey.WhWalletIva)_\(index)"], let mnemonic = keychain[data: "\(WhKeyChainkey.WhWalletMnemonic)_\(index)"] {
            let decrypted  = cryptoAESCBCDecryptData(iv: iv, encryptedData: seed, key: Crypto.sha256(pData!)[8...23])
            let deMnemonic = cryptoAESCBCDecryptData(iv: iv, encryptedData: mnemonic, key: Crypto.sha256(pData!)[8...23])
            if  let dSeed = decrypted, let dMnemonic = deMnemonic {
                return (dSeed, iv, String(data: dMnemonic, encoding: .utf8))
            }
        }
        
        return (nil, nil, nil)
    }
    
    
    
    
    
    func removeWallet(index: Int) {
        let keychain = Keychain()
        do {
            try keychain.remove("\(WhKeyChainkey.WhWalletIva)_\(index)")
            try keychain.remove("\(WhKeyChainkey.WhWalletSeed)_\(index)")
            try keychain.remove("\(WhKeyChainkey.WhWalletMnemonic)_\(index)")
            try keychain.remove("\(WhKeyChainkey.WhWalletHash)_\(index)")
            try keychain.remove("\(WhKeyChainkey.WhWalletLegacyAddr)_\(index)")
            try keychain.remove("\(WhKeyChainkey.WhWalletcashAddr)_\(index)")
            try keychain.remove("\(WhKeyChainkey.WhWalletNetwork)_\(index)")
            try keychain.remove("\(WhKeyChainkey.WhWalletNamePre)_\(index)")
            try keychain.remove(WhKeyChainkey.WhWalletCount)
            try keychain.remove(WhKeyChainkey.WhWalletMain)
        } catch  {
            DLog(message: error)
        }
       
    }
    
}
