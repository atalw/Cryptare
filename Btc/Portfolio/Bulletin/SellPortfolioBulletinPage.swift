//
//  SellPortfolioBulletinPage.swift
//  Btc
//
//  Created by Akshit Talwar on 22/11/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import BulletinBoard

/**
 * An item that displays a textfield.
 *
 * This item demonstrates how to create a bulletin item with a textfield and how it will behave when the keyboard is visible.
 */

class SellPortfolioBulletinPage: NSObject, BulletinItem {
    var manager: BulletinManager?
    var isDismissable: Bool = true
    var dismissalHandler: ((BulletinItem) -> Void)?
    var nextItem: BulletinItem?
    
    let dateFormatter = DateFormatter()
    let coin: String
    
    public let interfaceFactory = BulletinInterfaceFactory()
    public var actionHandler: ((BulletinItem) -> Void)? = nil
    
    fileprivate var coinAmount: UITextField?
    fileprivate var dateOfSale: UITextField?
    fileprivate var picker = UIDatePicker()
    fileprivate var date: String?
    fileprivate var toolbar = UIToolbar()
    fileprivate var done: UIBarButtonItem!
    fileprivate var addButton: ContainerView<HighlightButton>?
    
    init(coin: String) {
        self.coin = coin
    }
    
    func makeArrangedSubviews() -> [UIView] {
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        var arrangedSubviews = [UIView]()
        createDatePicker()
        
        let titleLabel = interfaceFactory.makeTitleLabel(reading: "Sell Transaction")
        arrangedSubviews.append(titleLabel)
        
        let firstFieldStack = self.makeGroupStack()
        arrangedSubviews.append(firstFieldStack)
        
        let firstRowTitle = UILabel()
        firstRowTitle.numberOfLines = 1
        firstRowTitle.textAlignment = .left
        firstRowTitle.adjustsFontSizeToFitWidth = true
        firstRowTitle.font = UIFont.systemFont(ofSize: 18)
        firstRowTitle.text = "Coin Amount"
        firstRowTitle.isAccessibilityElement = false
        firstFieldStack.addArrangedSubview(firstRowTitle)
        
        coinAmount = UITextField()
        coinAmount!.delegate = self
        coinAmount!.borderStyle = .roundedRect
        coinAmount!.returnKeyType = .done
        coinAmount!.keyboardType = UIKeyboardType.decimalPad
        firstFieldStack.addArrangedSubview(coinAmount!)
        
        let secondFieldStack = self.makeGroupStack()
        arrangedSubviews.append(secondFieldStack)
        
        let secondRowtitle = UILabel()
        secondRowtitle.numberOfLines = 1
        secondRowtitle.textAlignment = .left
        secondRowtitle.adjustsFontSizeToFitWidth = true
        secondRowtitle.font = UIFont.systemFont(ofSize: 18)
        secondRowtitle.text = "Date of sale"
        secondRowtitle.isAccessibilityElement = false
        secondFieldStack.addArrangedSubview(secondRowtitle)
        
        dateOfSale = UITextField()
        dateOfSale!.delegate = self
        dateOfSale!.borderStyle = .roundedRect
        dateOfSale!.returnKeyType = .done
        dateOfSale!.inputView = picker
        dateOfSale!.inputAccessoryView = toolbar
        secondFieldStack.addArrangedSubview(dateOfSale!)
        
        addButton = interfaceFactory.makeActionButton(title: "Next")
        arrangedSubviews.append(addButton!)
        
        addButton?.contentView.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        addButton?.contentView.isEnabled = false
        
        // since there isn't a method similar to "viewDidAppear" for BulletinItems,
        // we're using a workaround open the keyboard after a certain amount of time has elapsed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            self?.coinAmount?.becomeFirstResponder()
        }
        
        return arrangedSubviews
    }
    
    func tearDown() {
        addButton?.contentView.removeTarget(self, action: nil, for: .touchUpInside)
        
        coinAmount = nil
        dateOfSale = nil
        done = nil
        addButton = nil
    }
    
    func createDatePicker() {
        toolbar.sizeToFit()
        
        done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, done], animated: false)
        
        picker.datePickerMode = .date
        picker.maximumDate = Date()
        picker.minimumDate = dateFormatter.date(from: "2009-1-1")
    }
    
    @objc private func addButtonTapped() {
        
        var dataSource: [String: Any] = [:]
        dataSource["type"] = "sell"
        dataSource["coinAmount"] = Double(coinAmount!.text!)
        dataSource["date"] = date
        
        nextItem = CostBulletinPage(coin: coin, dataSource: dataSource)
        displayNextItem()
    }
    
    public func makeGroupStack() -> UIStackView {
        
        let buttonsStack = UIStackView()
        buttonsStack.axis = .vertical
        buttonsStack.alignment = .fill
        buttonsStack.distribution = .fill
        buttonsStack.spacing = 5
        return buttonsStack
        
    }
    
}

extension SellPortfolioBulletinPage: UITextFieldDelegate {
    
    @objc func donePressed() {
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let dateString = dateFormatter.string(from: picker.date)
        dateOfSale!.text = dateString
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        date = dateFormatter.string(from: picker.date)
        
        dateOfSale?.endEditing(true)
        
        if isInputValid(text: coinAmount?.text) {
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
        if isInputValid(text: coinAmount?.text) && isInputValid(text: dateOfSale?.text) {
            addButton?.contentView.isEnabled = true
        }
        else {
            addButton?.contentView.isEnabled = false
        }
    }
    
    
}

