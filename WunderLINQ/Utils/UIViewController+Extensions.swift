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

extension UIViewController {
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width - 20, height: 70))
        toastLabel.center = self.view.center
        toastLabel.numberOfLines = 0
        toastLabel.backgroundColor = UIColor(named: "imageTint")
        toastLabel.textColor = UIColor(named: "backgrounds")
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont.boldSystemFont(ofSize: 20)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 1.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
