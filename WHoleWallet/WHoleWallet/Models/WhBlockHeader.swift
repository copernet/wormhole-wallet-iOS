//
/*******************************************************************************

        WhBlockHeader.swift
        WHoleWallet
   
        Created by ffy on 2018/11/16
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/

import Foundation
import BitcoinKit

struct BlockHeader {
    /// Block version information, based upon the software version creating this block (note, this is signed)
    public let version: Int32
    /// The hash value of the previous block this particular block references
    public let prevBlock: Data
    /// The reference to a Merkle tree collection which is a hash of all transactions related to this block
    public let merkleRoot: Data
    /// A timestamp recording when this block was created (Limited to 2106!)
    public let timestamp: UInt32
    /// The calculated difficulty target being used for this block
    public let bits: UInt32
    /// The nonce used to generate this block… to allow variations of the header and compute different hashes
    public let nonce: UInt32
    
    //block height
    public var height: UInt64
    
    //block header hash string
    public var hashString : String {
        get {
            let hash = Crypto.sha256sha256(self.serialized())
            return hash.hexString()
        }
    }
    
    public var reverseHS : String {
        get {
            var hash = Crypto.sha256sha256(self.serialized())
            hash.reverse()
            return hash.hexString()
        }
    }
    
    public var prevHashString: String {
        get {
            return prevBlock.hexString()
        }
    }
    
    public func serialized() -> Data {
        var data = Data()
        data.append(version)
        data.append(prevBlock)
        data.append(merkleRoot)
        data.append(timestamp)
        data.append(bits)
        data.append(nonce)
        
        return data
    }

    public static func deserialize(_ data: Data, height: UInt64 = 0) -> BlockHeader {
        let inputStream = InputStream(data: data)
        inputStream.open()
        let header = deserialize(inputStream, height: height)
        inputStream.close()
        return header;
    }
    
    public static func deserialize(_ byteStream: InputStream, height: UInt64 = 0) -> BlockHeader {
        let version = byteStream.read(Int32.self)
        let prevBlock = byteStream.read(Data.self, count: 32)
        let merkleRoot = byteStream.read(Data.self, count: 32)
        let timestamp = byteStream.read(UInt32.self)
        let bits = byteStream.read(UInt32.self)
        let nonce = byteStream.read(UInt32.self)
        return BlockHeader(version: version, prevBlock: prevBlock, merkleRoot: merkleRoot, timestamp: timestamp, bits: bits, nonce: nonce, height: height)
    }
    
    
    
    public static func == (lhs: BlockHeader, rhs: BlockHeader) -> Bool {
        return lhs.serialized() == rhs.serialized()
    }
    
    public static func != (lhs: BlockHeader, rhs: BlockHeader) -> Bool {
        return !(lhs.serialized() == rhs.serialized())
    }
}


public struct WhMerkleVerify{
    
    static let ChunkMax: Int = 2016
    
    static func txMerkleVerify(txHash:String, height: Int, verified:@escaping (String, Int, Bool) ->Void)  {
        let sm = WhSocketManager.share()
        sm.getMerkleWithTransaction(txHash, andHeight: height) { (response) in
            DLog(message: response.result)
            guard let result = response.result as? Dictionary<String,Any> else {
                verified(txHash,height,false)
                return
            }
            guard let merkles:[String] = resPonsedArray(dictionary: result, key: "merkle"), let pos = resPonsedInt(dictionary: result, key: "pos") else {
                verified(txHash,height,false)
                return
            }
            
            let root = createMerkleRoot(merklePath:merkles , targetHash: txHash, position: pos)
            guard let header = getHeader(height: height) else {
                verified(txHash,height,false)
                return
            }
            
            guard txHash == header.hashString || root != header.merkleRoot else {
                verified(txHash,height,false)
                return
            }
            
            verified(txHash, height, true)
        }
    }
    
    
    static func createMerkleRoot(merklePath:[String],targetHash:String, position:Int) ->Data{
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
        return hashRoot
    }
    
    static private var catchPath: String {
        get {
            let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            return cachesDir.appendingPathComponent("blockchain_headers").path
        }
    }
    
    static var headerFilePath: String? {
        get {
            let path = catchPath
            let fm = FileManager.default
            if fm.fileExists(atPath: path) {
                return path
            }else {
                guard let fileURL = Bundle.main.url(forResource: "blockchain_headers", withExtension: nil) else {
                    return nil
                }
                do {
                    let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
                    DLog(message: data.count)
                    fm.createFile(atPath: path, contents: data, attributes: nil)
                    return path
                }catch{
                    DLog(message: error)
                    return nil
                }
            }
        }
    }
    
    static var headerCount:Int {
        get {
            guard let filePath = headerFilePath else{
                return 0
            }
            guard let fh = FileHandle(forReadingAtPath: filePath) else {
                return 0
            }
            fh.seekToEndOfFile()
            let count = fh.offsetInFile / 80
            fh.closeFile()
            return Int(count)
        }
    }
    
    static var blockHeight:Int {
        get {
            return headerCount - 1
        }
    }
    
    static func getHeader(height: Int) -> BlockHeader? {
        guard let filePath = headerFilePath else{
            return nil
        }
        
        guard let fh = FileHandle(forReadingAtPath: filePath) else {
            return nil
        }
        fh.seekToEndOfFile()
        let offSet = UInt64(80 * height)
        fh.seek(toFileOffset: offSet)
        let blockData = fh.readData(ofLength: 80)
        let header = BlockHeader.deserialize(blockData, height: UInt64(height))
        fh.closeFile()
        return header
    }
    
    static func lastHeader() -> BlockHeader? {
        guard let filePath = headerFilePath else{
            return nil
        }
        
        guard let fh = FileHandle(forReadingAtPath: filePath) else {
            return nil
        }
        fh.seekToEndOfFile()
        guard fh.offsetInFile >= 80 && fh.offsetInFile % 80 == 0 else {
            return nil
        }
        fh.seek(toFileOffset: fh.offsetInFile - 80)
        let blockData = fh.readData(ofLength: 80)
        let header = BlockHeader.deserialize(blockData, height: fh.offsetInFile / 80 - 1)
        fh.closeFile()
        return header
    }
    
    static func firstHeader() -> BlockHeader? {
        guard let filePath = headerFilePath else{
            return nil
        }
        
        guard let fh = FileHandle(forReadingAtPath: filePath) else {
            return nil
        }
        fh.seekToEndOfFile()
        guard fh.offsetInFile >= 80 && fh.offsetInFile % 80 == 0 else {
            return nil
        }
        let blockData = fh.readData(ofLength: 80)
        let header = BlockHeader.deserialize(blockData, height: fh.offsetInFile / 80 - 1)
        fh.closeFile()
        return header
    }
    
    static func getHeaderChunkEndWith(height:Int, count: Int = 147, txhash:String = "") -> Dictionary<String,BlockHeader>? {
        guard let filePath = headerFilePath else{
            return nil
        }
        guard let fh = FileHandle(forReadingAtPath: filePath) else {
            return nil
        }
        guard height > 0 else {
            return nil
        }
        var set = Dictionary<String,BlockHeader>()
        var offSet = UInt64(80 * (height - 1))
        fh.seek(toFileOffset: offSet)
        var index = 1
        while (fh.offsetInFile >= 80 && index <= count) {//2016
            autoreleasepool { () in
                let blockData = fh.readData(ofLength: 80)
                let header = BlockHeader.deserialize(blockData, height: UInt64(height - index))
                set[header.hashString] = header
                offSet -= 80 
                fh.seek(toFileOffset: offSet)
                index += 1
            }
            
        }
        fh.closeFile()
        return set
    }
    
    
    //get header from height - count  to height, not include header with .height of height
    static func getHeaderChunks(height:Int, count: Int = 147) -> Array<BlockHeader>? {
        guard let filePath = headerFilePath else{
            return nil
        }
        guard let fh = FileHandle(forReadingAtPath: filePath) else {
            return nil
        }
        guard height > 0 else {
            return nil
        }
        let maxHeight = blockHeight
        var (end,number): (Int,Int) = (0,0)
        if height > maxHeight {
            end = maxHeight
            let real = count - (height - maxHeight)
            if real < 0 {
                number = 0
            }else {
                number = real
            }
        }else {
            end = height
            number = count
        }
        
        var blocks = Array<BlockHeader>()
        var offSet = UInt64(80 * (end - 1))
        fh.seek(toFileOffset: offSet)
        var index = 0
        while (fh.offsetInFile >= 80 && index < number) {//2016
            autoreleasepool { () in
                let blockData = fh.readData(ofLength: 80)
                let header = BlockHeader.deserialize(blockData, height: UInt64(end - index))
                blocks.append(header)
                offSet -= 80
                fh.seek(toFileOffset: offSet)
                index += 1
            }
            
        }
        fh.closeFile()
        
        return blocks
    }
    
    //verify header's diffculity
    //select median header
    static func medianBlock(blockHeader:BlockHeader, blockSet:Dictionary<String,BlockHeader>) -> BlockHeader? {
        let b2 = blockHeader
        guard let b1 = blockSet[b2.prevHashString] else {
            return nil
        }
        guard let b0 = blockSet[b1.prevHashString] else {
            return nil
        }
        
        var b: BlockHeader
        if b2.timestamp >= b1.timestamp {
            if b1.timestamp >= b0.timestamp {
                b = b1
            }else {
                b = b2.timestamp > b0.timestamp ? b0 : b2
            }
        }else {
            if b1.timestamp <= b0.timestamp {
                b = b1
            }else {
                b = b0.timestamp > b2.timestamp ? b0 : b2
            }
        }
        
        return b
    }
    
    //verify diffculity
    static func verifyDiffculity(blockHeader:BlockHeader, blockSet:Dictionary<String,BlockHeader>) ->Bool {
        guard blockSet.count >= 147 else {
            return false
        }
        var first, last : BlockHeader?
        var b: BlockHeader
        var (sz ,size) : (Int,Int) = (0,0x1d)
        var bits: Int
        var (t, target, w, work) : (UInt64,UInt64,UInt64,UInt64) = (0,0,0,0)
        var timespan: UInt32
        if blockHeader.height >= 504032 {
            //for testnet special case
            if WhWalletManager.shared.network == .testnet {
                if blockHeader.bits == 486604799 {
                    return true
                }
            }
            
            last = blockSet[blockHeader.prevHashString]
            last = medianBlock(blockHeader: last!, blockSet: blockSet)
            
            var index = 0
            first = blockHeader
            while index <= 144 && first != nil {
                first = blockSet[first!.prevHashString]
                index += 1
            }
            if first == nil {
                return false
            }
            
            first = medianBlock(blockHeader: first!, blockSet: blockSet)
            
            guard  let start = first,let end = last else {
                return false
            }
            
            timespan = end.timestamp - start.timestamp
            
            if timespan > 288 * 10 * 60 {
                timespan = 288 * 10 * 60
            }
            if timespan < 72 * 10 * 60 {
                timespan = 72 * 10 * 60
            }
            
            b = end
            while b != start  {
                bits = Int(b.bits)
                sz = bits >> 24
                t  = UInt64(bits & 0x007fffff)
                w  =  t > 0 ? UInt64.max/t : UInt64.max
                while(sz < size) {
                    work >>= 8
                    size  -= 1
                }
                while(size < sz) {
                    w >>= 8
                    sz -= 1
                }
                while(work &+ w < w) {
                    w    >>= 8
                    work >>= 8
                    size -= 1
                }
                work += w
                
                guard let blk = blockSet[b.prevHashString] else {
                    break
                }
                b = blk
            }
            
            //work = work*10*60/timespan
            while (work > UInt64.max / (10 * 60)) {
                work >>= 8
                size -= 1
            }
            work = work * 10 * 60 / UInt64(timespan)
            
            //target = (2^256/work) - 1
            while (work > 0 && UInt64.max/work < 0x8000) {
                work  >>= 8
                size -= 1
            }
            target = work > 0 ? UInt64.max/work : UInt64.max
            
            while (size < 1 || target > 0x007fffff) {
                target >>= 8
                size  += 1
            }
            target = target | UInt64(size << 24)
            
            if (target > 0x1d00ffff) {
                target = 0x1d00ffff
            }
            
            let value = target &- UInt64(blockHeader.bits)
            if (value > 1){
                return false
            }
        }
        
        return true
    }
    
    
    enum HandleHeaderStatus {
        case fileempty
        case havegap
        case lackheaders
        case nbitsinvalid
        case fileerror
        case headerdataerror
        case insertsuccess
    }
    
    //insert new header
    static func insertNewBlockHeader(newHeader:BlockHeader, escapeGap: Bool = true) -> HandleHeaderStatus {
        guard lastHeader() != nil else {
            return .fileempty
        }
        
        let height = Int(newHeader.height)
        
        //when not escapte gap, if cannot link togeter return error
        if !escapeGap {
            if let last = lastHeader() {
                if last.height + 1 != height || newHeader.prevHashString != last.hashString {
                    return .havegap
                }
            }
        }
        
        //request chunk of headers
        guard let chunk = getHeaderChunkEndWith(height: height, txhash: newHeader.hashString) else {
            return .lackheaders
        }
        
        if !verifyDiffculity(blockHeader: newHeader, blockSet: chunk) {
            return .nbitsinvalid
        }
        
        return insertHeader(header: newHeader)
    }
    
    static func insertHeader(header: BlockHeader, index: UInt64 = UInt64.max) -> HandleHeaderStatus {
        let height = index == UInt64.max ? header.height : index
        guard let filePath = headerFilePath else{
            return .fileerror
        }
        guard let fh = FileHandle(forWritingAtPath: filePath) else {
            return .fileerror
        }
        
        guard header.height > 0 else {
            return .nbitsinvalid
        }
        
        let preHeader = getHeader(height: Int(height - 1))
        guard preHeader!.hashString == header.prevHashString else {
            return .havegap
        }
        
        fh.truncateFile(atOffset: height * 80)
        fh.write(header.serialized())
        fh.synchronizeFile()
        fh.closeFile()
        return .insertsuccess
    }
    
    enum FetchDirection {
        case toleft
        case toright
        case complete
    }
    
    
    static func insertHeadersDirectly(received:[BlockHeader]) -> Int {
        //insert to local storage
        var insertHeightMax: Int = -1
        var prevHeader: BlockHeader!
        for index_h in 0...received.count-1 {
            let pos = received.count - 1 - index_h
            let newHeader = received[pos]
            if index_h == 0 {
                prevHeader = WhMerkleVerify.getHeader(height: Int(newHeader.height - 1))
            }else {
                prevHeader = received[pos + 1]
            }
            if newHeader.prevHashString != prevHeader.hashString {
                insertHeightMax = Int(prevHeader.height)
                break
            }
            let status = WhMerkleVerify.insertNewBlockHeader(newHeader: newHeader)
            if status != .insertsuccess {
                insertHeightMax = Int(newHeader.height) - 1
                break
            }
        }
        
        if insertHeightMax == -1 {
            insertHeightMax = Int(received.first!.height)
        }
        return insertHeightMax
    }
    
    //handle server's  new or rollback  block header
    static func linkValidHeaders(start: Int, count: Int = 2016, received: [BlockHeader]) {
        WhWalletManager.shared.requestHandler?.getChunkBlockHeaders(start: start, count: count, chunkHandle: { (index, number, hexs) in
            guard let hexString = hexs else {
                NotificationCenter.default.post(name: Notification.Name.AppController.serverHeaderDataInvalid, object: index)
                return
            }
            
            //have fetch all latest block header
            if hexString == "" && number == 0 {//complete
                if received.count > 0 {
                    let sucHeightMax = insertHeadersDirectly(received: received)
                    DLog(message: "completeinsertSuccessHeight: \(sucHeightMax)")
                    NotificationCenter.default.post(name: Notification.Name.AppController.insertedNewHeaderSucc, object: sucHeightMax)
                    return
                }else {
                    DLog(message: "no more new header, lastest height is: \(lastHeader()!.height)")
                    NotificationCenter.default.post(name: Notification.Name.AppController.insertedNewHeaderSucc, object: lastHeader()!.height)
                }
            }else {
                let hexLength = hexString.count
                if (hexLength/160 != number || hexLength%160 != 0) {
                    NotificationCenter.default.post(name: Notification.Name.AppController.serverHeaderDataInvalid, object: index)
                    return
                }
                
                //add sort with height descending
                var blockHeaders = [BlockHeader]()
                for i in 0..<number {
                    let j = number - 1 - i
                    guard let hex = hexString.subString(from: j * 160, to: (j+1) * 160) else {
                        return
                    }
                    guard let data = hex.hexToData() else {
                        return
                    }
                    let header = BlockHeader.deserialize(data, height: UInt64(index + j))
                    if i == 0 {
                        if received.count > 0 {
                            if header.hashString == received.last?.prevHashString {
                                blockHeaders.append(header)
                            }else{
                                NotificationCenter.default.post(name: Notification.Name.AppController.serverHeaderDataInvalid, object: header.height)
                                return
                            }
                        }else{
                            blockHeaders.append(header)
                        }
                    } else {
                        if header.hashString == blockHeaders[i-1].prevHashString {
                            blockHeaders.append(header)
                        }else {
                            NotificationCenter.default.post(name: Notification.Name.AppController.serverHeaderDataInvalid, object: header.height)
                            return
                        }
                    }
                }
            
                // judge fetch direction
                let new_last  = blockHeaders.last!
                let new_first = blockHeaders.first!
                var direction: FetchDirection!
                if received.count > 0 {
                    if let last = received.last {
                        if new_first.height < last.height && last.prevHashString == new_first.hashString {//to left
                            direction = .toleft
                        }else if new_last.height > last.height && last.hashString == new_last.prevHashString {//to right
                            direction = .toright
                        }else {
                            //may be not
                            direction = .toright
                        }
                    }else {//to left
                        direction = .toleft
                    }
                }else {//to right
                    direction = .toright
                }
                
                //store all fetched headers
                var allValids = [BlockHeader]()

                if direction == .toleft {
                    guard let chunk = WhMerkleVerify.getHeaderChunks(height: index + number, count: number) else {
                        NotificationCenter.default.post(name: Notification.Name.AppController.localHeaderFileInvalid, object: nil)
                        return
                    }
                    
                    var findIndex: Int = Int.max
                    
                    
                    if new_last.prevHashString == chunk.first?.hashString {//can link directly
                        allValids += received
                        allValids += blockHeaders
                        
                        //insert to local storage
                        let letfInsertHeightMax =  insertHeadersDirectly(received: allValids)
                        DLog(message: "leftinsertSuccessHeight: \(letfInsertHeightMax)")
                        //start to right fetch
                        linkValidHeaders(start: letfInsertHeightMax + 1, count: number, received: [BlockHeader]())
                        return
                    }else {//else
                        let space = blockHeaders.count - chunk.count
                        for (idx, header) in chunk.enumerated() {
                            if header.serialized() == blockHeaders[idx + space].serialized() {
                                findIndex = idx + space
                                break;
                            }
                        }
                    }
                    
                    allValids += received
                    if findIndex != Int.max {//find link index
                        allValids += blockHeaders[0..<findIndex]
                        
                        //insert to local storage
                        let letfInsertHeightMax =  insertHeadersDirectly(received: allValids)
                        
                        DLog(message: "leftinsertSuccessHeight: \(letfInsertHeightMax)")
                        //start to right fetch
                        linkValidHeaders(start: letfInsertHeightMax + 1, count: number, received: [BlockHeader]())
                    }else {//continue left fetch
                        allValids += blockHeaders
                        linkValidHeaders(start: index - number, count: number, received: allValids)
                    }
                }else{//continue right fetch
                    allValids += blockHeaders
                    allValids += received
                    linkValidHeaders(start: Int(allValids.first!.height + 1), count: number, received: allValids)
                }
                
            }
         
        })
    }
    
    // handle received a new header
    static func receivedNewBlockHeader(newHeader:BlockHeader) {
        
        guard let last = WhMerkleVerify.lastHeader() else {
            //notificaton file empty may be wrong
            return
        }
       
        if last.height == newHeader.height && newHeader.hashString == last.hashString { //do not need handle
            return
        }else if newHeader.prevHashString == last.hashString {//insert directly
            let status = WhMerkleVerify.insertNewBlockHeader(newHeader: newHeader, escapeGap: false)
            if status != .insertsuccess {
                //notification failed
                NotificationCenter.default.post(name: Notification.Name.AppController.serverHeaderDataInvalid, object: newHeader.height)
            }else {
                //notification success
                DLog(message: "directlyinsertSuccessHeight: \(newHeader.height)")
                NotificationCenter.default.post(name: Notification.Name.AppController.insertedNewHeaderSucc, object: newHeader.height)
            }
            return
        }else {//start to fetch
            var (height, start, count, space): (Int, Int, Int, Int) = (Int(newHeader.height), 0, 0, 0)
            if newHeader.height > last.height {//normal fetch
                space = Int(newHeader.height - last.height)
                if space > ChunkMax {
                    start = height - WhMerkleVerify.ChunkMax
                    count = WhMerkleVerify.ChunkMax
                }else {
                    start = height - space + 1
                    count = space - 1
                }
                
                linkValidHeaders(start: start, count: count, received: [newHeader])
                
            }else {//handle rollback
                space = -Int(last.height - newHeader.height)
                if -space > ChunkMax {
                    start = height - WhMerkleVerify.ChunkMax
                    count = WhMerkleVerify.ChunkMax
                }else {
                    start = height + space
                    count = -space
                }
                
                linkValidHeaders(start: start, count: count, received: [newHeader])
            }
        }
        
//        switch status {
//        case .insertsuccess:
//            //notification insert success height
//             NotificationCenter.default.post(name: Notification.Name.AppController.insertedNewHeaderSucc, object: newHeader.height)
//            break
//        case .havegap:
//            // 7 * 144
//            linkValidHeaders(start: height, count: fetchCount, received: [newHeader])
//            break
//        case .nbitsinvalid, .headerdataerror:
//            NotificationCenter.default.post(name: Notification.Name.AppController.serverHeaderDataInvalid, object: newHeader.height)
//            break
//        default:
//            NotificationCenter.default.post(name: Notification.Name.AppController.insertedNewHeaderFail, object: newHeader.height)
//            break
//        }
        
    }
}
