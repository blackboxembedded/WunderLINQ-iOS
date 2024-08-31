/*
WunderLINQ Client Application
Copyright (C) 2020  Keith Conger, Black Box Embedded, LLC

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import UIKit
import CarPlay

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate, CPListTemplateDelegate {
    var interfaceController: CPInterfaceController?
    var refreshTimer: Timer?
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {

        self.interfaceController = interfaceController

        updateGridTemplate()
        
        // Start the timer to refresh the grid template every 10 seconds
        startRefreshTimer()
    }
    
    @objc func updateGridTemplate() {
        NSLog("updateGridTemplate()")
        if #available(iOS 14.0, *) {
            let dataPoint1 = UserDefaults.standard.integer(forKey: "grid_one_preference")
            let gridButton1 = CPGridButton(titleVariants: [MotorcycleData.getValue(dataPoint: dataPoint1)],
                                           image: MotorcycleData.getIcon(dataPoint: dataPoint1)) { button in
                self.interfaceController?.pushTemplate(self.listTemplate(),
                                                 animated: true,
                                                 completion: nil)
            }
            let dataPoint2 = UserDefaults.standard.integer(forKey: "grid_two_preference")
            let gridButton2 = CPGridButton(titleVariants: [MotorcycleData.getValue(dataPoint: dataPoint2)],
                                           image: MotorcycleData.getIcon(dataPoint: dataPoint2)) { button in
                self.interfaceController?.pushTemplate(self.listTemplate(),
                                                 animated: true,
                                                 completion: nil)
            }
            let dataPoint3 = UserDefaults.standard.integer(forKey: "grid_three_preference")
            let gridButton3 = CPGridButton(titleVariants: [MotorcycleData.getValue(dataPoint: dataPoint3)],
                                           image: MotorcycleData.getIcon(dataPoint: dataPoint3)) { button in
                self.interfaceController?.pushTemplate(self.listTemplate(),
                                                 animated: true,
                                                 completion: nil)
            }
            let dataPoint4 = UserDefaults.standard.integer(forKey: "grid_four_preference")
            let gridButton4 = CPGridButton(titleVariants: [MotorcycleData.getValue(dataPoint: dataPoint4)],
                                           image: MotorcycleData.getIcon(dataPoint: dataPoint4)) { button in
                self.interfaceController?.pushTemplate(self.listTemplate(),
                                                 animated: true,
                                                 completion: nil)
            }
            let dataPoint5 = UserDefaults.standard.integer(forKey: "grid_five_preference")
            let gridButton5 = CPGridButton(titleVariants: [MotorcycleData.getValue(dataPoint: dataPoint5)],
                                           image: MotorcycleData.getIcon(dataPoint: dataPoint5)) { button in
                self.interfaceController?.pushTemplate(self.listTemplate(),
                                                 animated: true,
                                                 completion: nil)
            }
            let dataPoint6 = UserDefaults.standard.integer(forKey: "grid_six_preference")
            let gridButton6 = CPGridButton(titleVariants: [MotorcycleData.getValue(dataPoint: dataPoint6)],
                                           image: MotorcycleData.getIcon(dataPoint: dataPoint6)) { button in
                self.interfaceController?.pushTemplate(self.listTemplate(),
                                                 animated: true,
                                                 completion: nil)
            }
            let dataPoint7 = UserDefaults.standard.integer(forKey: "grid_seven_preference")
            let gridButton7 = CPGridButton(titleVariants: [MotorcycleData.getValue(dataPoint: dataPoint7)],
                                           image: MotorcycleData.getIcon(dataPoint: dataPoint7)) { button in
                self.interfaceController?.pushTemplate(self.listTemplate(),
                                                 animated: true,
                                                 completion: nil)
            }
            let dataPoint8 = UserDefaults.standard.integer(forKey: "grid_eight_preference")
            let gridButton8 = CPGridButton(titleVariants: [MotorcycleData.getValue(dataPoint: dataPoint8)],
                                           image: MotorcycleData.getIcon(dataPoint: dataPoint8)) { button in
                self.interfaceController?.pushTemplate(self.listTemplate(),
                                                 animated: true,
                                                 completion: nil)
            }
            
            let gridTemplate = CPGridTemplate(title: "WunderLINQ", gridButtons: [gridButton1,gridButton2,gridButton3,gridButton4,gridButton5,gridButton6,gridButton7,gridButton8])
            interfaceController?.setRootTemplate(gridTemplate,
                                                animated: true,
                                                completion: nil)
        } else {
            // Fallback for iOS 13
            interfaceController?.setRootTemplate(self.listTemplate(),
                                                animated: true)
        }
    }
    
    func startRefreshTimer() {
        refreshTimer?.invalidate()  // Invalidate any existing timer
        refreshTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(updateGridTemplate), userInfo: nil, repeats: true)
    }

    func listTemplate() -> CPListTemplate {
        let item = CPListItem(text: "iOS 14 Required", detailText: "CarPlay Support Requires iOS 14")
        
        if #available(iOS 14.0, *) {
            item.handler = { item, completion in
                NSLog("Item selected")
                completion()
            }
        }
        
        let section = CPListSection(items: [item])
        let listTemplate = CPListTemplate(title: "WunderLINQ", sections: [section])
        
        if #available(iOS 14.0, *) {
            // Do nothing, handler is already set
        } else {
            listTemplate.delegate = self
        }
        
        return listTemplate
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        self.interfaceController = nil
        refreshTimer?.invalidate()  // Invalidate the timer when disconnected
    }
    
    // Delegate method for CPListTemplateDelegate (iOS 13)
    func listTemplate(_ listTemplate: CPListTemplate, didSelect item: CPListItem, completionHandler: @escaping () -> Void) {
        NSLog("Item selected")
        completionHandler()
    }
}

