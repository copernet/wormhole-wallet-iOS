//
/*******************************************************************************

        WhWalletRequestHandler.swift
        WHoleWallet
   
        Created by ffy on 2018/11/22
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import Foundation
import BitcoinKit
import Alamofire



public struct WhWalletRequestHandler {
    
    var payments = [Payment]()
    let address: String
    
    init(address:String) {
        self.address = address
    }
    
    func fetchDataAsync() {
        let sm = WhSocketManager.share()
        if sm.isConnected {
            self.fetchTranactionHistory()
            self.subScribeTransactionState()
            self.subScribeBlockHeaders()
        }else{
            let deadline = DispatchTime.now() + .seconds(1)
            DispatchQueue.global().asyncAfter(deadline: deadline) {
                self.fetchTranactionHistory()
                self.subScribeTransactionState()
                self.subScribeBlockHeaders()
            }
        }
        
    }
    
    
    func subScribeTransactionState() {
        let sm = WhSocketManager.share()
        sm.subScribeMessages(withBase58Address: address, maintain: true) { (subScribeObj:WhJSONRPCInterface) in
            
            self.fetchTranactionHistory()
            
            NotificationCenter.default.post(name: Notification.Name.AppController.transactionListChange, object: nil)
        }
        sm.doHeartSkip()
    }
    
    
    func fetchTranactionHistory()  {
        let sm = WhSocketManager.share()
        sm.getConfirmedHistory(withAddress: address) { (historyObj: WhJSONRPCInterface) in
            if let result = historyObj.result as? Array<Dictionary<String, Any>>{
                guard result.count > 0 else {
                    self.toNotificationSome()
                    return
                }
                //local exist transactions
                let utxos = WhWalletManager.shared.transactions()
                for (index,dic) in result.enumerated(){
                    let hash = dic["tx_hash"] as! String
                    let height = resPonsedInt(dictionary: dic, key: "height")!
                    //check does the transaction is exist
                    var exist = false
                    for payment in utxos {
                        if payment.txHash == hash {
                            exist = true
                            break
                        }
                    }
                    if exist {//verify next
                        continue
                    }
                    
                    //merkle tree verify
                    WhMerkleVerify.txMerkleVerify(txHash: hash, height: height, verified: { (txHash, txHeight, valid) in
                        if !valid {
                            return
                        }
                        sm.getTransactionWithAddress(txHash, withResponseBlock: { (transactionObj:WhJSONRPCInterface) in
                            if let hexString = transactionObj.result as? String {
                                let rawData = hexString.hexToData()!
                                let transaction = Transaction.deserialize(rawData)
                                
                                do {
                                    let blockStore = try! SQLiteBlockStore.default()
                                    let hashData = txHash.hexToData()!
                                    try blockStore.writeQueue.sync {
                                        try blockStore.addTransaction(transaction, hash: Data(hashData.reversed()))
                                        if(index==result.count-1){
                                            self.toNotificationSome()
                                        }
                                    }
                                }catch{
                                    print(error)
                                }
                            }
                        })
                    })
                }
                
            }
        }
    }
    
    func toNotificationSome()  {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name.AppController.transactionListChange, object: nil)
            NotificationCenter.default.post(name: Notification.Name.AppController.balanceChange, object: nil)
        }
    }
    
    
    
    func subScribeBlockHeaders()  {
        let sm = WhSocketManager.share()
        sm.subScribeHeadersResponse { (response) in
            
            guard let result = response.result as? Dictionary<String,Any> else {
                NotificationCenter.default.post(name: Notification.Name.AppController.serverHeaderDataInvalid, object: response.error)
                return
            }
   
            guard let height = resPonsedInt(dictionary: result, key: "height"), let hex = resPonsedString(dictionary: result, key: "hex") else {
                NotificationCenter.default.post(name: Notification.Name.AppController.serverHeaderDataInvalid, object: result)
                return
            }
            guard let data = hex.hexToData() else {
                return
            }
            guard data.count == 80 else {
                NotificationCenter.default.post(name: Notification.Name.AppController.serverHeaderDataInvalid, object: result)
                return
            }
            
            DLog(message: "localHeight: \(WhMerkleVerify.blockHeight)   newBlockHeight: \(height)")
            let header = BlockHeader.deserialize(data, height: UInt64(height))
            //fetch some blcok from server
            WhMerkleVerify.receivedNewBlockHeader(newHeader: header)
        }
    }
    
    
    func getChunkBlockHeaders(start: Int, count: Int = 2016, chunkHandle: @escaping (Int, Int, String?) -> Void) {
        let sm = WhSocketManager.share()
        sm.getChunkBlockHeaders(start, count: count) { (response) in
            guard let result = response.result as? Dictionary<String,Any> else {
                DLog(message: response.error)
                chunkHandle(start, 0, nil)
                return
            }
            DLog(message: "chunk headers")
            DLog(message: result)
            guard let hexs = resPonsedString(dictionary: result, key: "hex"), let number = resPonsedInt(dictionary: result, key: "count") else {
                chunkHandle(start, 0, nil)
                return
            }
            chunkHandle(start, number, hexs)
        }
    }
    
    
    /* current not use
    func fetchBalance() {
        let sm = WhSocketManager.share()
        sm.getBananceWithAddress(address) { (balanceObj:WhJSONRPCInterface) in
            let result = balanceObj.result as! Dictionary<String,UInt64>
            let balance = result["confirmed"]
            let decimal = Decimal(balance!)
            
            //notification balance change
        }
    }*/
    
}


