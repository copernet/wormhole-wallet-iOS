//
//  AppDelegate.swift
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
import BitcoinKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window?.backgroundColor = UIColor.white
        IQKeyboardManager.shared.enable = true
        
        return true
    }
}

func applicationWillTerminate(_ application: UIApplication) {
    WhSocketManager.share().close()
}



func testTransactionDes(){
    
    let hexString = "0200000003709942399c072bf76a46aad471fda2f4e2698cb3ca24f40d2c1b8bf563b8a4100000000000ffffffff709942399c072bf76a46aad471fda2f4e2698cb3ca24f40d2c1b8bf563b8a4100100000000ffffffff162a85b46c8443c4c04a659eea2bd1db489687d9d20d51b1b152356197955b8c0100000000ffffffff0300e1f505000000001976a9140000000000000000000000000000000000376e4388ac00000000000000000a6a08087768630000004444a1a824010000001976a914519e1d1acb0915a0a3a1de245989609be18d68d888ac00000000"
    let rawData   = hexString.hexToData()!
    let transaction = Transaction.deserialize(rawData)
    DLog(message: transaction.txInCount)
    DLog(message: transaction.txOutCount)
    
    for input in transaction.inputs {
        DLog(message: input.previousOutput.index)
        DLog(message: input.previousOutput.hash.hexString())
        DLog(message: input.sequence)
    }
    
    for output in transaction.outputs {
        DLog(message: output.lockingScript.hexString())
    }
}

func testDouble() {
    let aInt = 1
    DLog(message: Double(aInt))
    
    let aFloat: Float = 1 / 3
    let aDouble: Double = 1 / 3
    DLog(message: aFloat)
    DLog(message: aDouble)
    
    let PI = 314e-2
    DLog(message: PI)
}

func testdic() {
    let dic = ["a":1,"b":2,"c":3,"d":4]
    for key in dic.keys {
        DLog(message: key)
    }
}

func testFormate() {
    
    let formatter = NumberFormatter()
    
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 5
    print(formatter.string(from: 1.000)!)
    print(formatter.string(from: 1.001)!)
    print(formatter.string(from: 1.234)!)
    print(formatter.string(from: 314e-2)!)
    print(formatter.string(from: NSNumber(floatLiteral: 1.0001))!)
    print(formatter.string(from: NSNumber(value: 1.0001))!)
    var ad: Double = 1.00009
    print(formatter.string(from: NSNumber(value: ad))!)
    
    let strFromDouble = String(1.000)
    DLog(message: strFromDouble)
    
}

func testDoubleFrom(str: String) -> Double
{
    var doubleValue : Double = 0.0
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = NumberFormatter.Style.decimal
    let finalNumber = numberFormatter.number(from: str)
    doubleValue = (finalNumber?.doubleValue)!;
    DLog(message: doubleValue)
    return doubleValue
}

func testSlice()  {
    let str = "abc\nefg\n"
    let slices = str.components(separatedBy: "\n")
    for slice in slices {
        DLog(message: "slice: \(slice)")
    }
    
    let str2 = "abc"
    let slices2 = str2.components(separatedBy: "\n")
    for slice in slices2 {
        DLog(message: "slice2: \(slice)")
    }
    
}


func testBlockHeaders() {
    guard let filePath = Bundle.main.path(forResource: "blockchain_headers", ofType: nil) else{
        return
    }
    
    var blockCount: Int?
    autoreleasepool { () in
        do {
             let headerDatas = try Data(contentsOf: URL(fileURLWithPath: filePath), options: [])
            if headerDatas.count % 80 != 0 {
                return
            }else {
                blockCount = Int(headerDatas.count / 80)
                if blockCount! < 100 {
                    return
                }
            }
        } catch  {
            DLog(message: error)
            return
        }
    }
    
    DLog(message: blockCount!)
    
    guard let fh = FileHandle(forReadingAtPath: filePath) else {
        return
    }
    let endOffset = fh.seekToEndOfFile()
    DLog(message: endOffset)
    DLog(message: fh.offsetInFile)
    fh.seek(toFileOffset: fh.offsetInFile - 80)

    while fh.offsetInFile >= UInt64(80) {
        autoreleasepool { () in
            let blockData = fh.readData(ofLength: 80)
            fh.seek(toFileOffset: fh.offsetInFile - 2 * 80)
            
            let header = BlockHeader.deserialize(blockData)
//            print(header.version)
            print(header.hashString)
            print(header.prevHashString)
//            print(header.merkleRoot.hexString())
//            print(header.timestamp)
//            print(header.bits)
//            print(header.nonce)
            
            print("***********************")
            
        }
    }
    fh.closeFile()
    
    
    
//    let readStream = InputStream(fileAtPath: filePath)
//
//    if let reader = readStream {
//        reader.open()
//        DLog(message: "start: \(Date.timeIntervalSinceReferenceDate)")
//        var index = 0
//        while reader.hasBytesAvailable {
//            if (index % 1000 == 0) {
//                DLog(message: "now: \(Date.timeIntervalSinceReferenceDate)")
//            }
//
//            autoreleasepool { () in
//                //                    var readBuffer = [UInt8](repeating: 0, count: 80)
//                //                    let numberOfBytesRead = reader.read(&readBuffer, maxLength: 80)
//                //                    let data = Data(bytes: readBuffer, count: numberOfBytesRead)
//                //                    let header = BlockHeader.deserialize(data)
//
//                let header = BlockHeader.deserialize(reader)
//
//                print(header.version)
//                print(header.prevBlock.hexString())
//                print(header.merkleRoot.hexString())
//                print(header.timestamp)
//                print(header.bits)
//                print(header.nonce)
//                let sData = Crypto.sha256sha256(header.serialized())
//                //                sData.reverse()
//                print(sData.hexString())
//                print("***********************")
//
//                index += 1
//
//            }
//
//        }
//    }
    
    
    
}






