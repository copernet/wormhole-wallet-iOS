//
/*******************************************************************************

        WhAlertViews.swift
        WHoleWallet
   
        Created by ffy on 2018/11/20
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import Foundation
import MMPopupView
import BitcoinKit
import Toast_Swift

class WhCustomAlertView: MMPopupView {
    
    let icon:  String
    let title: String
    let sure: String
    let complete: MMPopupCompletionBlock

    init(icon: String, title:String, sure: String, subView:UIView?, closeBtn:Bool, completeBlock:@escaping MMPopupCompletionBlock) {
        self.icon  = icon
        self.title = title
        self.sure = sure
        self.complete = completeBlock
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
        self.type = MMPopupType.custom
        self.layer.cornerRadius = 8
        configAlertView(subView: subView, useCloseBtn: closeBtn)

    }
    
    func configAlertView(subView:UIView?, useCloseBtn:Bool) {
        
        if useCloseBtn {
            let close = getSureButton()
            close.backgroundColor = UIColor.clear
            close.setBackgroundImage(UIImage(named: "create_close"), for: .normal)
            self.addSubview(close)
            close.snp.makeConstraints { (make) in
                make.width.height.equalTo(24)
                make.top.equalTo(8)
                make.right.equalTo(-8)
            }
        }
        
        let iconView = UIImageView(image: UIImage(named: self.icon))
        self.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.top.equalTo(30)
            make.centerX.equalToSuperview()
        }
        
        let label = UILabel(frame: CGRect.zero)
        label.text = self.title
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor(hex: 0x182c4f)
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(iconView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        if let sv = subView {
            self.addSubview(sv)
            sv.snp.makeConstraints { (make) in
                make.left.equalTo(20)
                make.top.equalTo(label.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
            }
            
            let sure = getSureButton()
            sure.layer.cornerRadius = 20
            self.addSubview(sure)
            sure.snp.makeConstraints { (make) in
                make.top.equalTo(sv.snp.bottom).offset(45)
                make.left.equalTo(50)
                make.centerX.equalToSuperview()
                make.height.equalTo(45)
                make.bottom.equalTo(-30).priority(750)
            }
        }else{
            let sure = getSureButton()
            sure.layer.cornerRadius = 20
            self.addSubview(sure)
            sure.snp.makeConstraints { (make) in
                make.top.equalTo(label.snp.bottom).offset(45)
                make.left.equalTo(50)
                make.centerX.equalToSuperview()
                make.height.equalTo(45)
                make.bottom.equalTo(-30).priority(750)
            }
        }
        
        let frame = UIScreen.main.bounds
        self.snp.makeConstraints { (make) in
            make.width.equalTo(frame.size.width-40)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getSureButton() -> UIButton {
        let sure = UIButton(type: UIButton.ButtonType.custom)
        sure.backgroundColor = UIColor(hex: 0x0c66ff)
        sure.setTitle(self.sure, for: .normal)
        sure.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        return sure
    }
    
    
    @objc func sureAction() {
        self.hide(self.complete)
    }
    
    
    static func createWalletAlert(complete:@escaping MMPopupCompletionBlock) -> WhCustomAlertView{
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: 0x8a94a6)
        label.text = "应包含大小写字母、数字，且 8-32个字符"
        let alert = WhCustomAlertView(icon: "create_warning", title: "请输入正确的密码格式", sure: "我知道了", subView: label, closeBtn: true, completeBlock: complete)
        return alert
    }
    
    static func createMnemonicInputAlert(complete:@escaping MMPopupCompletionBlock) -> WhCustomAlertView{
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: 0x8a94a6)
        label.text = "12个助记词必须按正确顺序输入至框内，并以空格分开"
        let alert = WhCustomAlertView(icon: "create_warning", title: "请按正确顺序输入助记词", sure: "我知道了", subView: label, closeBtn: true, completeBlock: complete)
        return alert
    }
    
    static func createBackupMnemonicFirstAlert(complete:@escaping MMPopupCompletionBlock) -> WhCustomAlertView{
        
        let topContainer = UIView()
        topContainer.layer.cornerRadius = 5
        topContainer.backgroundColor = UIColor(hex: 0xfafcff)
        let label = UILabel(frame: CGRect.zero)
        
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: 0x8a94a6)
        label.text = "钱包安全密码丢失时，将永远丢失该钱包及资"
        label.numberOfLines = 0
        topContainer.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.init(top: 5, left: 30, bottom: 5, right: 25))
        }
    
        let licon = UIImageView(image: UIImage(named: "wallet_create_reminder_icon"))
        topContainer.addSubview(licon)
        licon.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
            make.left.top.equalTo(5)
        }
        
        
        let bttomContainer = UIView()
        bttomContainer.layer.cornerRadius = 5
        bttomContainer.backgroundColor = UIColor(hex: 0xfafcff)
        let labelb = UILabel(frame: CGRect.zero)
        labelb.font = UIFont.systemFont(ofSize: 14)
        labelb.textColor = UIColor(hex: 0x8a94a6)
        labelb.numberOfLines = 0
        labelb.text = "删除钱包APP或手机遗失时，将永远丢失该"
        bttomContainer.addSubview(labelb)
        labelb.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.init(top: 5, left: 30, bottom: 5, right: 25))
        }
        
        let liconb = UIImageView(image: UIImage(named: "wallet_create_reminder_icon"))
        bttomContainer.addSubview(liconb)
        liconb.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
            make.left.top.equalTo(5)
        }
        
        let container = UIView()
        container.addSubview(topContainer)
        topContainer.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
        }
        container.addSubview(bttomContainer)
        bttomContainer.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(topContainer.snp.bottom).offset(5)
        }
        
    
        let alert = WhCustomAlertView(icon: "create_icon_word", title: "如未备份助记词会发生什么?", sure: "我知道了", subView: container, closeBtn: false, completeBlock: complete)
        return alert
    }
    
    static func createBackupMnemonicSecondAlert(complete:@escaping MMPopupCompletionBlock) -> WhCustomAlertView{
        
        let topContainer = UIView()
        topContainer.layer.cornerRadius = 5
        topContainer.backgroundColor = UIColor(hex: 0xfafcff)
        let label = UILabel(frame: CGRect.zero)
        
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: 0x8a94a6)
        label.text = "禁止截屏，并注意周围是否有摄像头"
        label.numberOfLines = 0
        topContainer.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.init(top: 5, left: 30, bottom: 5, right: 25))
        }
        
        let licon = UIImageView(image: UIImage(named: "wallet_create_reminder_icon"))
        topContainer.addSubview(licon)
        licon.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
            make.left.top.equalTo(5)
        }
        
        
        
        let centerContainer = UIView()
        centerContainer.layer.cornerRadius = 5
        centerContainer.backgroundColor = UIColor(hex: 0xfafcff)
        let labelc = UILabel(frame: CGRect.zero)
        
        labelc.font = UIFont.systemFont(ofSize: 14)
        labelc.textColor = UIColor(hex: 0x8a94a6)
        labelc.text = "请按顺序将「助记词」抄写在安全的地方，千万不要保存在网络上。"
        labelc.numberOfLines = 0
        centerContainer.addSubview(labelc)
        labelc.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.init(top: 5, left: 30, bottom: 5, right: 25))
        }
        
        let liconc = UIImageView(image: UIImage(named: "wallet_create_reminder_icon"))
        centerContainer.addSubview(liconc)
        liconc.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
            make.left.top.equalTo(5)
        }
        
        
        let bttomContainer = UIView()
        bttomContainer.layer.cornerRadius = 5
        bttomContainer.backgroundColor = UIColor(hex: 0xfafcff)
        let labelb = UILabel(frame: CGRect.zero)
        labelb.font = UIFont.systemFont(ofSize: 14)
        labelb.textColor = UIColor(hex: 0x8a94a6)
        labelb.numberOfLines = 0
        labelb.text = "保存好自己的「助记词」，wormhole wallet 钱包不承担因用户遗失、销毁或其他方式导致的资产损失。"
        bttomContainer.addSubview(labelb)
        labelb.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets.init(top: 5, left: 30, bottom: 5, right: 25))
        }
        
        let liconb = UIImageView(image: UIImage(named: "wallet_create_reminder_icon"))
        bttomContainer.addSubview(liconb)
        liconb.snp.makeConstraints { (make) in
            make.width.height.equalTo(16)
            make.left.top.equalTo(5)
        }
        
        let container = UIView()
        container.addSubview(topContainer)
        topContainer.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
        }
        
        container.addSubview(centerContainer)
        centerContainer.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(topContainer.snp.bottom).offset(5)
        }
        
        container.addSubview(bttomContainer)
        bttomContainer.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.top.equalTo(centerContainer.snp.bottom).offset(5)
        }
        
        
        let alert = WhCustomAlertView(icon: "create_icon_security", title: "注意事项", sure: "我知道了", subView: container, closeBtn: false, completeBlock: complete)
        return alert
        
    }
    
}


class WhQRCodeAlertView: MMPopupView {
    let bg:  String
    let pic: UIImage
    let subTitle: String
    let complete: MMPopupCompletionBlock?
    
    init(bg: String, pic:UIImage, subTitle: String, completeBlock:MMPopupCompletionBlock?) {
        self.bg  = bg
        self.pic = pic
        self.subTitle = subTitle
        self.complete = completeBlock
        super.init(frame: CGRect.zero)
        self.type = MMPopupType.custom
        
        self.layer.cornerRadius = 8
        configAlertView()
        
        MMPopupWindow.shared()?.touchWildToHide = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func  configAlertView() {
        
        let width = screenWidth()-40
        self.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.height.equalTo(width * 433 / 296)
        }
        
        let bgView = UIImageView(image: UIImage(named: self.bg))
        self.addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let picView = UIImageView(image: self.pic)
        self.addSubview(picView)
        picView.snp.makeConstraints { (make) in
            make.width.height.equalTo(width - 80)
            make.top.equalTo(50)
            make.centerX.equalToSuperview()
        }
        
        let iconView = UIImageView(image: UIImage(named: "main_icon_copy"))
        self.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.right.equalToSuperview().offset(-25)
            make.bottom.equalToSuperview().offset(-46 * screenWidth() / 360)
        }
//        iconView.isMultipleTouchEnabled = true
        iconView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(copyAddress))
        iconView.addGestureRecognizer(tap)
        
        
        let label = UILabel(frame: CGRect.zero)
        label.text = self.subTitle
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor(hex: 0x182c4f)
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.bottom.equalTo(iconView.snp.bottom)
            make.left.equalToSuperview().offset(25)
            make.right.equalTo(iconView.snp.left).offset(-5)
        }
        
    }
    
    
    @objc func copyAddress() {
        UIPasteboard.general.string = self.subTitle
        self.makeToast("the address has been copied !")
    }
    
    deinit {
        MMPopupWindow.shared()?.touchWildToHide = false
    }
}



class WhInputAlertView: MMPopupView, UITextFieldDelegate {
    let icon:   String
    let title:  String
    let promot: String
    let sure: String
    let complete: MMPopupCompletionBlock
    var tf:WhCPTextField!
    var promptLabel:UILabel!
    var password: String?
    
    init(icon: String, title:String, promot:String, sure: String, closeBtn:Bool, completeBlock:@escaping MMPopupCompletionBlock) {
        self.icon  = icon
        self.title = title
        self.promot = promot
        self.sure = sure
        self.complete = completeBlock
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
        self.type = MMPopupType.custom
        MMPopupWindow.shared()?.touchWildToHide = true
        
        self.layer.cornerRadius = 8
        configAlertView(useCloseBtn: closeBtn)
        
    }
    
    func configAlertView(useCloseBtn:Bool) {
        
        if useCloseBtn {
            let close = getSureButton()
            close.backgroundColor = UIColor.clear
            close.setBackgroundImage(UIImage(named: "create_close"), for: .normal)
            close.tag = 100
            self.addSubview(close)
            close.snp.makeConstraints { (make) in
                make.width.height.equalTo(24)
                make.top.equalTo(8)
                make.right.equalTo(-8)
            }
        }
        
        let iconView = UIImageView(image: UIImage(named: self.icon))
        self.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.top.equalTo(30)
            make.centerX.equalToSuperview()
        }
        
        let label = UILabel(frame: CGRect.zero)
        label.text = self.title
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor(hex: 0x182c4f)
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(iconView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        
        let tf = WhCPTextField(frame: CGRect.zero)
        tf.placeholder = "Please Input Password"
        tf.borderStyle = .roundedRect
        tf.setBorderColor(UIColor(hex: 0xF03D3D), forEditing: true)
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.textColor = UIColor(hex: 0x182c4f)
        self.addSubview(tf)
        tf.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.left.equalTo(15)
            make.height.equalTo(51)
        }
        tf.delegate = self
        self.tf = tf
        
        let promptLabel = UILabel(frame: CGRect.zero)
        promptLabel.text = self.promot
        promptLabel.font = UIFont.systemFont(ofSize: 14)
        promptLabel.textColor = UIColor(hex: 0xF03D3D)
        self.addSubview(promptLabel)
        promptLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tf.snp.bottom).offset(5)
            make.left.equalTo(tf.snp.left)
        }
        self.promptLabel = promptLabel
        
        let sure = getSureButton()
        sure.layer.cornerRadius = 20
        self.addSubview(sure)
        sure.snp.makeConstraints { (make) in
            make.top.equalTo(promptLabel.snp.bottom).offset(20)
            make.left.equalTo(50)
            make.centerX.equalToSuperview()
            make.height.equalTo(45)
            make.bottom.equalTo(-100).priority(750)
        }
        
        let frame = UIScreen.main.bounds
        self.snp.makeConstraints { (make) in
            
            make.width.equalTo(frame.size.width-60)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getSureButton() -> UIButton {
        let sure = UIButton(type: UIButton.ButtonType.custom)
        sure.backgroundColor = UIColor(hex: 0x0c66ff)
        sure.setTitle(self.sure, for: .normal)
        sure.addTarget(self, action: #selector(sureAction(sender:)), for: .touchUpInside)
        return sure
    }
    
    
    @objc func sureAction(sender: UIButton) {
        if sender.tag == 100 {
            self.hide()
            return
        }
        if let password = self.tf.text {
            let hash  = WhWalletManager.shared.getCurrentSeedHash()
            let pHash = Crypto.sha256sha256(password.data(using: .utf8)!)
            if hash == pHash {
                self.password = password
                self.complete(self,false)
                self.hide()
            }else{
                //prompt
                self.promptLabel.isHidden = false
            }
        } else {
            self.promptLabel.isHidden = false
        }
        
    }
    
    
    override func show() {
        super.show()
        self.tf.becomeFirstResponder()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.promptLabel.isHidden = true
        return true
    }
    
    deinit {
        self.tf.resignFirstResponder()
        MMPopupWindow.shared()?.touchWildToHide = false
    }
    
    
    static func defaultAuthAlert(completeBlock:@escaping MMPopupCompletionBlock) -> WhInputAlertView {
        let alert = WhInputAlertView(icon: "main_icon_lock", title: "Please enter your password", promot: "Password invalid,Please check them and try again", sure: "Sure", closeBtn: true, completeBlock: completeBlock)
        
        return alert
    }
    
}



class WhDatePicker: MMPopupView {
    
//    private var picker:UIDatePicker!
    var date: Date!
    let complete: MMPopupCompletionBlock
    
    init(completeBlock:@escaping MMPopupCompletionBlock) {
   
        self.complete = completeBlock
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
        self.type = MMPopupType.custom
        self.layer.cornerRadius = 8
        configAlertView()
        
        MMPopupWindow.shared()?.touchWildToHide = true
    }
    
    func configAlertView() {
        let width = screenWidth() - 40
        self.snp.makeConstraints { (make) in
            make.width.height.equalTo(width)
        }
        
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(valueChanged(picker:)), for: .valueChanged)
        self.addSubview(datePicker)
        datePicker.snp.makeConstraints { (make) in
            make.top.left.equalTo(10)
            make.right.bottom.equalTo(-10)
        }
        self.date = datePicker.date
  
    }
    
    @objc func valueChanged(picker: UIDatePicker){
        self.date = picker.date
    }
    
    deinit {
        MMPopupWindow.shared()?.touchWildToHide = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func hide() {
        complete(self, true)
        super.hide()
    }

    
}