extension URLRequest{
    
    static func postRequest(urlString: String, parameters: Any!) -> URLRequest? {
        guard let url = URL(string: urlString)  else {
            return nil
        }
        if let param = parameters {
            if !JSONSerialization.isValidJSONObject(param){
                return nil
            }
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters)
        return request
    }
}


struct WhHTTPRequestHandler {
    
    enum UnSignedPath:String {
        case feeRate = "transaction/fee"
        case burn = "getunsigned/68"
        case push = "transaction/push"
        case category = "category"
        case managed = "getunsigned/54"
        case fixed = "getunsigned/50"
        case crowdsale = "getunsigned/51"
        case unsigned = "getunsigned"
    }
    
    static func getFeeRate(complete: @escaping (Dictionary<String,Double>, [Double]) -> Void) {
        weak var mg = WhWalletManager.shared
        Alamofire.request(fullAddress(relaAddress: UnSignedPath.feeRate.rawValue), method: .post, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if response.result.isSuccess {
                let value  = response.result.value as! Dictionary<String,Any>
                if let result:Dictionary<String,Any> = resPonsedResult(dictionary: value) {
                    if result is Dictionary<String,Double> {
                        let dic = result as! Dictionary<String,Double>
                        let fast   = dic[TXFeeType.fast.rawValue] ?? 0
                        let normal = dic[TXFeeType.normal.rawValue] ?? 0
                        let slow   = dic[TXFeeType.slow.rawValue] ?? 0
                        mg?.fastFeeRate = fast
                        mg?.normalFeeRate = normal
                        mg?.slowFeeRate = slow
                        complete(dic, [fast,normal,slow])
                        return
                    }
                }
                
            }
            complete(Dictionary<String,Double>(),[Double]())
        }
    }
    
    static func unsignedOperate(reqCode:Int, parameters:Parameters, complete: @escaping (Dictionary<String,Any>)  -> Void) {
        let path = "\(UnSignedPath.unsigned.rawValue)/\(reqCode)"
        Alamofire.request(fullAddress(relaAddress: path), method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if response.result.isSuccess {
                let value  = response.result.value as! Dictionary<String,Any>
                if let result:Dictionary<String,Any> = resPonsedResult(dictionary: value) {
                    complete(result)
                    return
                }
            }
            complete(Dictionary<String,Any>())
        }
    }
    
    
    
