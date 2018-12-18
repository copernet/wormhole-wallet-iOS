//
//  WhWallet.swift
//  WHoleWallet
//
//  Created by ffy on 2018/11/12.
//  Copyright © 2018年 wormhole. All rights reserved.
//

import Foundation
import BitcoinKit

extension HDWallet{
    
    public func receiveLegacyAddress() throws -> Address {
        let key = try publicKey(index: 0)
        return key.toLegacy()
    }
    
    public func whChangeAddress() throws ->Address{
        return try self.receiveAddress()
    }
    
    public func defaultKeys() -> [PrivateKey] {
        var keys = [PrivateKey]()
        if let key = try? self.privateKey(index: 0) {
            keys.append(key)
        }
        return keys
    }
    
}


