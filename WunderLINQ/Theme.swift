//
//  Theme.swift
//  WunderLINQ
//
//  Created by Keith Conger on 8/10/18.
//  Copyright © 2018 Black Box Embedded, LLC. All rights reserved.
//

import UIKit
import GoogleMaps

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

        UIView.appearance(whenContainedInInstancesOf: [MusicViewController.self]).backgroundColor = backgroundColor
        UILabel.appearance(whenContainedInInstancesOf: [MusicViewController.self]).textColor = textColor
        UIButton.appearance(whenContainedInInstancesOf: [MusicViewController.self]).tintColor = mainColor
 
        UIView.appearance(whenContainedInInstancesOf: [TasksCollectionViewController.self]).backgroundColor = backgroundColor
        UILabel.appearance(whenContainedInInstancesOf: [TasksCollectionViewController.self]).textColor = textColor
        UICollectionViewCell.appearance(whenContainedInInstancesOf: [TasksCollectionViewController.self]).backgroundColor = backgroundColor
        UICollectionViewCell.appearance(whenContainedInInstancesOf: [TasksCollectionViewController.self]).tintColor = mainColor
        
        UIView.appearance(whenContainedInInstancesOf: [MusicViewController.self]).backgroundColor = backgroundColor
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
        
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().barTintColor = backgroundColor
        UINavigationBar.appearance().backgroundColor = backgroundColor
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: mainColor
        ]
        UIButton.appearance().tintColor = mainColor
        UIBarButtonItem.appearance().tintColor = mainColor
        
        //UIApplication.shared.delegate?.window??.tintColor = mainColor
        //UIApplication.shared.delegate?.window??.backgroundColor = backgroundColor
        //UIButton.appearance().tintColor = mainColor
        //UIBarButtonItem.appearance().tintColor = mainColor
        //UINavigationBar.appearance().titleTextAttributes = [
        //    NSForegroundColorAttributeName: mainColor
        //]
        //UINavigationBar.appearance().backgroundColor = backgroundColor
        //UINavigationBar.appearance().tintColor = mainColor
        //UIView.appearance().backgroundColor = backgroundColor
        //UIView.appearance(whenContainedInInstancesOf: [GMSMapView.self]).backgroundColor = nil
        //UIView.appearance().tintColor = mainColor
        //UILabel.appearance().textColor = textColor
        //UITextField.appearance().backgroundColor = backgroundColor
        //UITextField.appearance().textColor = textColor
        //UITableViewCell.appearance().backgroundColor = backgroundColor
        //UITableViewCell.appearance().tintColor = mainColor
        //UITableViewCell.appearance().contentView.backgroundColor = backgroundColor
        //UITableViewCell.appearance().contentView.tintColor = mainColor
        //UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = textColor
    }
}