    static func getCategories(complete: @escaping (Dictionary<String,Array<String>>) -> Void) {
        Alamofire.request(fullAddress(relaAddress: UnSignedPath.category.rawValue), method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if response.result.isSuccess {
                let value  = response.result.value as! Dictionary<String,Any>
                if let result:Dictionary<String,Any> = resPonsedResult(dictionary: value) {
                    if result is Dictionary<String,Array<String>> {
                        complete(result as! Dictionary<String,Array<String>>)
                        return
                    }
                }
                
            }
            complete(Dictionary<String,Array<String>>())
        }
    }
    
    
    
    
    static func createAsset(path:String, parameters:Parameters, complete: @escaping (Dictionary<String,Any>) -> Void) {
        
        Alamofire.request(fullAddress(relaAddress: path), method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if response.result.isSuccess {
                let value  = response.result.value as! Dictionary<String,Any>
                if let result:Dictionary<String,Any> = resPonsedResult(dictionary: value) {
                    complete(result)
                    return
                }
                
            }
            complete(Dictionary<String,Any>())
        }
    }
    
    static func pushSignedTx(rawData: String, complete:@escaping ()->Void = {}, failure: @escaping ()->Void = {}) {
        DLog(message: rawData)
        let parameters = ["signedTx": rawData]
        Alamofire.request(fullAddress(relaAddress: WhHTTPRequestHandler.UnSignedPath.push.rawValue), method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if response.result.isSuccess {
                let value  = response.result.value as! Dictionary<String,Any>
                DLog(message: value)
                complete()
                return
            }
            
            failure()
        }
        
    }
    
}


struct WormHoleSignUnSignedTxFlow {
    
    static func handleResult(result: Dictionary<String,Any>, complete:@escaping ()->Void = {}, failure: @escaping ()->Void = {}) {
        guard let unsigned_tx = resPonsedString(dictionary: result, key: "unsigned_tx") else {
            //to promopt user failed
            failure()
            return
        }
        guard let sign_data = resPonsedDicArray(dictionary: result, key: "sign_data") else {
            //to promopt user failed
            failure()
            return
        }
        DispatchQueue.main.async {
            self.signUnSignedTx(txRawData: unsigned_tx, inputs: sign_data, complete: complete, failure: failure)
        }
    }
    
    static func signUnSignedTx(txRawData:String, inputs:Array<Dictionary<String,Any>>, complete:@escaping ()->Void = {}, failure:@escaping ()->Void = {}) {
        
        let alert = WhInputAlertView.defaultAuthAlert(completeBlock: { (popupView, flag) in
            let popView = popupView as! WhInputAlertView
            //use password
            DLog(message: popView.password)
            //creaet a hd wallet
            let index = (WhWalletManager.shared.whWallet?.index)!
            let hdWallet = WhWalletManager.shared.getHDWallet(index: index, password: popView.password!)
            if let wallet = hdWallet {
                
                let unsignedTX = Transaction.deserialize(txRawData.hexToData()!)
                var outputs = [TransactionOutput]()
                guard inputs.count == unsignedTX.inputs.count else {
                    //prompt user
                    failure()
                    return
                }
                do {
                    let address = try wallet.receiveAddress()
                    for input in inputs {
                        let toPubKeyHash: Data = address.data
                        let lockingScriptTo = Script.buildPublicKeyHashOut(pubKeyHash: toPubKeyHash)
                        let value = resPonsedDouble(dictionary: input, key: "value")!
                        let amount = Int64(value * 100_000_000)
                        let toOutput = TransactionOutput(value: amount, lockingScript: lockingScriptTo)
                        outputs.append(toOutput)
                    }
                    
                    let singedTx = WhBitCoinCashTransactionHandler.signTx(transactionToSign: unsignedTX, outPuts: outputs, keys: wallet.defaultKeys())
                    WhHTTPRequestHandler.pushSignedTx(rawData: singedTx.serialized().hex, complete: complete, failure: failure)
                }catch {
                    DLog(message: error)
                    failure()
                }
            }
            
        })
        alert.show()
    }
    
}





