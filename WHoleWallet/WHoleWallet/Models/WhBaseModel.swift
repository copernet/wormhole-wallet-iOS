//
/*******************************************************************************

        WhBaseModel.swift
        WHoleWallet
   
        Created by ffy on 2018/11/23
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import Foundation

func resPonsedCode(dictionary: Dictionary<String,Any>) -> Int {
    if let aInt = resPonsedInt(dictionary: dictionary, key: "code"){
        return aInt
    }
    return 0
}

func resPonsedMessage(dictionary: Dictionary<String,Any>) -> String {
    if let str =  resPonsedString(dictionary: dictionary, key: "message") {
        return str
    }
    return "what?"
}

func resPonsedResult(dictionary: Dictionary<String,Any>) -> Dictionary<String,Any>? {

    return resPonsedDictionary(dictionary: dictionary, key: "result")
}

func resPonsedResult(dictionary: Dictionary<String,Any>) -> Array<Dictionary<String,Any>>? {

    return resPonsedDicArray(dictionary: dictionary, key: "result")
}

func resPonsedResult(dictionary: Dictionary<String,Any>) -> Array<String>? {

    return resPonsedArray(dictionary: dictionary, key: "result")
}

func resPonsedResult(dictionary: Dictionary<String,Any>) -> String? {

    return resPonsedString(dictionary: dictionary, key: "result")
}

func resPonsedResult(dictionary: Dictionary<String,Any>) -> Int? {
    
    return resPonsedInt(dictionary: dictionary, key: "result")
}

func resPonsedDictionary(dictionary: Dictionary<String,Any>, key: String) -> Dictionary<String,Any>? {
    let result = dictionary[key]
    if result is Dictionary<String,Any> {
        return result as? Dictionary<String,Any>
    }else{
        return nil
    }
}

func resPonsedDicArray(dictionary: Dictionary<String,Any>, key: String) -> Array<Dictionary<String,Any>>? {
    let result = dictionary[key]
    if result is Array<Dictionary<String,Any>> {
        return result as? Array<Dictionary<String,Any>>
    }else{
        return nil
    }
}

func resPonsedArray(dictionary: Dictionary<String,Any>, key: String) -> Array<String>? {
    let result = dictionary[key]
    if result is Array<String> {
        return result as? Array<String>
    }else{
        return nil
    }
}

func resPonsedString(dictionary: Dictionary<String,Any>, key:String) -> String? {
    let result = dictionary[key]
    if result is String {
        return result as? String
    }else if result is Int{
        return String(result as! Int)
    }else{
        return nil
    }
}

func resPonsedInt(dictionary: Dictionary<String,Any>, key:String) -> Int? {
    let result = dictionary[key]
    if result is Int {
        return result as? Int
    }else if result is String{
        return Int(result as! String)
    }
    else{
        return nil
    }
}

func resPonsedDouble(dictionary: Dictionary<String,Any>, key:String) -> Double? {
    let result = dictionary[key]
    if result is Double {
        return result as? Double
    }else if result is String{
        return Double(result as! String)
    }else{
        return nil
    }
}

func resPonsedInt64(dictionary: Dictionary<String,Any>, key:String) -> Int64? {
    let result = dictionary[key]
    if result is Int64 {
        return result as? Int64
    }else if result is String{
        return Int64(result as! String)
    }
    else{
        return nil
    }
}

func resPonsedBool(dictionary: Dictionary<String,Any>, key:String) -> Bool? {
    let result = dictionary[key]
    if result is Bool {
        return result as? Bool
    }else if result is String{
        return Bool(result as! String)
    }else if result is Int{
        let b = result as! Int
        if b >= 0 {
            return true
        } else {
            return false
        }
    }else {
        return nil
    }
}



func JSONModel<T>(_ type: T.Type, withKeyValues data:[String:Any]) throws -> T where T: Decodable {
    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
    let model = try JSONDecoder().decode(type, from: jsonData)
    return model
}

//class WhBaseModel: Codable {
//    var code: Int;
//    var message: String;
//    var result:
//
//
//}
