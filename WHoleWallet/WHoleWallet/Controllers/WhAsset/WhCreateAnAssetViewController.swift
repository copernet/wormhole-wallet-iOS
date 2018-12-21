//
/*******************************************************************************

        WhCreateAnAssetViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/11/29
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit
import SnapKit
import Toast_Swift

enum AssetType:String {
    case managed = "managed"
    case fixed = "fixed"
    case crowdsale = "crowdsale"
}

class WhCreateAnAssetViewController: UIViewController, UITextFieldDelegate, UIPopoverPresentationControllerDelegate,WhPopContentSelectProtocol {

    var assetType = AssetType.managed
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameTF: WhCPTextField!
    @IBOutlet weak var tokenURLTF: WhCPTextField!
    @IBOutlet weak var describeTF: WhCPTextField!

    @IBOutlet weak var categoryButton: WhSelectButton!
    @IBOutlet weak var subCategoryButton: WhSelectButton!
    
    //precison
    @IBOutlet weak var precisionContainer: UIView!
    @IBOutlet weak var precisionTop: NSLayoutConstraint!
    @IBOutlet weak var precisionButton: WhSelectButton!
    
    //number
    @IBOutlet weak var numberContainer: UIView!
    @IBOutlet weak var numberTop: NSLayoutConstraint!
    
    @IBOutlet weak var numberHeight: NSLayoutConstraint!
    @IBOutlet weak var numberTF: WhCPTextField!
    
    
    // crowdsale
    @IBOutlet weak var crowdSaleContainer: UIView!
    @IBOutlet weak var deadLine: WhCPTextField!
    @IBOutlet weak var earlyBirdTF: WhCPTextField!
    @IBOutlet weak var tokenRateTF: WhCPTextField!
    
    //miner container
    @IBOutlet weak var minerContainerTop: NSLayoutConstraint!
    
    
    @IBOutlet weak var minerFeeTF: WhCPTextField!
    @IBOutlet weak var feeRateView: WhFeeRateView!
    @IBOutlet weak var manulFeeTF: WhCPTextField!
    
    @IBOutlet weak var sureButton: UIButton!
    
    
    private var deadLineTime: Date!
    
    var categories = Dictionary<String, Array<String>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configViews()
        
        fetchFeeRate()
        
    }
    
    func fetchFeeRate()  {
        WhHTTPRequestHandler.getFeeRate { (dictionary,fees) in
            if dictionary.count > 0 {
                DispatchQueue.main.async {
                    self.feeRateView.feeRates = fees
                }
            }
        }
    }
    
    
    func configViews()  {
        
        //add container
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // address 
        addressLabel.text = WhWalletManager.shared.whWallet?.cashAddr
        
        //category
        categoryButton.titleLabel?.textAlignment = .left
        
        //feeRate
        feeRateView.setEditField(textField: minerFeeTF, feeRates: nil)
        
        // difference with type
      
        switch assetType {
        case .managed:
            numberContainer.isHidden = true
            numberTop.constant = 0
            numberHeight.constant = 0
            crowdSaleContainer.isHidden = true
            minerContainerTop.constant = 15
            break
        case .fixed:
            crowdSaleContainer.isHidden = true
            minerContainerTop.constant = 15
            break
        default: break
            
        }
        
        
        manulFeeTF.isUserInteractionEnabled = false
        
        //
        deadLine.delegate = self
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //select time
        if textField == deadLine {
            let picker = WhDatePicker { (pop, b) in
                let popPicker = pop as! WhDatePicker
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                textField.text = dateFormatter.string(from: popPicker.date)
                self.deadLineTime = popPicker.date
            }
            picker.show()
            return false
        }
        return true
    }
    
    
    @IBAction func categorySelect(_ sender: Any) {
        
        let button = sender as! UIButton
        
        categoryButton.title(for: .normal)
        
        if button.tag == 100 {
            if self.categories.count > 0 {
               popoverCategories(categories: Array(self.categories.keys), view: button)
            }else {
                WhHTTPRequestHandler.getCategories { (categories) in
                    if categories.count > 0 {
                        self.categories = categories;
                        self.popoverCategories(categories: Array(self.categories.keys), view: button)
                    }
                }
            }
        }else if button.tag == 101 {
            guard let key = categoryButton.title(for: .normal) else {
                return
            }
            if self.categories.count > 0 {
                popoverCategories(categories: self.categories[key]!, view: button)
            }
        }
        
    }
    
    
    @IBAction func precisionSelect(_ sender: Any) {
        let button = sender as! UIButton
        let sources = ["1","2","3","4","5","6","7","8"]
        popoverCategories(categories: sources, view: button)
    }
    
    
    
    func popoverCategories(categories: [String], view: UIButton) {
        view.isSelected = true
        
        let pop = WhPopContentViewController()
        pop.selectedDelegate = self
        pop.source = categories
        pop.modalPresentationStyle = .popover
        pop.popoverPresentationController?.delegate = self
        pop.popoverPresentationController?.sourceView = view
        pop.popoverPresentationController?.sourceRect = view.bounds
        pop.preferredContentSize = CGSize(width: view.bounds.width, height: 200)
        pop.popoverPresentationController?.permittedArrowDirections = .up
        self.present(pop, animated: true, completion: nil)
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        let button = popoverPresentationController.sourceView as! UIButton
        button.isSelected = false
    }
    
    func didSlectedRowData(row: Int, data: String, pop: UIViewController) {
        let button = pop.popoverPresentationController?.sourceView as! UIButton
        button.setTitle(data, for: .normal)
        button.setTitle(data, for: .selected)
        button.isSelected = false
    }
    
    
    @IBAction func sureAction(_ sender: Any) {
        guard let fee = minerFeeTF.text, let from = addressLabel.text  else {
            self.view!.makeToast("please enter required information !")
            return
        }
        guard let precision = precisionButton.title(for: .normal) else {
            self.view!.makeToast("please enter required information !")
            return
        }
        guard let category = categoryButton.title(for: .normal), let subCategory = subCategoryButton.title(for: .normal) else {
            self.view!.makeToast("please enter required information !")
            return
        }
        guard let name = nameTF.text, let url = tokenURLTF.text else {
            self.view!.makeToast("please enter required information !")
            return
        }
        guard let description = describeTF.text else {
            self.view!.makeToast("please enter required information !")
            return
        }
        
        var parameters = ["fee": fee, "transaction_from": from, "precision": precision, "property_category": category, "property_subcategory": subCategory, "property_name": name, "property_url": url,"property_data": description, "ecosystem":"1","previous_property_id":"0","transaction_version":"0"]
        var path:String!
        switch assetType {
        case .managed:
            path = WhHTTPRequestHandler.UnSignedPath.managed.rawValue
            break
        case .fixed:
            path = WhHTTPRequestHandler.UnSignedPath.fixed.rawValue
            guard let numer = numberTF.text else {
                return
            }
            parameters["number_properties"] = numer
            break
        case .crowdsale:
            path = WhHTTPRequestHandler.UnSignedPath.crowdsale.rawValue
            guard let numer = numberTF.text, let deadline = deadLine.text,let earlayAward = earlyBirdTF.text, let tokenRate = tokenRateTF.text else {
                return
            }
            parameters["total_number"] = numer
            parameters["number_properties"] = tokenRate
            parameters["deadline"] = deadline
            parameters["earlybird_bonus"] = earlayAward
            parameters["currency_identifier_desired"] = "1"
            break
        }

        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: .sortedKeys)
            DLog(message: String(data: data, encoding: .utf8))
        } catch  {
            DLog(message: error)
        }
        
        WhHTTPRequestHandler.createAsset(path:path, parameters: parameters) { (result) in
            if result.count > 0 {
                WormHoleSignUnSignedTxFlow.handleResult(result: result, complete: {
                    DispatchQueue.main.async {
                        [weak self] in
                        if let weakSelf = self {
                            weakSelf.view!.makeToast("transaction success !", duration: 2.0, title: nil, image: nil) { didTap in
                                weakSelf.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                }, failure: {
                    [weak self] in
                    if let weakSelf = self {
                        weakSelf.view!.makeToast("transaction failed !")
                    }
                })
            }
            
            //do somthing
            DispatchQueue.main.async {
                [weak self] in
                if let weakSelf = self {
                    weakSelf.view!.makeToast("transaction failed !")
                }
            }
            return
            
        }
        
    }
    

}
