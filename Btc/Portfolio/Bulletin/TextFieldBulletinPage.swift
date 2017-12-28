/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit
import BulletinBoard

/**
 * An item that displays a textfield.
 *
 * This item demonstrates how to create a bulletin item with a textfield and how it will behave when the keyboard is visible.
 */

class TextFieldBulletinPage: NSObject, BulletinItem {
    var manager: BulletinManager?
    var isDismissable: Bool = true
    var dismissalHandler: ((BulletinItem) -> Void)?
    var nextItem: BulletinItem?
    
    let dateFormatter = DateFormatter()
    
    
    public let interfaceFactory = BulletinInterfaceFactory()
    public var actionHandler: ((BulletinItem) -> Void)? = nil

    fileprivate var errorLabel: UILabel?
    fileprivate var amountOfBitcoin: UITextField?
    fileprivate var dateOfPurchase: UITextField?
    fileprivate var picker = UIDatePicker()
    fileprivate var date: String?
    fileprivate var toolbar = UIToolbar()
    fileprivate var done: UIBarButtonItem!
    fileprivate var addButton: ContainerView<HighlightButton>?
    
    public var descriptionText: String!

    func tearDown() {
        errorLabel = nil
        amountOfBitcoin = nil
        dateOfPurchase = nil
        done = nil
        addButton = nil
    }

    func makeArrangedSubviews() -> [UIView] {
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        var arrangedSubviews = [UIView]()
        createDatePicker()
        
        let titleLabel = interfaceFactory.makeTitleLabel(reading: "Add Transaction")
        arrangedSubviews.append(titleLabel)
        

        // Description Label
        
//        if let descriptionText = self.descriptionText {
//
//            let descriptionLabel = interfaceFactory.makeDescriptionLabel(isCompact: true)
//            descriptionLabel.text = descriptionText
//            arrangedSubviews.append(descriptionLabel)
//
//        }

//        errorLabel = interfaceFactory.makeDescriptionLabel(isCompact: true)
//        errorLabel!.text = ""
//        errorLabel!.textColor = .red
//        arrangedSubviews.append(errorLabel!)
        
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

        amountOfBitcoin = UITextField()
        amountOfBitcoin!.delegate = self
        amountOfBitcoin!.borderStyle = .roundedRect
        amountOfBitcoin!.returnKeyType = .done
        amountOfBitcoin!.keyboardType = UIKeyboardType.decimalPad
        firstFieldStack.addArrangedSubview(amountOfBitcoin!)
        
        let secondFieldStack = self.makeGroupStack()
        arrangedSubviews.append(secondFieldStack)
        
        let secondRowtitle = UILabel()
        secondRowtitle.numberOfLines = 1
        secondRowtitle.textAlignment = .left
        secondRowtitle.adjustsFontSizeToFitWidth = true
        secondRowtitle.font = UIFont.systemFont(ofSize: 18)
        secondRowtitle.text = "Date of purchase"
        secondRowtitle.isAccessibilityElement = false
        secondFieldStack.addArrangedSubview(secondRowtitle)
        
        dateOfPurchase = UITextField()
        dateOfPurchase!.delegate = self
        dateOfPurchase!.borderStyle = .roundedRect
        dateOfPurchase!.returnKeyType = .done
        dateOfPurchase!.inputView = picker
        dateOfPurchase!.inputAccessoryView = toolbar
        secondFieldStack.addArrangedSubview(dateOfPurchase!)
        
        addButton = interfaceFactory.makeActionButton(title: "Next")
        arrangedSubviews.append(addButton!)
        
        addButton?.contentView.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        addButton?.contentView.isEnabled = false

        // since there isn't a method similar to "viewDidAppear" for BulletinItems,
        // we're using a workaround open the keyboard after a certain amount of time has elapsed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            self?.amountOfBitcoin?.becomeFirstResponder()
        }

        return arrangedSubviews
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
//        NotificationCenter.default.post(name: .TextFieldEntered, object: self, userInfo: ["type": "buy", "amountOfBitcoin": amountOfBitcoin?.text, "dateOfPurchase": date])
        
        var dataSource: [String: Any] = [:]
        dataSource["type"] = "buy"
        dataSource["coinAmount"] = amountOfBitcoin?.text
        dataSource["date"] = date
        
        nextItem = CostBulletinPage(dataSource: dataSource)
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
    
//    func calculateCostFromDate() {
//        let dateOfPurchaseString = dateFormatter.string(from: dateOfPurchase)
//        let todaysDateString = dateFormatter.string(from: Date())
//        
//        else {
//            let url = URL(string: "https://api.coindesk.com/v1/bpi/historical/close.json?currency=\(GlobalValues.currency!)&start=\(dateOfPurchaseString)&end=\(dateOfPurchaseString)")!
//            
//            Alamofire.request(url).responseJSON(completionHandler: { response in
//                
//                let json = JSON(data: response.data!)
//                if let price = json["bpi"][dateOfPurchaseString].double {
//                    self.cost = price * self.coinAmount
//                }
//            })
//        }
//        
//    }

}

extension TextFieldBulletinPage: UITextFieldDelegate {

    @objc func donePressed() {
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let dateString = dateFormatter.string(from: picker.date)
        dateOfPurchase!.text = dateString
        
        dateFormatter.dateFormat = "YYYY-MM-dd"
        date = dateFormatter.string(from: picker.date)
        
        dateOfPurchase?.endEditing(true)
        
        if isInputValid(text: amountOfBitcoin?.text) {
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if isInputValid(text: amountOfBitcoin?.text) && isInputValid(text: dateOfPurchase?.text){
//            textField.resignFirstResponder()
//            NotificationCenter.default.post(name: .TextFieldEntered, object: self, userInfo: ["amountOfBitcoin": amountOfBitcoin?.text, "dateOfPurchase": dateOfPurchase?.text])
//            actionHandler?(self)
//            return true
//
//        } else {
//            errorLabel?.text = "You must enter some text to continue."
//            textField.backgroundColor = .red
//            return false
//        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !isInputValid(text: textField.text) {
            addButton?.contentView.isEnabled = false
        }
    }
    
    
}
