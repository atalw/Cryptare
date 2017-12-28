//
//  CostBulletinPage.swift
//  Btc
//
//  Created by Akshit Talwar on 28/12/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import Foundation
import BulletinBoard
import Firebase

class  CostBulletinPage: NSObject, BulletinItem {
    
    var manager: BulletinManager?
    var isDismissable: Bool = true
    var dismissalHandler: ((BulletinItem) -> Void)?
    var nextItem: BulletinItem?
    
    let  dataSource: [String: Any]
    let dateFormatter = DateFormatter()
    
    var databaseRef: DatabaseReference!

    fileprivate var cost: UITextField?
    fileprivate var addButton: ContainerView<HighlightButton>?

    
    public let interfaceFactory = BulletinInterfaceFactory()
    public var actionHandler: ((BulletinItem) -> Void)? = nil
    
    init(coin: String, dataSource: [String: Any]) {
        
        self.dataSource = dataSource
        databaseRef = Database.database().reference().child(coin)

    }
    
    func makeArrangedSubviews() -> [UIView] {
        
        var arrangedSubviews = [UIView]()

        let titleLabel = interfaceFactory.makeTitleLabel(reading: "Add Transaction")
        arrangedSubviews.append(titleLabel)
        
        let descriptionLabel = interfaceFactory.makeDescriptionLabel(isCompact: true)
        let descriptionText = "Add a \(dataSource["type"]!) transaction for \(dataSource["coinAmount"]!) on \(dataSource["date"]!). How much did it cost?"
        descriptionLabel.text = descriptionText
        arrangedSubviews.append(descriptionLabel)

        let firstFieldStack = self.makeGroupStack()
        arrangedSubviews.append(firstFieldStack)
        
        let firstRowTitle = UILabel()
        firstRowTitle.numberOfLines = 1
        firstRowTitle.textAlignment = .left
        firstRowTitle.adjustsFontSizeToFitWidth = true
        firstRowTitle.font = UIFont.systemFont(ofSize: 18)
        firstRowTitle.text = "Cost (\(GlobalValues.currency!))"
        firstRowTitle.isAccessibilityElement = false
        firstFieldStack.addArrangedSubview(firstRowTitle)
        
        cost = UITextField()
        cost!.delegate = self
        cost!.borderStyle = .roundedRect
        cost!.returnKeyType = .done
        cost!.keyboardType = UIKeyboardType.decimalPad
        
        cost!.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        firstFieldStack.addArrangedSubview(cost!)
        
        addButton = interfaceFactory.makeActionButton(title: "Next")
        arrangedSubviews.append(addButton!)
        
        addButton?.contentView.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        addButton?.contentView.isEnabled = false
        
        // since there isn't a method similar to "viewDidAppear" for BulletinItems,
        // we're using a workaround open the keyboard after a certain amount of time has elapsed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            self?.cost?.becomeFirstResponder()
        }
        
        calculateCostFromDate()
        
        return arrangedSubviews
    }
    
    func tearDown() {
        
    }
    
    func calculateCostFromDate() {
        
        databaseRef.observeSingleEvent(of: .childAdded, with: {(snapshot) -> Void in
            if let dict = snapshot.value as? [String : AnyObject] {
                if let price = dict[GlobalValues.currency!]!["price"] as? Double {
                    let cost = price * (self.dataSource["coinAmount"] as! Double)
                    self.cost?.text = "\(cost)"
                }
            }
        })
    }
    
    public func makeGroupStack() -> UIStackView {
        
        let buttonsStack = UIStackView()
        buttonsStack.axis = .vertical
        buttonsStack.alignment = .fill
        buttonsStack.distribution = .fill
        buttonsStack.spacing = 5
        return buttonsStack
        
    }
    
    @objc private func addButtonTapped() {
        NotificationCenter.default.post(name: .TextFieldEntered, object: self, userInfo: ["type": dataSource["type"], "coinAmount": dataSource["coinAmount"], "date": dataSource["date"], "cost": cost?.text])
        manager?.dismissBulletin(animated: true)
    }
    
}

extension CostBulletinPage: UITextFieldDelegate {
    
    @objc func textFieldDidChange(textField: UITextField) {
        if !isInputValid(text: textField.text) {
            addButton?.contentView.isEnabled = false
        }
        else {
            addButton?.contentView.isEnabled = true
        }
    }
    
    func isInputValid(text: String?) -> Bool {
        // some logic here to verify input
        
        if text != nil && !text!.isEmpty {
            // return true to continue to the next bulletin item
            return true
        }
        
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textfield did end editing")
        if !isInputValid(text: textField.text) {
            addButton?.contentView.isEnabled = false
        }
        else {
            print("here")
            addButton?.contentView.isEnabled = true
        }
    }
    
    
}
