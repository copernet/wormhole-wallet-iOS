//
//  WhAdditionals.swift
//  WHoleWallet
//
//  Created by ffy on 2018/11/13.
//  Copyright © 2018年 wormhole. All rights reserved.
//

import Foundation
import BitcoinKit


extension Notification.Name {
    struct AppController {
        static let walletChanged  = Notification.Name("AppController.walletChanged")
        static let hdWalletCreated  = Notification.Name("AppController.hdWalletCreated")
        static let transactionListChange = Notification.Name("AppController.transactionListChange")
        static let balanceChange = Notification.Name("AppController.balanceChange")
        
        //about header
        static let blockHeadersChanged  = Notification.Name("AppController.blockHeadersChanged")
        static let insertedNewHeaderSucc = Notification.Name("AppController.insertedNewHeaderSucc")
        static let insertedNewHeaderFail = Notification.Name("AppController.insertedNewHeaderFail")
        static let localHeaderFileInvalid = Notification.Name("AppController.localHeaderFileInvalid")
        static let serverHeaderDataInvalid = Notification.Name("AppController.serverHeaderDataInvalid")
        
        //socket connected WhSocketConnectedSuccessKey
        static let rpcSocketConnectSuccess = Notification.Name("WhSocketConnectedSuccessKey")
    }
}

extension Data{
    func hexString() -> String {
        return self.withUnsafeBytes({ (bytes: UnsafePointer<UInt8>) -> String in
            let buffer = UnsafeBufferPointer(start: bytes, count: self.count)
            return buffer.map{String(format: "%02hhx", $0)}.reduce("", {$0 + $1})
        })
    }
    
}

