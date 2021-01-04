![UIMultiPicker](https://raw.github.com/aselivanov/UIMultiPickerDemo/master/media/UIMultiPicker.png)

[![CI Status](https://img.shields.io/travis/aselivanov/UIMultiPickerDemo.svg?style=flat)](https://travis-ci.org/aselivanov/UIMultiPickerDemo)
[![Version](https://img.shields.io/cocoapods/v/UIMultiPicker.svg?style=flat)](https://cocoapods.org/pods/UIMultiPicker)
[![License](https://img.shields.io/cocoapods/l/UIMultiPicker.svg?style=flat)](https://cocoapods.org/pods/UIMultiPicker)
[![Platform](https://img.shields.io/cocoapods/p/UIMultiPicker.svg?style=flat)](https://cocoapods.org/pods/UIMultiPicker)

`UIMultiPicker` is `UIPickerView` extension to support multiple selection.
The goal was to implement UI control mobile Safari uses to handle input for `<select multiple>` tag.

UIMultiPicker subclasses `UIControl` and sends `.valueChanged` action when any value is picked or unpicked (i.e. selection is changed).

## Usage

```swift
class ViewController: UIViewController {

    static let TASTES = [
        "Sweet",
        "Sour",
        "Bitter",
        "Salty",
        "Umami"
    ];
    
    @IBOutlet weak var tastesPicker: UIMultiPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Model
        tastesPicker.options = ViewController.TASTES
        tastesPicker.selectedIndexes = [0,2]

        // Styling
        tastesPicker.color = .gray
        tastesPicker.tintColor = .black
        tastesPicker.font = .systemFont(ofSize: 30, weight: .bold)

        // Add selection listener
        tastesPicker.addTarget(self, action: #selector(ViewController.selected(_:)), for: .valueChanged)

        tastesPicker.highlight(2, animated: false) // centering "Bitter"
    }
    
    @objc func selected(_ sender: UIMultiPicker) {
        print(sender.selectedIndexes)
    }
}
```

## Options

### **`options: [String]`**

List of options.

### **`selectedIndexes: [Int]`**

Selected items indexes, reactive to user interactions.

### **`color: UIColor`**

Text color for not selected items.

### **`UIView.tintColor: UIColor`**

Text color for selected items .

### **`textAlign: NSTextAlignment`**

Text alignments for picker items.

### **`font: UIFont`**

Font face for picker items.

## Example

Here is a [demo](https://github.com/aselivanov/UIMultiPickerDemo) Xcode project.

## Installation

UIMultiPicker is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'UIMultiPicker'
```
