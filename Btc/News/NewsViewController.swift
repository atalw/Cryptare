//
//  SecondViewController.swift
//  Btc
//
//  Created by Akshit Talwar on 02/07/2017.
//  Copyright © 2017 atalw. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireRSSParser
import Armchair
import SwiftyUserDefaults

public enum NetworkResponseStatus {
  case success
  case error(string: String?)
}

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  let defaults = UserDefaults.standard
  var selectedCountry: String!
  var allNewsData : [NewsData] = [];
  var sortedNewsData : [NewsData] = [];
  
  var cryptoName: String! = "cryptocurrency"
  var coin: String! = "cryptocurrency"
  
  let marketRowColour : UIColor = UIColor.white
  let alternateMarketRowColour: UIColor = UIColor.init(hex: "e6ecf1")
  let sortButtonSelectedColour: UIColor = UIColor.init(hex: "46637F")
  
  lazy var activityIndicator: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView()
    activityIndicator.theme_activityIndicatorViewStyle = GlobalPicker.activityIndicatorColor
    activityIndicator.center = tableView.center
    activityIndicator.center.y -= 150
    activityIndicator.hidesWhenStopped = true
    tableView.addSubview(activityIndicator)
    
    return activityIndicator
  }()
  
  @IBOutlet weak var tableView: UITableView! {
    didSet {
      tableView.dataSource = self
      tableView.delegate = self
    }
  }
  @IBOutlet weak var countryButton: UIButton! {
    didSet {
      countryButton.setTitleColor(UIColor.white, for: .selected)
      countryButton.isSelected = true
      countryButton.addTarget(self, action: #selector(newsButtonTapped), for: .touchUpInside)
      countryButton.theme_tintColor = GlobalPicker.sortButtonSelectedColor
    }
  }
  @IBOutlet weak var worldwideButton: UIButton! {
    didSet {
      worldwideButton.setTitleColor(UIColor.white, for: .selected)
      worldwideButton.isSelected = false
      worldwideButton.addTarget(self, action: #selector(newsButtonTapped), for: .touchUpInside)
      worldwideButton.theme_tintColor = GlobalPicker.sortButtonSelectedColor
    }
  }
  @IBOutlet weak var sortPopularityButton: UIButton! {
    didSet {
      sortPopularityButton.titleLabel?.adjustsFontSizeToFitWidth = true
      sortPopularityButton.layer.cornerRadius = 5
      sortPopularityButton.isSelected = true
      sortPopularityButton.addTarget(self, action: #selector(sortPopularityButtonTapped), for: .touchUpInside)
      sortPopularityButton.theme_setTitleColor(GlobalPicker.sortButtonTextSelectedColor, forState: .selected)
      sortPopularityButton.theme_setTitleColor(GlobalPicker.sortButtonTextNotSelectedColor, forState: .normal)
      
    }
  }
  @IBOutlet weak var sortDateButton: UIButton! {
    didSet {
      sortDateButton.titleLabel?.adjustsFontSizeToFitWidth = true
      sortDateButton.layer.cornerRadius = 5
      sortDateButton.isSelected = false
      sortDateButton.addTarget(self, action: #selector(sortDateButtonTapped), for: .touchUpInside)
      sortDateButton.theme_setTitleColor(GlobalPicker.sortButtonTextSelectedColor, forState: .selected)
      sortDateButton.theme_setTitleColor(GlobalPicker.sortButtonTextNotSelectedColor, forState: .normal)
    }
  }
  
  @IBOutlet weak var sortByLabel: UILabel! {
    didSet {
      sortByLabel.theme_textColor = GlobalPicker.viewAltTextColor
    }
  }
  
  @IBAction func refreshButton(_ sender: Any) {
    self.getNews()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Armchair.userDidSignificantEvent(true)
    
    self.view.theme_backgroundColor = GlobalPicker.mainBackgroundColor
    self.tableView.theme_backgroundColor = GlobalPicker.mainBackgroundColor
    
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
    
    self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.selectedCountry = Defaults[.selectedCountry]
    
    if self.selectedCountry == "australia" {
      self.countryButton.setTitle("🇦🇺", for: .normal)
    }
    else if self.selectedCountry == "brazil" {
      self.countryButton.setTitle("🇧🇷", for: .normal)
    }
    else if self.selectedCountry == "canada" {
      self.countryButton.setTitle("🇨🇦", for: .normal)
    }
    else if self.selectedCountry == "switzerland" {
      self.countryButton.setTitle("🇨🇭", for: .normal)
    }
    else if self.selectedCountry == "chile" {
      self.countryButton.setTitle("🇨🇱", for: .normal)
    }
    else if self.selectedCountry == "china" {
      self.countryButton.setTitle("🇨🇳", for: .normal)
    }
    else if self.selectedCountry == "czech" {
      self.countryButton.setTitle("🇨🇿", for: .normal)
    }
    else if self.selectedCountry == "denmark" {
      self.countryButton.setTitle("🇩🇰", for: .normal)
    }
    else if self.selectedCountry == "eu" {
      self.countryButton.setTitle("🇪🇺", for: .normal)
    }
    else if self.selectedCountry == "uk" {
      self.countryButton.setTitle("🇬🇧", for: .normal)
    }
    else if self.selectedCountry == "hongkong" {
      self.countryButton.setTitle("🇭🇰", for: .normal)
    }
    else if self.selectedCountry == "hungary" {
      self.countryButton.setTitle("🇭🇺", for: .normal)
    }
    else if self.selectedCountry == "indonesia" {
      self.countryButton.setTitle("🇮🇩", for: .normal)
    }
    else if self.selectedCountry == "israel" {
      self.countryButton.setTitle("🇮🇱", for: .normal)
    }
    else if self.selectedCountry == "india" {
      self.countryButton.setTitle("🇮🇳", for: .normal)
    }
    else if self.selectedCountry == "japan" {
      self.countryButton.setTitle("🇯🇵", for: .normal)
    }
    else if self.selectedCountry == "korea" {
      self.countryButton.setTitle("🇰🇷", for: .normal)
    }
    else if self.selectedCountry == "mexico" {
      self.countryButton.setTitle("🇲🇽", for: .normal)
    }
    else if self.selectedCountry == "malaysia" {
      self.countryButton.setTitle("🇲🇾", for: .normal)
    }
    else if self.selectedCountry == "norway" {
      self.countryButton.setTitle("🇳🇴", for: .normal)
    }
    else if self.selectedCountry == "newzealand" {
      self.countryButton.setTitle("🇳🇿", for: .normal)
    }
    else if self.selectedCountry == "philippines" {
      self.countryButton.setTitle("🇵🇭", for: .normal)
    }
    else if self.selectedCountry == "pakistan" {
      self.countryButton.setTitle("🇵🇰", for: .normal)
    }
    else if self.selectedCountry == "poland" {
      self.countryButton.setTitle("🇵🇱", for: .normal)
    }
    else if self.selectedCountry == "russia" {
      self.countryButton.setTitle("🇷🇺", for: .normal)
    }
    else if self.selectedCountry == "sweden" {
      self.countryButton.setTitle("🇸🇪", for: .normal)
    }
    else if self.selectedCountry == "singapore" {
      self.countryButton.setTitle("🇸🇬", for: .normal)
    }
    else if self.selectedCountry == "thailand" {
      self.countryButton.setTitle("🇹🇭", for: .normal)
    }
    else if self.selectedCountry == "turkey" {
      self.countryButton.setTitle("🇹🇷", for: .normal)
    }
    else if self.selectedCountry == "taiwan" {
      self.countryButton.setTitle("🇹🇼", for: .normal)
    }
    else if self.selectedCountry == "usa" {
      self.countryButton.setTitle("🇺🇸", for: .normal)
    }
    else if self.selectedCountry == "southafrica" {
      self.countryButton.setTitle("🇿🇦", for: .normal)
    }
    
    FirebaseService.shared.news_view_appeared(coin: coin, country: selectedCountry)
    
    getNews()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    FirebaseService.shared.updateScreenName(screenName: "News", screenClass: "NewsViewController")

  }
  
  @objc func newsButtonTapped() {
    countryButton.isSelected = !self.countryButton.isSelected
    worldwideButton.isSelected = !self.worldwideButton.isSelected
    getNews()
  }
  
  @objc func sortPopularityButtonTapped() {
    activityIndicator.startAnimating()
    
    sortPopularityButton.isSelected = true
    sortDateButton.isSelected = false
    
    sortPopularityButton.theme_backgroundColor = GlobalPicker.sortButtonSelectedColor
    sortDateButton.theme_backgroundColor = GlobalPicker.sortButtonNotSelectedColor
    
    activityIndicator.stopAnimating()
    tableView.reloadData()
    tableView.setContentOffset(CGPoint.zero, animated: true)
  }
  
  @objc func sortDateButtonTapped() {
    activityIndicator.startAnimating()
    
    sortPopularityButton.isSelected = false
    sortDateButton.isSelected = true
    
    sortDateButton.theme_backgroundColor = GlobalPicker.sortButtonSelectedColor
    sortPopularityButton.theme_backgroundColor = GlobalPicker.sortButtonNotSelectedColor
    
    activityIndicator.stopAnimating()
    tableView.reloadData()
    tableView.setContentOffset(CGPoint.zero, animated: true)
  }
  
  func getNews() {
    self.allNewsData = []
    self.tableView.reloadData()
    
    if defaults.string(forKey: "newsSort") == "popularity" {
      sortPopularityButton.sendActions(for: .touchUpInside)
    }
    else {
      sortDateButton.sendActions(for: .touchUpInside)
    }
    
    if (self.countryButton.isSelected) {
      self.getCountryNews()
    }
    else if (self.worldwideButton.isSelected) {
      self.getWorldwideNews()
    }
    
  }
  
  @objc func appMovedToBackground() {
    if let row = self.tableView.indexPathForSelectedRow {
      self.tableView.deselectRow(at: row, animated: false)
    }
  }
  
  func getCountryNews() {
    self.activityIndicator.startAnimating()

    var url: String! = "https://news.google.com/news/rss/search/section/q/\(cryptoName!) \(self.selectedCountry!)?hl=en&ned=us"
    
    url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    self.getRSSFeedResponse(path: url) { (rssFeed: RSSFeed?, status: NetworkResponseStatus) in
      
      #if PRO_VERSION
      if let items = rssFeed?.items {
        for item in items {
          let newsData = NewsData(title: item.title!, pubDate: item.pubDate!, link: item.link!)
          self.allNewsData.append(newsData)
        }
      }
      
      #endif
      
      self.sortedNewsData = self.sortNewsDataByDate(newsData: self.allNewsData)
      self.activityIndicator.stopAnimating()
      self.tableView.reloadData()
      self.tableView.setContentOffset(CGPoint.zero, animated: true)
    }
  }
  
  func getWorldwideNews() {
    self.activityIndicator.startAnimating()

    var url: String! = "https://news.google.com/news/rss/search/section/q/\(cryptoName!)/\(cryptoName!)?hl=en&ned=us"
    
    url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    
    self.getRSSFeedResponse(path: url) { (rssFeed: RSSFeed?, status: NetworkResponseStatus) in
      #if PRO_VERSION
      if let items = rssFeed?.items {
        for item in items {
          let newsData = NewsData(title: item.title!, pubDate: item.pubDate!, link: item.link!)
          self.allNewsData.append(newsData)
        }
      }
      
      #endif
      
      self.sortedNewsData = self.sortNewsDataByDate(newsData: self.allNewsData)
      self.activityIndicator.stopAnimating()
      self.tableView.reloadData()
      self.tableView.setContentOffset(CGPoint.zero, animated: true)
    }
  }
  
  func sortNewsDataByDate(newsData: [NewsData]) -> [NewsData] {
    let sortedData = newsData
    return sortedData.sorted(by: {$0.pubDate.compare($1.pubDate) == .orderedDescending})
  }
  
  
  public func getRSSFeedResponse(path: String, completionHandler: @escaping (_ response: RSSFeed?,_ status: NetworkResponseStatus) -> Void) {
    Alamofire.request(path).responseRSS() { response in
      if let rssFeedXML = response.result.value {
        // Successful response - process the feed in your completion handler
        completionHandler(rssFeedXML, .success)
      } else {
        // There was an error, so feel free to handle it in your completion handler
        completionHandler(nil, .error(string: response.result.error?.localizedDescription))
      }
    }
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int{
    return 1;
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->  Int {
    return allNewsData.count
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! CustomNewsTableViewCell
    var entry: NewsData!
    if sortPopularityButton.isSelected {
      entry = allNewsData[indexPath.row]
    }
    else {
      entry = sortedNewsData[indexPath.row]
    }
    cell.title.text = entry.title
    
    let timeInMilliSeconds = entry.pubDate.timeIntervalSinceNow
    let time = floor(abs(timeInMilliSeconds)/3600)
    let intTime = Int(time)
    if time < 24 {
      cell.pubDate.text = "\(intTime)h ago"
    }
    else if time >= 24 && time < 48 {
      cell.pubDate.text = "1 day ago"
    }
    else if time >= 48 && time < 72 {
      cell.pubDate.text = "2 days ago"
    }
    else if time >= 72 && time < 96 {
      cell.pubDate.text = "3 days ago"
    }
    else if time >= 96 && time < 120 {
      cell.pubDate.text = "4 days ago"
    }
    else if time >= 120 && time < 144 {
      cell.pubDate.text = "5 days ago"
    }
    else if time >= 144 && time < 168 {
      cell.pubDate.text = "6 days ago"
    }
    else if time >= 168 && time < 336 {
      cell.pubDate.text = "1 week ago"
    }
    else {
      let dateString = entry.pubDate.description
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
      if let date = dateFormatter.date(from: dateString) {
        dateFormatter.dateFormat = "dd/MM/yy"
        cell.pubDate.text = dateFormatter.string(from: date)
      }
    }
    
    cell.link = entry.link
    return cell
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
    cell.selectionStyle = .none
    
    let row = indexPath.row
    if row % 2 == 0 {
      cell.theme_backgroundColor = GlobalPicker.mainBackgroundColor
    }
    else {
      cell.theme_backgroundColor = GlobalPicker.alternateMarketRowColour
    }
  }
  
  func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    
    cell.theme_backgroundColor = GlobalPicker.viewSelectedBackgroundColor
  }
  
  func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    let row = indexPath.row

    if row % 2 == 0 {
      cell.theme_backgroundColor = GlobalPicker.mainBackgroundColor
    }
    else {
      cell.theme_backgroundColor = GlobalPicker.alternateMarketRowColour
    }
  }
  
}
