//
/*******************************************************************************

        WhWalletCustomView.swift
        WHoleWallet
   
        Created by ffy on 2018/11/19
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import Foundation
import SnapKit

class WhWalletButton: UIView {
    let bgButton      = UIButton(type: UIButton.ButtonType.custom)
    let iconImageView = UIImageView(frame: CGRect.zero)
    let nameLabel     = UILabel(frame: CGRect.zero)
    let amountLabel   = UILabel(frame: CGRect.zero)
    

    init(bg: String, icon: String, name:String, amount:String) {
        super.init(frame: CGRect.zero)
        
        configConstraints()
     
        configSubViews(bg: bg, icon: icon, name: name, amount: amount)
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        configConstraints()
    }
    
    
    func configSubViews(bg: String, icon: String, name:String, amount:String) {
        
        self.bgButton.setBackgroundImage(UIImage(named: bg), for: .normal)
        self.bgButton.contentMode = .scaleAspectFill
        self.iconImageView.image = UIImage(named: icon)
        self.nameLabel.text = name
        self.amountLabel.text = amount
        
        self.nameLabel.textColor = UIColor.white
        self.nameLabel.font      = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        
        self.amountLabel.textColor = UIColor.white
        self.amountLabel.font      = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
        self.amountLabel.textAlignment = .right
        
    }
    
    func configConstraints() {
        //add subviews constraint
        self.addSubview(self.bgButton)
        self.bgButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(self.iconImageView)
        self.iconImageView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        
        self.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.iconImageView.snp.right).offset(10)
            make.centerY.equalTo(self.iconImageView.snp.centerY)
        }
        
        self.addSubview(self.amountLabel)
        self.amountLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.centerY.equalTo(self.nameLabel.snp.centerY)
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        let p = self.convert(point, to: self)
        if self.frame.contains(p){
            return self.bgButton
        }else{
            return super.hitTest(point, with: event)
        }
    }
    
}



class WhWalletButtonTwo: UIView {
    
    let bgButton      = UIButton(type: UIButton.ButtonType.custom)
    
    let iconImageView = UIButton(type: UIButton.ButtonType.custom)
    
    let nameLabel      = UILabel(frame: CGRect.zero)
    let addressLabel   = UILabel(frame: CGRect.zero)
    
    
    init(name:String, address:String) {
        super.init(frame: CGRect.zero)
        
        configConstraints()
        
        configSubViews(name: name, address: address)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configConstraints()
    }
    
    
    func configSubViews(name: String, address: String) {
        
        self.nameLabel.text    = name
        self.addressLabel.text = address
        
        self.bgButton.setBackgroundImage(UIImage(named: "main_blue_bg_wallet"), for: .normal)
        self.bgButton.contentMode = .scaleAspectFill
        
        self.iconImageView.setBackgroundImage(UIImage(named: "main_button_QR"), for: .normal)
        
        self.nameLabel.textColor = UIColor.white
        self.nameLabel.font      = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        
        self.addressLabel.textColor = UIColor.white
        self.addressLabel.font      = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)

        
    }
    
    func configConstraints() {
        //add subviews constraint
        self.addSubview(self.bgButton)
        self.bgButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        
        self.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(80)
            make.top.equalTo(10)
        }
        
        self.addSubview(self.addressLabel)
        self.addressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.nameLabel)
            make.top.equalTo(self.nameLabel.snp.bottom)
        }
        
        self.addSubview(self.iconImageView)
        self.iconImageView.snp.makeConstraints { (make) in
            make.right.equalTo(-20)
            make.width.height.equalTo(20)
            make.centerY.equalTo(self.addressLabel.snp.centerY)
            make.left.equalTo(self.addressLabel.snp.right).offset(5)
        }
        
        
    }

}




class WhSelectButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setTitleColor(UIColor(hex: 0x0A1F44), for: .normal)
        self.layer.borderColor = UIColor(hex: 0xE1E4E8).cgColor
        self.layer.borderWidth  = 1.5
        self.layer.cornerRadius = 6
    }
    
    
    override func awakeFromNib() {
        setImage(UIImage(named: "assert_icon_down"), for: .normal)
        setImage(UIImage(named: "assert_icon_up"), for: .selected)
    }
    
    
    open override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(x: 15, y: contentRect.origin.y, width: contentRect.size.width - 45 , height: contentRect.size.height)
    }
    
    open override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(x: contentRect.size.width - 26, y: contentRect.origin.y + (contentRect.size.height - 22) / 2, width: 21 , height: 22)
    }
}



class WhSureButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor(hex: 0x758196)
        self.layer.cornerRadius = 22.5
    }
}

extension UIButton {
    static func commonSure(title: String) -> UIButton {
        let sure = UIButton(type: .custom)
        sure.setTitle(title, for: .normal)
        sure.backgroundColor = UIColor(hex: 0x758196)
        sure.layer.cornerRadius = 22.5
        return sure
    }
}


class WhAddressView: UIView {
    var address:String
    
    init(address: String) {
        self.address = address
        super.init(frame: CGRect.zero)
        configView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configView() {
        let addressTag = UILabel()
        addressTag.text = "Address:"
        addressTag.textColor = UIColor(hex: 0x53627C)
        addressTag.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        addSubview(addressTag)
        addressTag.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        let addressLabel = UILabel()
        addressLabel.text = address
        addressLabel.textColor = UIColor(hex: 0x8a94a6)
        addressLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        addressLabel.numberOfLines = 0
        addSubview(addressLabel)
        addressLabel.snp.makeConstraints { (make) in
            make.left.equalTo(addressTag.snp.right).offset(10)
            make.right.equalToSuperview()
            make.top.equalTo(addressTag.snp.top)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
    }
}


//fee rate select view
class WhFeeRateView: UIView {
    
    weak var  editTextField: UITextField?
    var feeRates: [Double]! {
        didSet {
            buttonClicked(button: selectButon)
        }
    }
    private var baseTag = 10000
    private var selectButon:UIButton!
    
    init(textField:UITextField, feeRates: [Double]?) {
        super.init(frame: CGRect.zero)
        configSubView()
        setEditField(textField: textField, feeRates: feeRates)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configSubView()
    }
    
    func setEditField(textField: UITextField, feeRates: [Double]?) {
        editTextField = textField
        if let fees = feeRates {
            if fees.count == 3 {
                self.feeRates = fees
            } else {
                let obj = WhWalletManager.shared
                self.feeRates = [obj.fastFeeRate,obj.normalFeeRate,obj.slowFeeRate]
            }
            
        } else {
            let obj = WhWalletManager.shared
            self.feeRates = [obj.fastFeeRate,obj.normalFeeRate,obj.slowFeeRate]
        }
    }
    
    func configSubView() {
        let titles = ["Fast","Normal","Slow"]
        var preButton: UIButton!
        for (index,title) in titles.enumerated() {
            let button = UIButton(type: .custom)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            if index == 1 {
                button.isSelected = true
                button.backgroundColor = UIColor(hex: 0xffffff)
                selectButon = button
            } else {
                button.backgroundColor = UIColor(hex: 0xffffff)
            }
            button.layer.cornerRadius = 6
            button.tag = baseTag + index
            button.addTarget(self, action: #selector(buttonClicked(button:)), for: .touchUpInside)
            
            addSubview(button)
            button.snp.makeConstraints { (make) in
                if index == 0 {
                    make.top.left.bottom.equalToSuperview()
                    make.width.equalTo(67)
                } else {
                    make.top.equalTo(preButton.snp.top)
                    make.bottom.equalTo(preButton.snp.bottom)
                    make.left.equalTo(preButton.snp.right).offset(20)
                    make.width.equalTo(preButton.snp.width)
                }
            }
            preButton = button
        }
    }
    
    @objc func buttonClicked(button: UIButton) {
        guard let tf = editTextField else {
            return
        }
        guard feeRates.count == 3 else {
            return
        }
        
        if !button.isSelected {
            button.isSelected = true;
            
        }
        for index in 0...3 {
            let tag = baseTag + index
            let view = viewWithTag(tag)
            if tag != button.tag {
                view?.backgroundColor = UIColor(hex: 0x8A94A6)
            }else {
                view?.backgroundColor = UIColor(hex: 0x0C66FF)
                tf.text = feeRates[index].toString()
            }
        }
        
        selectButon = button
        
    }
}


class WhAssetDetailItem: UIView {
    private var title: String
    private var value: String?
    
    init(title:String, value: String?) {
        self.title = title
        self.value = value
        super.init(frame: CGRect.zero)
        
        configViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configViews()  {
        let aSpace = 12
        let itemValueH = 40
        
        // category
        let categoryTag = UILabel()
        categoryTag.text = title
        categoryTag.textColor = UIColor(hex: 0x445571)
        categoryTag.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        addSubview(categoryTag)
        categoryTag.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        
        let categoryNameL = UILabel()
        categoryNameL.text = value
        categoryNameL.textAlignment = .center
        categoryNameL.textColor = UIColor(hex: 0x8A94A6)
        categoryNameL.backgroundColor = UIColor(hex: 0xF9F9F9)
        categoryNameL.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        addSubview(categoryNameL)
        categoryNameL.snp.makeConstraints { (make) in
            make.left.equalTo(categoryTag.snp.left)
            make.right.equalTo(categoryTag.snp.right)
            make.top.equalTo(categoryTag.snp.bottom).offset(aSpace)
            make.bottom.equalToSuperview()
            make.height.equalTo(itemValueH)
        }
    }
}


//custom textfield with icon and tag
class WhAssetOperateView: UIView {
    var title: String
    var iconName: String
    var highLight: String
    var operateBtn = UIButton(type: .custom)
    
    init(title: String, iconName: String, highLight: String) {
        self.title = title
        self.iconName = iconName
        self.highLight = highLight
        super.init(frame: CGRect.zero)
        
        configView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configView() {
        operateBtn.setImage(UIImage(named: iconName), for: .normal)
        operateBtn.setImage(UIImage(named: iconName), for: .highlighted)
        addSubview(operateBtn)
        operateBtn.snp.makeConstraints { (make) in
            make.width.equalTo(71)
            make.height.equalTo(88)
            make.centerX.equalToSuperview()
            make.top.equalTo(10)
        }
        
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        label.textColor = UIColor(hex: 0x53627C)
        label.text = title
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(operateBtn.snp.bottom)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }
        
    }
}


class WhCommonInputRow: UIView {
    
    static let defaultH = 72
    
    var icon:  String
    var title: String
    var holder: String?
    var keyboardType: UIKeyboardType
    var tf: WhCPTextField!
    
    init(icon: String, title: String,  _ holder: String, _ kbType: UIKeyboardType = .default) {
        self.icon = icon
        self.title = title
        self.holder = holder
        self.keyboardType = kbType
        super.init(frame: CGRect.zero)
        
        configView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configView() {
        let iconView = UIImageView(image: UIImage(named: icon))
        addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.left.top.equalToSuperview()
        }
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor(hex: 0x53627C)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconView.snp.right).offset(10)
            make.centerY.equalTo(iconView.snp.centerY)
        }
        
        let textField = WhCPTextField()
        textField.placeholder = holder
        textField.keyboardType = self.keyboardType
        addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(iconView.snp.bottom).offset(5)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(48)
        }
        tf = textField
        
    }
    
    
}



