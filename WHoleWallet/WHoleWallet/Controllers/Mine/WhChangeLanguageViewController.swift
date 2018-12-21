//
/*******************************************************************************

        WhChangeLanguageViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/12/5
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import SnapKit
import KeychainAccess
import BitcoinKit

class WhChangeLanguageViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
   
    var currentLanguage: String!
    var supportLanguages = [String]()
    
    
    var tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        supportLanguages.append("English")//en
//        supportLanguages.append("简体中文")//zh-Hans
        
        tableView.delegate   = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        tableView.tableFooterView = UIView()
        tableView.register(WhLanguageCell.self, forCellReuseIdentifier: WhLanguageCell.reuseIdentifier)
        
        currentLanguage = "English"
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supportLanguages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WhLanguageCell.reuseIdentifier, for: indexPath) as! WhLanguageCell
        cell.nameLabel.text = supportLanguages[indexPath.row]
        if currentLanguage == supportLanguages[indexPath.row] {
            cell.beSelected()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
  

}


class WhLanguageCell: UITableViewCell {
    static let reuseIdentifier = "WhLanguageCell"
    var nameLabel:UILabel!
    var useIcon:UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configViews() {
        let nameLabel = UILabel(frame: .zero)
        nameLabel.textColor = UIColor.darkTextColor
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
        }
        self.nameLabel = nameLabel
        
        let iconView = UIImageView(image: UIImage(named: "my_icon_chose_nor"))
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        self.useIcon = iconView
    }
    
    func beSelected()  {
        self.useIcon.image = UIImage(named: "my_icon_chose_sel")
    }
}




