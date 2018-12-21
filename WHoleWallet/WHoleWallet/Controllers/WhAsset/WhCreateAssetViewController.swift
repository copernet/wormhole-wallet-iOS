//
/*******************************************************************************

        WhCreateAssetViewController.swift
        WHoleWallet
   
        Created by ffy on 2018/11/28
        Copyright © 2018年 wormhole. All rights reserved.

********************************************************************************/
    

import UIKit



class AssetCreateView: UIView {
    
    var bgButton: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func awakeFromNib() {
        bgButton = self.viewWithTag(100)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let p = self.convert(point, to: self)
        
        if self.bounds.contains(p){
            return self.bgButton
        }else{
            return super.hitTest(point, with: event)
        }
    }
    
    
}

class WhCreateAssetViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let button = sender as! UIButton
        let dest = segue.destination as! WhCreateAnAssetViewController
        if button.restorationIdentifier == "managed" {
            dest.assetType = .managed
        } else if button.restorationIdentifier == "fixed" {
            dest.assetType = .fixed
        } else if button.restorationIdentifier == "crowdsale" {
            dest.assetType = .crowdsale
        }
        
    }


}