struct WhBitCoinCashTransactionHandler {
    
    static public func sendToAddress(wallet:HDWallet?, amount: Int64, address: String, payMents:[Payment], _ usedKeys: [PrivateKey]? = nil, feeRate: String = "0") -> Transaction? {
        do {
            let toAddress: Address = try! AddressFactory.create(address)
            let changeAddress: Address = try wallet!.whChangeAddress()
            var pKeys = [PrivateKey]()
            if let keys = usedKeys {
                pKeys.append(contentsOf: keys)
            } else {
                if let aWallet = wallet {
                    pKeys.append(contentsOf: aWallet.defaultKeys())
                }else {
                    return nil
                }
                
            }
            var utxos: [UnspentTransaction] = []
            for p in payMents {
                let value = p.amount
                let lockScript = Script.buildPublicKeyHashOut(pubKeyHash: p.to.data)
                let txHash =  p.txid //Data(p.txid.reversed())
                let txIndex = UInt32(p.index)
                print(p.txid.hex, txIndex, lockScript.hex, value)
                
                let unspentOutput = TransactionOutput(value: value, lockingScript: lockScript)
                let unspentOutpoint = TransactionOutPoint(hash: txHash, index: txIndex)
                let utxo = UnspentTransaction(output: unspentOutput, outpoint: unspentOutpoint)
                utxos.append(utxo)
            }
            
            guard let unsignedTx = createUnsignedTx(toAddress: toAddress, amount: amount, changeAddress: changeAddress, utxos: utxos,feeRate: feeRate) else {
                return nil
            }
            
            let signedTx = signTx(unsignedTx: unsignedTx, keys: pKeys)
            return signedTx
            
        } catch  {
            DLog(message: error)
            return nil
        }
        
    }
    // TODO: select utxos and decide fee
    static public func selectTx(from utxos: [UnspentTransaction], amount: Int64, feeRate: String) -> (utxos: [UnspentTransaction], fee: Int64, needChange:Bool) {
        var sum: Int64   = 0
        var fee: Int64 = 0
        var selected = [UnspentTransaction]()
        let decimal = Int64(feeRate.toDouble() * 1_00_000_000)
        for (index,utxo) in utxos.enumerated() {
            selected.append(utxo)
            sum += utxo.output.value
            if sum > amount {
                fee = Transaction.estimateSize(inputCount: index+1, outPutCount: 2) * decimal / 1000
                if sum - amount >= fee {
                    break;
                }
            }
        }
        
        if sum - amount >= fee {
            return (selected, fee, true)
        }else {
            fee = Transaction.estimateSize(inputCount: utxos.count, outPutCount: 1) * decimal / 1000
            if sum - amount >= fee {
                return (selected, fee, false)
            }else {
                return ([UnspentTransaction](), 0 , false)
            }
        }
        
    }
    
    static public func createUnsignedTx(toAddress: Address, amount: Int64, changeAddress: Address, utxos: [UnspentTransaction],feeRate: String) -> UnsignedTransaction? {
        let (utxos, fee, needChange) = selectTx(from: utxos, amount: amount, feeRate: feeRate)
        if utxos.count < 0 {
            return nil
        }
        
        var outPuts = [TransactionOutput]()
        
        let totalAmount: Int64 = utxos.reduce(0) { $0 + $1.output.value }
        let toPubKeyHash: Data = toAddress.data
        let lockingScriptTo = Script.buildPublicKeyHashOut(pubKeyHash: toPubKeyHash)
        let toOutput = TransactionOutput(value: amount, lockingScript: lockingScriptTo)
        outPuts.append(toOutput)
        
        if needChange {
            let change: Int64 = totalAmount - amount - fee
            let changePubkeyHash: Data = changeAddress.data
            let lockingScriptChange = Script.buildPublicKeyHashOut(pubKeyHash: changePubkeyHash)
            let changeOutput = TransactionOutput(value: change, lockingScript: lockingScriptChange)
            outPuts.append(changeOutput)
        }
        
        // この後、signatureScriptやsequenceは更新される
        let unsignedInputs = utxos.map { TransactionInput(previousOutput: $0.outpoint, signatureScript: Data(), sequence: UInt32.max) }
        let tx = Transaction(version: 1, inputs: unsignedInputs, outputs: outPuts, lockTime: 0)
        return UnsignedTransaction(tx: tx, utxos: utxos)
    }
    
    
    