func testTransactionSize() {
    let txt = "0200000024d511b76834cddaae26a0c3bc7b23e0395ab0264b1610dedb81445a1abee2d032010000006b483045022100dae4f7fd3efb849f94c715f93f5d6fe04dfc15b9f1e8a7d3bb30b8a93d3a3494022038b6cbece747eff291efc00a568fd5072e77fd587be4c6b024080aae7fa879d641210247fdc6efe8768fa8e05dfe5af18dd28b4745f49f15b7bbdb0d46078e6dfde624feffffff2b3e1c2829e0ce81bad9db3a5bc54cd7f84636257d549d0f0b0352ae71912b4c000000006b48304502210086329b5f8cb74a526142c1ceceb918b293d28113a03d17f93fe2ddc9164bba0002204cad34c0d40dda2f656f4230d374b3b4adc16467ab660a27af7457a0748b91f74121022b96086a5018d362509e97c1391834c1376c779e161f5bb90399cb9227e9a7ccfeffffffc71259ce0c1171e48cbad9a5e6e3fdefcccabf16028abbe5d706570b4c3c17e4000000006b483045022100f0d9a575e25f0275fbd05be5febce6a9d292649924e5b87a0f72a7b319b7e1d8022055722f602b1c6ffe13674d177bf722aba38a47a86f4c5ccfe9662977b895ed46412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffff32ba52883c4d821bc166e08e1657e1d19d694fa44ca9aef3958303d5a43bdaaf000000006a473044022075b73fb251bca68ca83ba60ccb641593ebdb5713f942d810d867c0400487951d02207ecf1a6d9c91debf66f57407f4588c6492692d9ceaa7bcaece07a97357037be7412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffffa8db83321d8c33f25c9097bbad2fb2d5c0aa033f6b8691869d200ccccb5539a9000000006a473044022003c67e0ecca4068b4fc32ffe4a04dac7d717652fca19ace34aba099a9565574702202ff31ae263b56ddad3b482802b4b624001d997090c2ccd7c3412c6d1213080f1412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffff5846e7520867443540306c43d975aab453550f1e201bc1f6d6b4e034a0c7753a000000006b483045022100b1568cfc25fc43cff63a9290fa1496c94648ef770561f3d886d365b989c2daac02206c45b1ee79e7e3935df64f11b8ec039a3a7bda07b5e1038b83efeaace1c22f21412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffffb99d7cdc9587d29550cda8d81182d19eb644adc893833957d9a8dd8dbc141a60000000006a473044022060ec610e61b538cb6c0c37293260cae3bf2952b73895bfbb7a4ed43508dc4ddc02203f8af2f9751c6f5e346ba6629018f80c3da73291ab321ac60705f8288a54cf96412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffff36a590db20e7a6ca4a196029a729c39f1c6e551705314df8fe514a783aa11d9c000000006b483045022100f7c974d0128f5b2e86f184bb07604c8b0fb2bd0fea5305b0dea8999d8a539d42022028761824fb29ce1b164ad63426612cb7f78cd19ceaf985847cc00a22cdbfdd90412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffff9690d933a00790db4f637e824fa32e066d15aed8b3e559aed747226298bcaee4000000006a47304402206eb14305b8b239b24d2b626cbdacf259be21678938eb7b34704ba712df3becd302200ecbc08e78a20c94bffee1699d4d1b85c129f3ab0a3b21ce12d8ac11b1ab1d7b412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffff0d6c4085f4a8fa2620f670b46cb1ceb1e7e32ae6d054b2128acfd532df623a05000000006a47304402200cc6414db15f126af15ca040c99636a8ea72c955bfe8d27c654e926a8a08028102206930495d3474e79269355c7d798e47f0a61dafb31be560bbcedcfd3e6a0859fb412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffffe44683b6453714ae42dd5d4f261b5d9e7d045c97c545b3cb34c342b44d94bf94000000006b48304502210085e765ae2b64fbe4c2982f5fd74fd54a9a16e3b068711419b0ae6e38c77f0412022065c2fe3fef6773f9a1dd2bc7f093b02103af845cac1ad335e312d3d229380833412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffffd73329bd302149fd861b008e4f093eddf78002881ca7dd7c8d653ed39ece5b26000000006b483045022100e8c0a3453233dbf7dff2647d541a1afc3844c147f2d2fb9c12356693a4554ca90220157d8536f112167865dff1881dbba25aa0485422777be1dc309ca4865d737410412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afefffffffcbbd70fdd249ffe7fb0d5ccb10023e8cd0ee148f992916db5e50df4891f9cb6000000006a47304402207eca66f70008c2850d85b6ffbfa9c92344edc1766c71e0a78bde3516108109ad02202930065b6b88d5ddc43e0f4cf8075c0374f0ebd0fc65398b984888e8df423597412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffff165b2bbb789ee67f180c414d484b4c186e833488eb98075b21fd954033cfc226000000006b483045022100bf587cdff1435b32180af5da7f44d5017058cdd5dd796f3be7b3e48a000da4dc02207bae74ecd70790248a7e2e6c479b316633cbfee212f3db86253db979e0405f7f412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffffeafecd479cbe200d0d0edf523b246aafcba9331b2be4b6fa1468c8dea9d5ed98000000006b483045022100b4bd89bd68073bd0921e62e5fab3b76a3f39d90f461eee9fd8fdf45d0a5720ac02200aa31de86af94c50f43bc2422b3e8dbafc2ce8820f912709fad36bd065e679b5412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffffd7145fd1042cb0ceed749551aea614a758060bac4980673c0ab338b7815b2597000000006a4730440220359aa0579eeb33820f648e56be071d5d20a2bd35dc0de623481b086ffc7c03d7022041436591b9988e353e6c95d976a12211756915ead193c326d4708658eacdf646412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffffd93c222cc1008daf97ead087e1e51a89bf5aa3aebe3cc0fcb75b46589253dce0000000006a47304402200c588de01bb429492d0a1c4cd33bb6008a8950f6126eebe672c1e0875c51c8bf02207c1d65a0673581ef8a2abe125a47af9a37d1c3352377ca4bb2624198cb4145cf412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffff235cff8b707799e05acd7ba832594b87dac8a728cb715fe599860e7db4f44a89000000006b483045022100bbe4420ceeabb420d991d81c1c6b3725934c39b9a608ac65cc45200a8a20cca70220612e6f4f9846b431c4d2bf189f04fcc72bcc6cff104e1afdd56419b4381251c0412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffffef5615f9c8efa7d97f0669a7f1c4409a0b36afc1b0038517077f8bc210097fd3000000006a473044022031ef710874efaee1825a8ca7805ad0ce75056367c0ffaa6e6f6b69596017cc1602204997968aea42eaeae55db7c9a14972ab608e1058feac62818eedd82725cd96f4412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffffeafb626aa69f7e3c0b1fc3168850dace96269601d93122cc19d738eaae3688ed000000006b4830450221009efc74a469868e1ad71f11f7c55e09b8ee96d6f84be22fe41b4e57c8d2bf8ba902205923306d19262ced4b08d80dec9cf9742142f79c71098de6524d772162233b07412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffffd76ce362e553237232d9dedd8c6ca40d22dccb415b2b453e89c2ab518390b892000000006a473044022045676b09d9966589021756de6a42de11f37e4710ad01fb09c89ef6561196e3c2022045a72248e65521867f312c7136d209b8f4abd0d4b7f9fb9cb52fc7c320e98795412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffff19d9c2fce04ee7105fa31a4afbd4cda43372670fd9da3bf69c94c1c46997c97a000000006a473044022045e1efecc973bf2f39590db496b04c7234141df5322e8735351423693f47a4cb022065703955f9932f8ba017fee155dd7050c1b2fc82f464fa1250431f8f500e05e5412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffff6024b88c0f3ee301f2749e2bf187ac21032078f613479a6d43cb72f7a6fcc832000000006a473044022025b3905457f5674a3781108f85da299a8abe8f9b578a32804a493ae942c31de0022024b87ab07c8311e91fcd1fa07ef3928ac89170b243316ff8eb60015fad4ee047412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffffd7d9e9cb27fc24f13fc7ff2353edcbfa886c3b2fd892ef15cd0699df106c2089000000006a4730440220737a15c56faae7513bc8e4eb11da8e42e0e8d3800de59352c8e3341e723a6d8f02200a016cb32924f2feb415fcd08d5d2a9424bde83a10bfbdc754f01c8460a23e7a412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffffef8bc91bb10f37ccfe95aaf1a333c99f28420765bdca67e213b17d60304296f7000000006a47304402203a9574ecbe09637b3fccebe3bad9d198b3f8f314737d89226db31d6ed593ae7b022064d603ed2d69e12070e777969d6a4bc370d26c8893ab47b69290cdee698e625c412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffff05fe96d8c32f2025dfe32475b16a828e87a9dc93b4fd20e57ce654bbe63b420d000000006a47304402201e03b75ba4796ea1229e2b43c0cb70d82542b900ab4814f1bc7e4579e06b629502204df091992038a117f1428803558b26b81321b076e80df7341541ebb8ede01d44412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffff74d844541bdb8894c4bbc388cd5bf0a03867a9b03f4dbd97a3357db17a8be751000000006a47304402203c31e11a6ec40b34fb12e6687fb52bf84e84fdc53bd207ad469b05f96afa268b022036f8da31d9c19462943a80aebc14ee2681f74e48d56700a8b180aac18e0143a6412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffffb864035adfb17b6e22928407f890bd6962dff4a597e51f79b79873c84af5e063000000006b483045022100870ea0b1cf692df52254d1ceb14970d8c450a320e6dd2412e2f01fc62f07a4960220023fb9e25b30cb1dd513865628b5b9ed13ea712bda78b4f8a7041e0731a59d7f412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffff99034704de67eacb43a21a3fa37e08986cb064df641c42facda690d7409dff17000000006a47304402203200d312d97b271ba6b809e2e424f1ab3d3c1ccf5e7d24e6c64919089bed65380220790d99737ef55dce7d64d20a82ad29c172a6f5028e9e681ec6ca02ee7f24caf7412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffff8902070e945224c6aed2779ad36eab1bf41228676722ad63c8e2b5d82f656cc9000000006a47304402202391ffe007faa25b63ff9bd3a1a592b98ef7a54c84307c20aa3b8eca35a1f01c02207fd17d1a1a112824b78e4da540b7b981d8ee7b18495a18ae8f17582c104e4ad6412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffff72038e7115f1561335b2902fccc5610cd005d8eae2433c99610f77e7f3b226d3000000006b483045022100d25940f30e9c72c3e6a06eda10f57581437635b39f087ad61287847de5fd1be002200e99db88ef18fa560edfc1488a9e10c273b240e724204fb39325f8fe768c519c412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffff88a5cd36d8344f70c6defc6824906e5cdf1fd8210a5f5b91b1a443713333ae82000000006a47304402200509adafeb3ef9fa8a22734648d8cfaf61b91de1d51a91fe8670d0ca1354b4d902202c8bf4806a0bc5a51697c40bffdf3755277bd92837cb1ed413a7c08426206924412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffffdadb6095589ed53839ed2266c9e3419d284e6005f77214ec41d4aff55010f8da000000006a4730440220725b5945c73637230f57dcfbcd78fa1e99e6861087bc48d48f9c9baa0392d9be02200ebae3138065645ea8b6e95544925756242658f05779191489bfdf83a0802f6e412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffffd9254a1ee24a65c1a5321eae64864d30361696558e1d9a78711167f826f62170000000006a47304402200385f971a71ed208399f3595f524e84415f0ac8f7921a6c56e3827982180bc9602206e6b095ee51829360d4fe83c937d737e97bc829179652bf02e52a7f1e24c1723412102a6b338a7647a12095fb38f8a5420579d37bec27f738a63875fbaac6e0cd3dd6afeffffffcade71b919e19be83399b344bdd46ef2d2fa3805835230f3fa030aeaff788e54010000006a47304402200f9e911a91c7ca457458325067eff2bd4aeff11ff24ef801411371118291c57a02205e47a9fb0b8aba22621d1b48b04fd856de2879aa7f9033fe8e6109e35ba0d822412102f983443f86e1cdaadaccdbe0a49c5d204812f4eff29634b5fc22bd75ff2e2b5afefffffff0115046f800d45e58bc075185131f4dadb712e0981e67b1e796eb890b917ace000000006b48304502210095fd244f89854dc261e70924f33cbd048f1bcb5072fe728f5a88cf790209b7c1022058d295de49086ff4ae2645efdc251f9dd346f3b562c11eb9c9d7267ba6b85f01412103b552e56a7172af31d2ace4c20a27bff1b11fec84245c65a8ee7cc379ec439fe0feffffff0265f90f00000000001976a9148a38665bbc2d8ed22b1b351c99bbdc0d251b0e5688ac00f2052a010000001976a914519e1d1acb0915a0a3a1de245989609be18d68d888ac78611300"
    
    
    let txData = txt.hexToData()
    DLog(message: txData!.count)
    
}

