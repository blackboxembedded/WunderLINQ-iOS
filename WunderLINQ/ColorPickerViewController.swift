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

import Foundation
import UIKit
import ChromaColorPicker
import InAppSettingsKit

class ColorPickerViewController: UIViewController
{
    private let defaultColorPickerSize = CGSize(width: 320, height: 320)
    private let brightnessSliderWidthHeightRatio: CGFloat = 0.1
    private var colorPicker: ChromaColorPicker!
    private var brightnessSlider: ChromaBrightnessSlider!
    private var pickerHandle: ChromaColorHandle!
    
    override func loadView() {
        view = UIView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor(named: "backgrounds")
        view.autoresizesSubviews = true
        
        colorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: defaultColorPickerSize.width, height: defaultColorPickerSize.height))
        colorPicker.delegate = self
        view.addSubview(colorPicker)
        colorPicker.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Attach a ChromaBrightnessSlider to a ChromaColorPicker
        brightnessSlider = ChromaBrightnessSlider(frame: CGRect(x: 0, y: defaultColorPickerSize.height, width: defaultColorPickerSize.width, height: 32))
        view.addSubview(brightnessSlider)
        brightnessSlider.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        colorPicker.connect(brightnessSlider)
        
        var highlightColor: UIColor?
        if let colorData = UserDefaults.standard.data(forKey: "highlight_color_preference"){
            highlightColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)
        } else {
            highlightColor = UIColor(named: "accent")
        }
        pickerHandle = colorPicker.addHandle(at: highlightColor)
    }
    
    @objc func initWithFile (_ file: NSString, specifier: IASKSpecifier ) -> ColorPickerViewController {
        let vc = ColorPickerViewController()
        return vc
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var smallestDimension = view.bounds.width
        if(view.bounds.height < view.bounds.width){
            smallestDimension = view.bounds.height
            colorPicker.frame = CGRect(x: 0, y: 0, width: smallestDimension, height: smallestDimension)
            brightnessSlider.frame = CGRect(x: (smallestDimension + 16), y: ((smallestDimension / 2) - 16), width: smallestDimension, height: 32)
        } else {
            smallestDimension = view.bounds.width
            colorPicker.frame = CGRect(x: 0, y: 0, width: smallestDimension, height: smallestDimension)
            brightnessSlider.frame = CGRect(x: 0, y: (smallestDimension + 16), width: smallestDimension, height: 32)
        }
        
        let verticalOffset = -defaultColorPickerSize.height / 6
        NSLayoutConstraint.activate([
            colorPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorPicker.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: verticalOffset),
            colorPicker.widthAnchor.constraint(equalToConstant: defaultColorPickerSize.width),
            colorPicker.heightAnchor.constraint(equalToConstant: defaultColorPickerSize.height)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ColorPickerViewController: ChromaColorPickerDelegate {
    func colorPickerHandleDidChange(_ colorPicker: ChromaColorPicker, handle: ChromaColorHandle, to color: UIColor) {
        var colorData: Data?
        colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
        UserDefaults.standard.set(colorData as NSData?, forKey: "highlight_color_preference")
    }
}
