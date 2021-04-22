import UIKit

@IBDesignable
open class UIMultiPicker: UIControl {

    @objc
    public var options: [String] = [] {
        didSet {
            picker.reloadComponent(0)
        }
    }

    @objc
    public var selectedIndexes: [Int] = [] {
        didSet {
            picker.reloadComponent(0)
        }
    }

    @objc
    public var font: UIFont = UIFont.systemFont(ofSize: 21) {
        didSet {
            picker.setNeedsLayout()
        }
    }

    @objc
    public var textAlign: NSTextAlignment = .center {
        didSet {
            picker.setNeedsLayout()
        }
    }

    @IBInspectable
    public var color: UIColor = UIColor.black {
        didSet {
            picker.setNeedsLayout()
        }
    }

    @IBInspectable
    public var rowHeight: CGFloat = 44 {
        didSet {
            picker.setNeedsLayout()
        }
    }

    @objc
    public func highlight(_ at: Int, animated: Bool = true) {
        picker.selectRow(at, inComponent: 0, animated: animated)
    }

    private let picker = UIMultiPickerView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        let height = bounds.size.height
        let h = height - 22 // Vertical padding
        let offset = max(0, (UIMultiPicker.A * h * h + (UIMultiPicker.B - 1) * h + UIMultiPicker.C) / 2)
        picker.frame.size.height = height + 2 * offset
        picker.frame.origin.y = -offset
    }

    fileprivate func setup() {
        picker.parent = self
        addSubview(picker)
        picker.frame = bounds
        picker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    fileprivate static let A: CGFloat = 0.001138663967611336
    fileprivate static let B: CGFloat = 1.3481781376518218
    fileprivate static let C: CGFloat = -64.72064777327921
}

class UIMultiPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource
{
    weak var parent: UIMultiPicker!
    var proxy: TableViewProxy!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        self.delegate = self
        self.dataSource = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.borderWidth = 0 // Main view rounded border

        // Component borders
        subviews.forEach {
            $0.layer.borderWidth = 0
            $0.isHidden = $0.frame.height <= 1.0 || $0.subviews.count == 0
        }

        let tables = [
            subviews[0].subviews[0].subviews[0].subviews[0] as! UITableView, // top
            subviews[0].subviews[0].subviews[1].subviews[0] as! UITableView, // bottom
            subviews[0].subviews[0].subviews[2].subviews[0] as! UITableView, // center
        ]
        if tables[0].dataSource !== proxy {
            proxy = TableViewProxy(dataSource: tables[0].dataSource!)
            proxy.multiPicker = self.parent
            for table in tables {
                table.dataSource = proxy
            }
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return parent.options.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return parent.options[row]
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return parent.rowHeight
    }
}

class TableViewProxy: NSObject, UITableViewDataSource
{
    weak var multiPicker: UIMultiPicker!
    let dataSource: UITableViewDataSource

    init(dataSource: UITableViewDataSource) {
        self.dataSource = dataSource
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dataSource.tableView(tableView, cellForRowAt: indexPath)
        let label = cell.subviews.first(where: { $0 is UILabel }) as! UILabel

        let tap = cell.gestureRecognizers![0] as! UITapGestureRecognizer
        cell.tag = indexPath.row
        tap.addTarget(self, action: #selector(self.handleCellTap))

        label.alpha = 1
        label.font = multiPicker.font
        label.textAlignment = multiPicker.textAlign
        label.textColor = multiPicker.selectedIndexes.contains(indexPath.row) ?
            multiPicker.tintColor :
            multiPicker.color

        return cell
    }

    @objc
    func handleCellTap(sender: UITapGestureRecognizer) {
        let cell = sender.view as! UITableViewCell
        let row = cell.tag

        if (multiPicker.selectedIndexes.contains(row)) {
            multiPicker.selectedIndexes = multiPicker.selectedIndexes.filter { $0 != row }
        } else {
            multiPicker.selectedIndexes += [row]
        }
        multiPicker.sendActions(for: .valueChanged)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.tableView(tableView, numberOfRowsInSection: section)
    }
}
