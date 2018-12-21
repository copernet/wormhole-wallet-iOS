//
//  WHoleWalletTests.swift
//  WHoleWalletTests
//
//  Created by ffy on 2018/11/12.
//  Copyright © 2018年 wormhole. All rights reserved.
//

import XCTest
@testable import WHoleWallet
import BitcoinKit
import CryptoSwift


class WHoleWalletTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testTransaction() {
        let hexString = "0200000001787b211c5e1ac119a4a14e6f54377e83c69ecb18e7659da336fbb54475df44720000000000ffffffff03001c4e0e000000001976a9140000000000000000000000000000000000376e4388ac00000000000000000a6a080877686300000044b7665627000000001976a914e6886aa39d558ecfa79981db118f238f8ca2308488ac00000000"
        let rawData   = hexString.hexToData()!
        let transaction = Transaction.deserialize(rawData)
        if transaction != nil {
            DLog(message: transaction)
        }
        
    }
    
    func testMerkel() {
        
        let merkels = [
        "83e84757a6d777cfd89055669fa4875e4ea46a88c1f357397177041717f06eb8",
        "8955b9853ee313265b63f0684e4d1b08ac96de0b8ce9365a8b4cfd2bd31ad60d",
        "d2c799dc9c3cbeeb543feea450f369687bb208bdfe48d20fa8ba497c30e4e9b0",
        "4affb5afe436c7fab2f9a68ac796b97ad1de0b27ae366eda15e7441643c7bf50",
        "766e22c64f447a0317850a95f9a83fff8a23da0616c79b3060b12672bddd0e00",
        "9865e1db65bc17a019df8ff9ad211b3d371ad85212b91406d8bc9ef9e1c149a1",
        "5ae69040aee09cbfcbea390ac6c4a27a6d68b25e1c8c427b5b4b74eb1e1f0c40"
        ]
        let pos = 67
        let targetHash = "ee674a67006a53beb3462287e234b55c34028f2bc3281e906c3e62c71e8dd4a2"
        let root = WhMerkleVerify.createMerkleRoot(merklePath: merkels, targetHash: targetHash, position: pos)
        print("merkel root: " + root.hexString())
        
        
//        let sm = WhSocketManager.share()
//        let height = 1267652
//        sm.getBlockHeader(withHeight: height, cpHeight: 0) { (header:WhJSONRPCInterface) in
//            print("header: \(header.result)")
//        }
    }
    
    /*
    func testCropSwiftAESECB()  {
        do {
            let plainText = "powerful platforms each offer unique capabilities and user experiences yet integrate tightly"
            let key = "0123456789"
            let aes = try AES(key: Padding.zeroPadding.add(to: key.bytes, blockSize: AES.blockSize), blockMode: ECB())
            
            //en
            let encrypted = try aes.encrypt(plainText.bytes)
            let encryptedBase64 = encrypted.toBase64()
            print("加密结果(base64)：\(encryptedBase64!)")
            
            //de
            let decrypted1 = try aes.decrypt(encrypted)
            print("解密结果1：\(String(data: Data(decrypted1), encoding: .utf8)!)")
            
            let decrypted2 = try encryptedBase64?.decryptBase64ToString(cipher: aes)
            print("解密结果2：\(decrypted2!)")
        } catch  {
            print(error)
        }
        
    }
    
    
    func testCropSeiftAESCBC() {
        do {
            let plainText = "powerful platforms each offer unique capabilities and user experiences yet integrate tightly"
            let key = "0123456789"
//            let iv  = "1234567890123456"
            if let iv = generateCroyptNumber(bytesLen: 16){
                print("iv: " + iv.toHexString())
                let aes = try cryptoAESCBCEncryptData(iv: iv, data: plainText.data(using: String.Encoding.utf8)!, key: key.data(using: .utf8)!)
                print("加密结果: " + aes!.hex)
                
                let des = try cryptoAESCBCDecryptData(iv: iv, encryptedData: aes!, key: key.data(using: .utf8)!)
                print("解密结果: " + des!.hex)
                
            }
           
            
        } catch  {
            print(error)
        }
    }
    
    
    func testCropSeiftAESCBCTwo() {
        
    }
 */
    
    func testKeyChain() {
        guard let filePath = Bundle.main.path(forResource: "blockchain_headers", ofType: nil) else{
            return
        }
        let readStream = InputStream(fileAtPath: filePath)
        
        if let reader = readStream {
            reader.open()
            DLog(message: "start: \(Date.timeIntervalSinceReferenceDate)")
            let index = 0
            while reader.hasBytesAvailable {
                if (index % 1000 == 0) {
                    DLog(message: "now: \(Date.timeIntervalSinceReferenceDate)")
                }
                    
                autoreleasepool { () in
//                    var readBuffer = [UInt8](repeating: 0, count: 80)
//                    let numberOfBytesRead = reader.read(&readBuffer, maxLength: 80)
//                    let data = Data(bytes: readBuffer, count: numberOfBytesRead)
//                    let header = BlockHeader.deserialize(data)
                    
                    let header = BlockHeader.deserialize(reader)
                    
                    print(header.version)
                    print(header.prevBlock.hexString())
                    print(header.merkleRoot.hexString())
                    print(header.timestamp)
                    print(header.bits)
                    print(header.nonce)
                    let sData = Crypto.sha256sha256(header.serialized())
                    //                sData.reverse()
                    print(sData.hexString())
                    print("***********************")
                }
                
                
            }
        }
        
    }
    
    
    func testNetworkAddress() {
        
    }
    

}
