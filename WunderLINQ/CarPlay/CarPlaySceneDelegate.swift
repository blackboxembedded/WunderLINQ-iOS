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

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    var interfaceController: CPInterfaceController?
    var tabBarTemplate: CPTabBarTemplate?
    var gridTemplate: CPGridTemplate?
    var listTemplate: CPListTemplate?
    
    var refreshTimer: Timer?
    
    let buttonLabelLength = 14
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {

        self.interfaceController = interfaceController

        gridTemplate = self.dataGridTemplate()
        if(!Faults.shared.getallActiveDesc().isEmpty){
            listTemplate = self.faultListTemplate()
            tabBarTemplate = CPTabBarTemplate(templates: [gridTemplate!,listTemplate!])
        } else {
            tabBarTemplate = CPTabBarTemplate(templates: [gridTemplate!])
        }

        interfaceController.setRootTemplate(tabBarTemplate!,
                                            animated: true,
                                            completion: nil)
        
        // Start the timer to refresh the display every 10 seconds
        startRefreshTimer()
    }
    
    @objc func updateDisplay() {
        if(!Faults.shared.getallActiveDesc().isEmpty && tabBarTemplate?.templates.count == 1){
            self.listTemplate = self.faultListTemplate()
            tabBarTemplate?.updateTemplates([self.gridTemplate!,self.listTemplate!])
        }
        if (tabBarTemplate?.selectedTemplate == tabBarTemplate?.templates[0]){
            updateGrid()
        } else {
            updateFaults()
        }
    }
    
    func startRefreshTimer() {
        refreshTimer?.invalidate()  // Invalidate any existing timer
        refreshTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(updateDisplay), userInfo: nil, repeats: true)
    }
    
    func faultListTemplate() -> CPListTemplate {
        var faultItems = [CPListItem]()
        for item in Faults.shared.getallActiveDesc() {
            faultItems.append(CPListItem(text: item, detailText: ""))
        }
        let section = CPListSection(items: faultItems)
        let listTemplate = CPListTemplate(title: NSLocalizedString("fault_title", comment: ""), sections: [section])
        listTemplate.tabImage = UIImage(named: "Alert")?.withRenderingMode(.alwaysTemplate)
        
        return listTemplate
    }
    
    func updateFaults() {
        var faultItems = [CPListItem]()
        for item in Faults.shared.getallActiveDesc() {
            faultItems.append(CPListItem(text: item, detailText: ""))
        }
        let section = CPListSection(items: faultItems)
        listTemplate?.updateSections([section])
    }
    
    func dataGridTemplate() -> CPGridTemplate {
        let dataPoint1 = UserDefaults.standard.integer(forKey: "grid_one_preference")
        let gridButton1 = CPGridButton(titleVariants: [Utility.padString(MotorcycleData.getValue(dataPoint: dataPoint1), length: buttonLabelLength)],
                                       image: MotorcycleData.getIcon(dataPoint: dataPoint1)) { button in
        }
        let dataPoint2 = UserDefaults.standard.integer(forKey: "grid_two_preference")
        let gridButton2 = CPGridButton(titleVariants: [Utility.padString(MotorcycleData.getValue(dataPoint: dataPoint2), length: buttonLabelLength)],
                                       image: MotorcycleData.getIcon(dataPoint: dataPoint2)) { button in
        }
        let dataPoint3 = UserDefaults.standard.integer(forKey: "grid_three_preference")
        let gridButton3 = CPGridButton(titleVariants: [Utility.padString(MotorcycleData.getValue(dataPoint: dataPoint3), length: buttonLabelLength)],
                                       image: MotorcycleData.getIcon(dataPoint: dataPoint3)) { button in
        }
        let dataPoint4 = UserDefaults.standard.integer(forKey: "grid_four_preference")
        let gridButton4 = CPGridButton(titleVariants: [Utility.padString(MotorcycleData.getValue(dataPoint: dataPoint4), length: buttonLabelLength)],
                                       image: MotorcycleData.getIcon(dataPoint: dataPoint4)) { button in
        }
        let dataPoint5 = UserDefaults.standard.integer(forKey: "grid_five_preference")
        let gridButton5 = CPGridButton(titleVariants: [Utility.padString(MotorcycleData.getValue(dataPoint: dataPoint5), length: buttonLabelLength)],
                                       image: MotorcycleData.getIcon(dataPoint: dataPoint5)) { button in
        }
        let dataPoint6 = UserDefaults.standard.integer(forKey: "grid_six_preference")
        let gridButton6 = CPGridButton(titleVariants: [Utility.padString(MotorcycleData.getValue(dataPoint: dataPoint6), length: buttonLabelLength)],
                                       image: MotorcycleData.getIcon(dataPoint: dataPoint6)) { button in
        }
        let dataPoint7 = UserDefaults.standard.integer(forKey: "grid_seven_preference")
        let gridButton7 = CPGridButton(titleVariants: [Utility.padString(MotorcycleData.getValue(dataPoint: dataPoint7), length: buttonLabelLength)],
                                       image: MotorcycleData.getIcon(dataPoint: dataPoint7)) { button in
        }
        let dataPoint8 = UserDefaults.standard.integer(forKey: "grid_eight_preference")
        let gridButton8 = CPGridButton(titleVariants: [Utility.padString(MotorcycleData.getValue(dataPoint: dataPoint8), length: buttonLabelLength)],
                                       image: MotorcycleData.getIcon(dataPoint: dataPoint8)) { button in
        }
        let gridTemplate = CPGridTemplate(title: NSLocalizedString("main_title", comment: ""), gridButtons: [gridButton1,gridButton2,gridButton3,gridButton4,gridButton5,gridButton6,gridButton7,gridButton8])
        gridTemplate.tabImage = UIImage(named: "Odometer")?.withRenderingMode(.alwaysTemplate)
        
        return gridTemplate
    }
    
    func updateGrid(){
        if #available(iOS 15.0, *) {
            let dataPoint1 = UserDefaults.standard.integer(forKey: "grid_one_preference")
            let gridButton1 = CPGridButton(titleVariants: [Utility.padString(MotorcycleData.getValue(dataPoint: dataPoint1), length: buttonLabelLength)],
                                           image: MotorcycleData.getIcon(dataPoint: dataPoint1)) { button in
            }
            let dataPoint2 = UserDefaults.standard.integer(forKey: "grid_two_preference")
            let gridButton2 = CPGridButton(titleVariants: [Utility.padString(MotorcycleData.getValue(dataPoint: dataPoint2), length: buttonLabelLength)],
                                           image: MotorcycleData.getIcon(dataPoint: dataPoint2)) { button in
            }
            let dataPoint3 = UserDefaults.standard.integer(forKey: "grid_three_preference")
            let gridButton3 = CPGridButton(titleVariants: [Utility.padString(MotorcycleData.getValue(dataPoint: dataPoint3), length: buttonLabelLength)],
                                           image: MotorcycleData.getIcon(dataPoint: dataPoint3)) { button in
            }
            let dataPoint4 = UserDefaults.standard.integer(forKey: "grid_four_preference")
            let gridButton4 = CPGridButton(titleVariants: [Utility.padString(MotorcycleData.getValue(dataPoint: dataPoint4), length: buttonLabelLength)],
                                           image: MotorcycleData.getIcon(dataPoint: dataPoint4)) { button in
            }
            let dataPoint5 = UserDefaults.standard.integer(forKey: "grid_five_preference")
            let gridButton5 = CPGridButton(titleVariants: [Utility.padString(MotorcycleData.getValue(dataPoint: dataPoint5), length: buttonLabelLength)],
                                           image: MotorcycleData.getIcon(dataPoint: dataPoint5)) { button in
            }
            let dataPoint6 = UserDefaults.standard.integer(forKey: "grid_six_preference")
            let gridButton6 = CPGridButton(titleVariants: [Utility.padString(MotorcycleData.getValue(dataPoint: dataPoint6), length: buttonLabelLength)],
                                           image: MotorcycleData.getIcon(dataPoint: dataPoint6)) { button in
            }
            let dataPoint7 = UserDefaults.standard.integer(forKey: "grid_seven_preference")
            let gridButton7 = CPGridButton(titleVariants: [Utility.padString(MotorcycleData.getValue(dataPoint: dataPoint7), length: buttonLabelLength)],
                                           image: MotorcycleData.getIcon(dataPoint: dataPoint7)) { button in
            }
            let dataPoint8 = UserDefaults.standard.integer(forKey: "grid_eight_preference")
            let gridButton8 = CPGridButton(titleVariants: [Utility.padString(MotorcycleData.getValue(dataPoint: dataPoint8), length: buttonLabelLength)],
                                           image: MotorcycleData.getIcon(dataPoint: dataPoint8)) { button in
            }
            gridTemplate?.updateGridButtons([gridButton1,gridButton2,gridButton3,gridButton4,gridButton5,gridButton6,gridButton7,gridButton8])
        } else {
            // Fallback on earlier versions
            if(!Faults.shared.getallActiveDesc().isEmpty){
                listTemplate = self.faultListTemplate()
                tabBarTemplate = CPTabBarTemplate(templates: [gridTemplate!,listTemplate!])
            } else {
                gridTemplate = self.dataGridTemplate()
                tabBarTemplate = CPTabBarTemplate(templates: [gridTemplate!])
            }

            interfaceController!.setRootTemplate(tabBarTemplate!,
                                                animated: true,
                                                completion: nil)
            
        }
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        self.interfaceController = nil
        refreshTimer?.invalidate()  // Invalidate the timer when disconnected
    }

}
