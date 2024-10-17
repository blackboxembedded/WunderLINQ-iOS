//
//  AppSettingsViewController.swift
//  WunderLINQ
//
//  Created by Keith Conger on 4/14/21.
//  Copyright © 2021 Black Box Embedded, LLC. All rights reserved.
//

import UIKit
import InAppSettingsKit

class AppSettingsViewController: IASKAppSettingsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "Left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backBtn.tintColor = UIColor(named: "imageTint")
        backBtn.addTarget(self, action: #selector(leftScreen), for: .touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        let backButtonWidth = backButton.customView?.widthAnchor.constraint(equalToConstant: 30)
        backButtonWidth?.isActive = true
        let backButtonHeight = backButton.customView?.heightAnchor.constraint(equalToConstant: 30)
        backButtonHeight?.isActive = true
        self.navigationItem.leftBarButtonItems = [backButton]
    }
    
    @objc func leftScreen() {
        navigationController?.popToRootViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(style: UITableView.Style) {
        super.init(style: style)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    func myinit (file: NSString, specifier: IASKSpecifier) -> AppSettingsViewController {
        let vc = AppSettingsViewController()
        vc.showDoneButton = false;
        vc.showCreditsFooter = false;
        vc.delegate = self.delegate;
        vc.settingsStore = self.settingsStore;
        vc.file = specifier.file!;
        vc.hiddenKeys = self.hiddenKeys;
        vc.title = specifier.title;

        return vc
    }

}
