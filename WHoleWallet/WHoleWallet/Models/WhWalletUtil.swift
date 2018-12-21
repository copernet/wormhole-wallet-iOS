//
/*******************************************************************************

        WhWalletUtil.swift
        WHoleWallet
   
        Created by ffy on 2018/11/20
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import Foundation
import CryptoSwift
import BitcoinKit

//print
//message: T, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line
func DLog<T>(message: T, file : String = #file, method: String = #function, lineNum : Int = #line) {
    #if DEBUG
    let fileName = ((file as NSString).pathComponents.last!)
    print("\(fileName).\(method)[\(lineNum)]: \(message)")
    #endif
}

//verify some inputs
public func validAlphanumericAndNumber(str: String, minLen:UInt32, maxLen:UInt32) -> Bool {
    let regex =  "^[a-zA-Z0-9]{\(minLen),\(maxLen)}+$"
    let strPredicate = NSPredicate(format: "SELF MATCHES%@", regex)
    return strPredicate.evaluate(with: str)
}


public func validMnemonic(str: String) -> Bool {
//    let regex =  "^[a-zA-Z]{24}+$"
//    let strPredicate = NSPredicate(format: "SELF MATCHES%@", regex)
//   
//    if !strPredicate.evaluate(with: str){
//        return false
//    }
    let words = str.components(separatedBy: " ")
    return words.count == 12
}




//encrypt decrypt
public func generateCroyptNumber(bytesLen: Int) -> Data? {
    var data = Data(count: bytesLen)
    let status = data.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, bytesLen, $0) }
    guard status == errSecSuccess else {
        return nil;
    }
    return data
}

public func cryptoAESCBCEncryptData(iv:Data, data: Data, key:Data) -> Data? {
    do {
        let aes = try AES(key: Padding.zeroPadding.add(to: key.bytes, blockSize: AES.blockSize), blockMode: CBC(iv: iv.bytes))
        let encrypted = try aes.encrypt(data.bytes)
        return Data(bytes: encrypted, count: encrypted.count)
    } catch  {
        print(error)
        return nil
        
    }
}


public func cryptoAESCBCDecryptData(iv:Data, encryptedData: Data, key:Data) -> Data? {
    do {
        let aes = try AES(key: Padding.zeroPadding.add(to: key.bytes, blockSize: AES.blockSize), blockMode: CBC(iv: iv.bytes))
        let dencrypted = try aes.decrypt(encryptedData.bytes)
        return Data(bytes: dencrypted, count: dencrypted.count)
    } catch  {
        print(error)
        return nil
    }
}

//QRCode
public func generateVisualQRCode(address: String) -> UIImage? {
    let parameters: [String : Any] = [
        "inputMessage": address.data(using: .utf8)!,
        "inputCorrectionLevel": "L"
    ]
    let filter = CIFilter(name: "CIQRCodeGenerator", parameters: parameters)
    guard let outputImage = filter?.outputImage else {
        return nil
    }
    let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 6, y: 6))
    guard let cgImage = CIContext().createCGImage(scaledImage, from: scaledImage.extent) else {
        return nil
    }
    return UIImage(cgImage: cgImage)
}


//ui constant
func screenWidth() -> CGFloat {
    return UIScreen.main.bounds.width
}

func screenHeight() -> CGFloat {
    return UIScreen.main.bounds.height
}

func getACustomButton() -> UIButton {
    let button = UIButton(type: .custom)
    return button
}

//network address
func fullAddress(relaAddress: String) -> String{
    
    let base: String = WhNetWorkConfig.baseURL()

    var subString:String
    if base.hasSuffix("/") {
        subString = relaAddress.hasPrefix("/") ? relaAddress.substring(from: 1) : relaAddress
    } else {
        subString = relaAddress.hasPrefix("/") ? relaAddress : "/" + relaAddress
    }
    return base.appending(subString)
   
}
