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

enum Theme: Int {
    case `default`, dark
    
    private enum Keys {
        static let selectedTheme = "SelectedTheme"
    }
    
    static var current: Theme {
        let storedTheme = UserDefaults.standard.integer(forKey: Keys.selectedTheme)
        return Theme(rawValue: storedTheme) ?? .default
    }
    
    var mainColor: UIColor {
        switch self {
        case .default:
            return UIColor.black
        case .dark:
            return UIColor.white
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .default:
            return UIColor.white
        case .dark:
            return UIColor.black
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .default:
            return UIColor.black
        case .dark:
            return UIColor.white
        }
    }
    
    func apply() {
        UserDefaults.standard.set(rawValue, forKey: Keys.selectedTheme)
        UserDefaults.standard.synchronize()
        
        UILabel.appearance(whenContainedInInstancesOf: [MainCollectionViewController.self]).textColor = textColor
        UICollectionView.appearance(whenContainedInInstancesOf: [MainCollectionViewController.self]).backgroundColor = textColor

        UIView.appearance(whenContainedInInstancesOf: [MusicViewController.self]).backgroundColor = backgroundColor
        UILabel.appearance(whenContainedInInstancesOf: [MusicViewController.self]).textColor = textColor
        UIButton.appearance(whenContainedInInstancesOf: [MusicViewController.self]).tintColor = mainColor
 
        UIView.appearance(whenContainedInInstancesOf: [TasksCollectionViewController.self]).backgroundColor = backgroundColor
        UILabel.appearance(whenContainedInInstancesOf: [TasksCollectionViewController.self]).textColor = textColor
        UICollectionView.appearance(whenContainedInInstancesOf: [TasksCollectionViewController.self]).backgroundColor = backgroundColor
        UICollectionViewCell.appearance(whenContainedInInstancesOf: [TasksCollectionViewController.self]).backgroundColor = backgroundColor
        UICollectionViewCell.appearance(whenContainedInInstancesOf: [TasksCollectionViewController.self]).tintColor = mainColor
        
        UIView.appearance(whenContainedInInstancesOf: [MusicViewController.self]).backgroundColor = backgroundColor
        UIImageView.appearance(whenContainedInInstancesOf: [MusicViewController.self]).backgroundColor = backgroundColor
        UILabel.appearance(whenContainedInInstancesOf: [MusicViewController.self]).textColor = textColor
        UIButton.appearance(whenContainedInInstancesOf: [MusicViewController.self]).tintColor = mainColor
        
        UIView.appearance(whenContainedInInstancesOf: [ContactsTableViewController.self]).backgroundColor = backgroundColor
        UILabel.appearance(whenContainedInInstancesOf: [ContactsTableViewController.self]).textColor = textColor
        
        UIView.appearance(whenContainedInInstancesOf: [WaypointsNavTableViewController.self]).backgroundColor = backgroundColor
        UILabel.appearance(whenContainedInInstancesOf: [WaypointsNavTableViewController.self]).textColor = textColor
        UITableViewCell.appearance(whenContainedInInstancesOf: [WaypointsNavTableViewController.self]).backgroundColor = backgroundColor
        UITableViewCell.appearance(whenContainedInInstancesOf: [WaypointsNavTableViewController.self]).tintColor = mainColor
        UITableViewCell.appearance(whenContainedInInstancesOf: [WaypointsNavTableViewController.self]).contentView.backgroundColor = backgroundColor
        UITableViewCell.appearance(whenContainedInInstancesOf: [WaypointsNavTableViewController.self]).contentView.tintColor = mainColor
        
        UIButton.appearance(whenContainedInInstancesOf: [WaypointViewController.self]).tintColor = UIColor.black
        UIButton.appearance(whenContainedInInstancesOf: [TripViewController.self]).tintColor = UIColor.black
        
        UIImageView.appearance(whenContainedInInstancesOf: [GeoDataViewController.self]).tintColor = UIColor.white

        UINavigationBar.appearance().backItem?.backBarButtonItem?.tintColor = mainColor
        UINavigationBar.appearance().barStyle = .default
        UINavigationBar.appearance().barTintColor = backgroundColor
        UINavigationBar.appearance().titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([
            NSAttributedString.Key.foregroundColor.rawValue: mainColor
        ])
        UINavigationBar.appearance().tintColor = mainColor
        UINavigationBar.appearance().backItem?.leftBarButtonItem?.tintColor = mainColor
        
        UIButton.appearance().tintColor = mainColor
        UIBarButtonItem.appearance().tintColor = mainColor
        UINavigationBar.appearance().backgroundColor = backgroundColor
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