extension String{
    //hex to data
    func hexToData() -> Data? {
        var data = Data(capacity: self.count/2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
    //to double
    public func toDouble(_ minDig: Int = 0, _ maxDig: Int = 9) -> Double {
        var doubleValue : Double = 0.0
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.minimumFractionDigits = minDig
        numberFormatter.maximumFractionDigits = maxDig
        let finalNumber = numberFormatter.number(from: self)
        doubleValue = (finalNumber?.doubleValue)!;
        return doubleValue
    }
    
    //substring
    public func substring(from index: Int) -> String {
        if self.count > index {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let subString = self[startIndex..<self.endIndex]
            return String(subString)
        } else {
            return self
        }
    }
    
    public func subString(from:Int, to:Int) ->String? {
        if from < 0 || to > self.count || from > to {
            return nil
        }
        let start = self.index(self.startIndex, offsetBy: from)
        let end   = self.index(self.startIndex, offsetBy: to)
        return String(self[start..<end])
    }
    
    
    func nsRange(from range: Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
    //is valid address
    public func isValidCashAddress(network: Network) ->Bool {
        do {
            let address = try Cashaddr(self)
            return address.network == network
        } catch  {
            DLog(message: error)
            return false
        }
    }
    
    
}

extension Double {
    
    public func toString(_ minDig: Int = 0, _ maxDig: Int = 20) -> String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits  = 1
        formatter.minimumFractionDigits = minDig
        formatter.maximumFractionDigits = maxDig
        return formatter.string(from: NSNumber(value: self))!
    }
}

extension SQLiteBlockStore {
    
    static var queueKey = "sqlite.write.queue.key"
    
    var writeQueue : DispatchQueue {
        get {
            guard let queue = objc_getAssociatedObject(self, &SQLiteBlockStore.queueKey) else {
                let aQueue = DispatchQueue(label: "fft.wallet.sqlite.writequeue")
                objc_setAssociatedObject(self, &SQLiteBlockStore.queueKey, aQueue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return aQueue
            }
            return queue as! DispatchQueue;
        }
    }

}




extension Transaction {
    static let TX_INPUT_SIZE  = 148
    static let TX_OUTPUT_SIZE = 34
    
    static func createMerkleRoot(merklePath:[String],targetHash:String, position:Int) ->String{
        var hashRoot = targetHash.hexToData()!
        hashRoot.reverse()
        for (i,hash) in merklePath.enumerated() {
            var hashData = hash.hexToData()!
            hashData.reverse()
            if (position >> i)&1 > 0 {
                hashRoot = Crypto.sha256sha256(hashData + hashRoot)
            }else{
                hashRoot = Crypto.sha256sha256(hashRoot + hashData)
            }
        }
        return hashRoot.hexString()
    }
    
    static func estimateSize(inputCount: Int, outPutCount: Int) -> Int64 {
        return  Int64( 8 + MemoryLayout.size(ofValue: inputCount) + MemoryLayout.size(ofValue: outPutCount) + Transaction.TX_INPUT_SIZE * inputCount +  Transaction.TX_OUTPUT_SIZE * outPutCount )
    }
    
}


extension Payment {
    var txHash: String {
        get {
            let reversed = txid.reversed()
            return Data(reversed).hexString()
        }
    }
}



extension Data {

    mutating func append(_ int32: Int32) {
        var int = int32
        var data = Data(bytes: &int, count: MemoryLayout<UInt32>.size)
        if data.count > 0 {
            self.append(data)
        }
    }
    
    
    mutating func append(_ uint32: UInt32) {
        var int = uint32
        var data = Data(bytes: &int, count: MemoryLayout<UInt32>.size)
        if data.count > 0 {
            self.append(data)
        }
    }
    
}

extension InputStream{

    public func read(_ type: Int.Type, _ littleEndian: Bool = true) -> Int {
        
        var readBuffer = [UInt8](repeating: 0, count: MemoryLayout<Int>.size)
        let numberOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
        let data = NSData(bytes: readBuffer, length: numberOfBytesRead)
        var result: Int = 0
        data.getBytes(&result, length: numberOfBytesRead)
        return result
    }
    
    public func read(_ type: Int32.Type, _ littleEndian: Bool = true) -> Int32 {
        
        var readBuffer = [UInt8](repeating: 0, count: MemoryLayout<Int32>.size)
        let numberOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
        let data = NSData(bytes: readBuffer, length: numberOfBytesRead)
        var result: Int32 = 0
        data.getBytes(&result, length: numberOfBytesRead)
        return result
    }
    
    public func read(_ type: Int64.Type, _ littleEndian: Bool = true) -> Int64 {
        
        var readBuffer = [UInt8](repeating: 0, count: MemoryLayout<Int64>.size)
        let numberOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
        let data = NSData(bytes: readBuffer, length: numberOfBytesRead)
        var result: Int64 = 0
        data.getBytes(&result, length: numberOfBytesRead)
        return result
    }
    
    public func read(_ type: Int16.Type, _ littleEndian: Bool = true) -> Int16 {
        
        var readBuffer = [UInt8](repeating: 0, count: MemoryLayout<Int16>.size)
        let numberOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
        let data = NSData(bytes: readBuffer, length: numberOfBytesRead)
        var result: Int16 = 0
        data.getBytes(&result, length: numberOfBytesRead)
        return result
    }
    
    public func read(_ type: Int8.Type, _ littleEndian: Bool = true) -> Int8 {
        
        var readBuffer = [UInt8](repeating: 0, count: MemoryLayout<Int8>.size)
        let numberOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
        let data = NSData(bytes: readBuffer, length: numberOfBytesRead)
        var result: Int8 = 0
        data.getBytes(&result, length: numberOfBytesRead)
        return result
    }
    
    
    public func read(_ type: UInt32.Type, _ littleEndian: Bool = true) -> UInt32 {
        var readBuffer = [UInt8](repeating: 0, count: MemoryLayout<UInt32>.size)
        let numberOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
        let data = NSData(bytes: readBuffer, length: numberOfBytesRead)
        var result: UInt32 = 0
        data.getBytes(&result, length: numberOfBytesRead)
        return result
    }
    
    public func read (_ type: Data.Type, count:Int, _ littleEndian: Bool = true) ->Data {
        var readBuffer = [UInt8](repeating: 0, count: count)
        let numberOfBytesRead = self.read(&readBuffer, maxLength: readBuffer.count)
        return Data(bytes: readBuffer, count: numberOfBytesRead)
    }
    
}





extension UIColor{
    /// hexColor
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let r: CGFloat = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let g: CGFloat = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let b: CGFloat = CGFloat((hex & 0x0000FF)) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    
    //create a image with pure color
    func toImage(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size);
        let context = UIGraphicsGetCurrentContext();
        context?.setFillColor(self.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!;
    }
    
    static var theme: UIColor {
        get {
            return UIColor(hex: 0x0C66FF)
        }
    }
    static var darkTextColor: UIColor {
        get {
            return UIColor(hex: 0x53627C)
        }
    }
    
    
}


extension UISearchBar {
    static var tapGesturekey = "wormhole.fft.uisearchbar.tap"
    weak var aTap : UITapGestureRecognizer? {
        get {
            guard let tap = objc_getAssociatedObject(self, &UISearchBar.tapGesturekey) else {
                return nil
            }
            return (tap as! UITapGestureRecognizer)
        }
        
        set {
            objc_setAssociatedObject(self, &UISearchBar.tapGesturekey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

