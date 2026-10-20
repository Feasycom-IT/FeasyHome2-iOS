//
//  NewRoomViewController.swift
//  FeasyHome2
//
//  Created by wenjie zeng on 2025/2/6.
//

import UIKit

extension UIView {
    func currentFirstResponder() -> UIResponder? {
            if self.isFirstResponder {
                return self
            }
            for view in self.subviews {
                if let responder = view.currentFirstResponder() {
                    return responder
                }
            }
            return nil
        }
}

class NewRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RoomTableUnitCellDelegate, UITextFieldDelegate {
    var selectedViews: [IndexPath: Set<UIView>] = [:]
    var orgSelectedIndexPath:IndexPath?
    var orgSelectedUILabel:UILabel?
    var tableView:UITableView!
    var createButton:UIButton!
    let CELL_ID = "ROOM_TABLE_UNIT_CELL"
    var roomCreatedCallback:((String)->Void)?
    var roomNameTextField:UITextField!
    var selectTitle:[String] = ["起居","睡眠", "餐饮", "功能", "自定义"]
    var selectRooms:[[String]] = [["客厅", "书房", "玄关"],["主卧", "次卧", "客房"],["餐厅", "厨房"],["阳台", "庭院", "卫生间"],[""]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = "创建房间"
        setupTableView()
        createButton = UIButton(type: .system)
        createButton.setTitle("创建", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = UIColor(red: 0/255.0, green: 117/255.0, blue: 201/255.0, alpha: 1.0)
        createButton.layer.cornerRadius = 6
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        self.view.addSubview(createButton)
        self.view.backgroundColor = UIColor(red: 245.0/255, green: 245.0/255, blue: 245.0/255, alpha: 1.0)
        
        NSLayoutConstraint.activate([
            createButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            createButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 52),
            createButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20)
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        roomNameTextField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func roomNameTextFieldChanged() {
        selectedViews.removeAll()
        if orgSelectedIndexPath != nil {
            tableView.reloadRows(at: [orgSelectedIndexPath!], with: .automatic)
        }
    }
    
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView!)
        tableView.rowHeight = 50
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 245.0/255, green: 245/255.0, blue: 245.0/255, alpha: 1.0)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,constant: -90)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let num = selectRooms[section].count/3 + ((selectRooms[section].count%3)>0 ? 1:0)
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectRooms.count == indexPath.section+1 {
            //            let cell = tableView.dequeueReusableCell(withIdentifier: "RoomTableTextFieldUnitCell") as? RoomTableTextFieldUnitCell ?? RoomTableTextFieldUnitCell(style: .value1, reuseIdentifier: "RoomTableTextFieldUnitCell")
            //            roomNameTextField = cell.textField
            //            roomNameTextField.delegate = self
            //            cell.selectionStyle = .none
            //            return cell
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RoomTableTextFieldUnitCell") ?? UITableViewCell(style: .value1, reuseIdentifier: "RoomTableTextFieldUnitCell")
            
            for subview in cell.contentView.subviews {
                if subview is UITextField {
                    subview.removeFromSuperview()
                }
            }
            
            // 创建文本框
            let textField = UITextField(frame: CGRect(x: 20, y: 10, width: kScreen_Width-40 , height: 50))
            textField.borderStyle = .roundedRect
            textField.placeholder = "请输入内容"
            textField.delegate = self
            roomNameTextField = textField
            roomNameTextField.addTarget(self, action: #selector(roomNameTextFieldChanged), for: .editingChanged)
            cell.backgroundColor = UIColor(red: 245.0/255, green: 245.0/255, blue: 245.0/255, alpha: 1.0)
            cell.contentView.addSubview(textField)
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RoomTableUnitCell") as? RoomTableUnitCell ?? RoomTableUnitCell(style: .value1, reuseIdentifier: "RoomTableUnitCell")
            
            let count = selectRooms[indexPath.section].count
            cell.backgroundColor = UIColor(red: 245.0/255, green: 245.0/255, blue: 245.0/255, alpha: 1.0)
            cell.name1.layer.cornerRadius = 6
            cell.name2.layer.cornerRadius = 6
            cell.name3.layer.cornerRadius = 6
            cell.name1.isHidden = true
            cell.name2.isHidden = true
            cell.name3.isHidden = true
            for i in 0..<count {
                if i%3 == 0 {
                    cell.refreshCellName1(name1: selectRooms[indexPath.section][i])
                    if let label = selectedViews[indexPath]?.first as? UILabel, label.text == (cell.name1.text) {
                        setLableStyle(label: cell.name1, isSelected: true)
                    } else {
                        setLableStyle(label: cell.name1, isSelected: false)
                    }
                    cell.name1.isHidden = false
                } else if i%3 == 1 {
                    cell.refreshCellName2(name2: selectRooms[indexPath.section][i])
                    if let label = selectedViews[indexPath]?.first as? UILabel, label.text == (cell.name2.text) {
                        setLableStyle(label: cell.name2, isSelected: true)
                    } else {
                        setLableStyle(label: cell.name2, isSelected: false)
                    }
                    cell.name2.isHidden = false
                } else if i%3 == 2 {
                    cell.refreshCellName3(name3: selectRooms[indexPath.section][i])
                    if let label = selectedViews[indexPath]?.first as? UILabel, label.text == (cell.name3.text) {
                        setLableStyle(label: cell.name3, isSelected: true)
                    } else {
                        setLableStyle(label: cell.name3, isSelected: false)
                    }
                    cell.name3.isHidden = false
                }
            }
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectRooms.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return selectTitle[section]
    }
    
    func didSelectView(in cell: RoomTableUnitCell, view: UIView) {
        let label = view as? UILabel
        if let label  {
            print("lable=\(String(describing: label.text))");
        } else {return}
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        selectedViews.removeAll()
        print("orgSelectedIndexPath=\(String(describing: orgSelectedIndexPath))")
        print("orgSelectedUILabel.text=\(String(describing: orgSelectedUILabel?.text))")
        if ((label!.text == orgSelectedUILabel?.text) && orgSelectedIndexPath != nil) {
            tableView.reloadRows(at: [orgSelectedIndexPath!], with: .none)
            orgSelectedIndexPath = nil
            orgSelectedUILabel = nil
            return
        }
        if orgSelectedIndexPath != nil {
            tableView.reloadRows(at: [orgSelectedIndexPath!], with: .none)
        }
        if var selected = selectedViews[indexPath] {
            if selected.contains(view) {
                selected.remove(view)
            } else {
                selected.insert(view)
            }
            selectedViews[indexPath] = selected
        } else {
            selectedViews[indexPath] = [view]
        }
        orgSelectedIndexPath = indexPath
        orgSelectedUILabel = label
        print("indexPath=\(indexPath)")
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @objc func createButtonTapped() {
        var roomName: String?
        
        if let customRoomName = roomNameTextField.text, !customRoomName.isEmpty {
            // 中文字符与英文字符都计算在内，一个字符算一个单位
            if customRoomName.count > 6 {
                let alert = UIAlertController(title: "提示", message: "名称最大长度为6", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "确定", style: .default)
                alert.addAction(okAction)
                present(alert, animated: true)
                return
            }
            roomName = customRoomName
        } else if let selectedLabel = orgSelectedUILabel {
            roomName = selectedLabel.text
        } else {
            // 如果用户没有选择或输入任何房间名称，则提示用户
            let alert = UIAlertController(title: "提示", message: "请选择或输入一个房间名称", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "确定", style: .default)
            alert.addAction(okAction)
            present(alert, animated: true)
            return
        }
        
        if let roomName = roomName, let roomCreatedCallback = roomCreatedCallback {
            roomCreatedCallback(roomName)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            tableView.contentInset = contentInsets
            tableView.scrollIndicatorInsets = contentInsets
                
                if let activeTextField = self.view.currentFirstResponder() as? UITextField {
                    let rect = activeTextField.convert(activeTextField.bounds, to: tableView)
                    tableView.scrollRectToVisible(rect, animated: true)
                }
            }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
    }
    
    private func setLableStyle(label:UILabel, isSelected:Bool) {
        if isSelected {
            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor(red: 0/255.0, green: 117/255.0, blue: 201/255.0, alpha: 1.0).cgColor
            label.textColor = UIColor(red: 0/255.0, green: 117/255.0, blue: 201/255.0, alpha: 1.0)
        } else {
            label.backgroundColor = .white
            label.layer.borderWidth = 0
            label.textColor = .black
        }
    }
    
}
//swift如何实现选中UITableView多个表格单元中的多个UIView对象中的某一个UIView对象？
protocol RoomTableUnitCellDelegate: AnyObject {
    func didSelectView(in cell: RoomTableUnitCell, view: UIView)
}
class RoomTableTextFieldUnitCell:UITableViewCell {
    private let borderView = UIView(frame: CGRect(x: 20, y: 20, width: kScreen_Width-40, height: 64))
    let textField = UITextField(frame: CGRect(x: 20, y: 20, width: 101, height: 44))
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    private func setupUI() {
        self.insertSubview(borderView, at: 0)
        borderView.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        textField.backgroundColor = .green
    }
}
class RoomTableUnitCell:UITableViewCell {
    private let borderView = UIView(frame: CGRect(x: 20, y: 10, width: kScreen_Width-40, height: 64))
    let name1 = UILabel()
    let name2 = UILabel()
    let name3 = UILabel()
    
    weak var delegate: RoomTableUnitCellDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    private func setupUI() {
        name1.frame = CGRect(x: 5, y: 5, width: 101, height: 44)
        name2.frame = CGRect(x: 5, y: 5, width: 101, height: 44)
        name3.frame = CGRect(x: 5, y: 5, width: 101, height: 44)
        //        name1.backgroundColor = .white
        //        name2.backgroundColor = .white
        //        name3.backgroundColor = .white
        contentView.insertSubview(borderView, at: 0)
        borderView.addSubview(name1)
        borderView.addSubview(name2)
        borderView.addSubview(name3)
        name1.textAlignment = .center
        name2.textAlignment = .center
        name3.textAlignment = .center
        name1.translatesAutoresizingMaskIntoConstraints = false
        name1.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(2)
            make.centerY.equalToSuperview()
        }
        NSLayoutConstraint.activate([
            name1.heightAnchor.constraint(equalToConstant: 44),
            name1.widthAnchor.constraint(equalToConstant: 101),
            name2.heightAnchor.constraint(equalToConstant: 44),
            name2.widthAnchor.constraint(equalToConstant: 101),
            name3.heightAnchor.constraint(equalToConstant: 44),
            name3.widthAnchor.constraint(equalToConstant: 101)
        ])
        name2.snp.makeConstraints { make in
            make.leading.equalTo(name1.snp.trailing).offset(20)
            make.centerY.equalToSuperview()
        }
        name3.snp.makeConstraints { make in
            make.leading.equalTo(name2.snp.trailing).offset(20)
            make.centerY.equalToSuperview()
        }
        name1.isUserInteractionEnabled = true
        let name1Gesture = UITapGestureRecognizer(target: self, action: #selector(name1GestureAction(gesture: )))
        name1.addGestureRecognizer(name1Gesture)
        
        let name2Gesture = UITapGestureRecognizer(target: self, action: #selector(name2GestureAction(gesture: )))
        name2.addGestureRecognizer(name2Gesture)
        name2.isUserInteractionEnabled = true
        
        let name3Gesture = UITapGestureRecognizer(target: self, action: #selector(name3GestureAction(gesture: )))
        name3.addGestureRecognizer(name3Gesture)
        name3.isUserInteractionEnabled = true
    }
    
    func refreshCell(name1:String, name2:String, name3:String) {
        self.name1.text = name1
        self.name2.text = name2
        self.name3.text = name3
    }
    
    func refreshCellName1(name1:String) {
        self.name1.text = name1
    }
    
    func refreshCellName2(name2:String) {
        self.name2.text = name2
    }
    
    func refreshCellName3(name3:String) {
        self.name3.text = name3
    }
    
    @objc private func name1GestureAction(gesture: UITapGestureRecognizer) {
        delegate?.didSelectView(in: self, view: gesture.view!)
    }
    
    @objc private func name2GestureAction(gesture: UITapGestureRecognizer) {
        delegate?.didSelectView(in: self, view: gesture.view!)
    }
    
    @objc private func name3GestureAction(gesture: UITapGestureRecognizer) {
        delegate?.didSelectView(in: self, view: gesture.view!)
    }
}