    static public func signTx(unsignedTx: UnsignedTransaction, keys: [PrivateKey]) -> Transaction {
        var inputsToSign = unsignedTx.tx.inputs
        var transactionToSign: Transaction {
            return Transaction(version: unsignedTx.tx.version, inputs: inputsToSign, outputs: unsignedTx.tx.outputs, lockTime: unsignedTx.tx.lockTime)
        }
        
        // Signing
        let hashType = SighashType.BCH.ALL
        for (i, utxo) in unsignedTx.utxos.enumerated() {
            let pubkeyHash: Data = Script.getPublicKeyHash(from: utxo.output.lockingScript)
            
            let keysOfUtxo: [PrivateKey] = keys.filter { $0.publicKey().pubkeyHash == pubkeyHash }
            guard let key = keysOfUtxo.first else {
                print("No keys to this txout : \(utxo.output.value)")
                continue
            }
            print("Value of signing txout : \(utxo.output.value)")
            
            
            let sighash: Data = transactionToSign.signatureHash(for: utxo.output, inputIndex: i, hashType: SighashType.BCH.ALL)
            let signature: Data = try! Crypto.sign(sighash, privateKey: key)
            let txin = inputsToSign[i]
            let pubkey = key.publicKey()
            
            let unlockingScript = Script.buildPublicKeyUnlockingScript(signature: signature, pubkey: pubkey, hashType: hashType)
            
            // TODO: sequenceの更新
            inputsToSign[i] = TransactionInput(previousOutput: txin.previousOutput, signatureScript: unlockingScript, sequence: txin.sequence)
        }
        
        return transactionToSign
    }
    
    
    
    
    //sign worm hole unsigned transaction
    static public func signTx(transactionToSign: Transaction, outPuts: [TransactionOutput], keys: [PrivateKey]) -> Transaction {
       
        var inputsToSign = transactionToSign.inputs
        var txToSign: Transaction {
            return Transaction(version: transactionToSign.version, inputs: inputsToSign, outputs: transactionToSign.outputs, lockTime: transactionToSign.lockTime)
        }
        
        // Signing
        let hashType = SighashType.BCH.ALL
        for (i, output) in outPuts.enumerated() {
            let pubkeyHash: Data = Script.getPublicKeyHash(from: output.lockingScript)
            
            let keysOfUtxo: [PrivateKey] = keys.filter { $0.publicKey().pubkeyHash == pubkeyHash }
            guard let key = keysOfUtxo.first else {
                print("No keys to this txout : \(output.value)")
                continue
            }
            print("Value of signing txout : \(output.value)")
            
            
            let sighash: Data = transactionToSign.signatureHash(for: output, inputIndex: i, hashType: SighashType.BCH.ALL)
            let signature: Data = try! Crypto.sign(sighash, privateKey: key)
            let txin = inputsToSign[i]
            let pubkey = key.publicKey()
            
            let unlockingScript = Script.buildPublicKeyUnlockingScript(signature: signature, pubkey: pubkey, hashType: hashType)
            
            // TODO: sequenceの更新
            let signedInput = TransactionInput(previousOutput: txin.previousOutput, signatureScript: unlockingScript, sequence: txin.sequence)
            
            inputsToSign[i] = signedInput
        }

        
        return txToSign
    }
    
    
    
    
}

