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
import Hero

public enum NetworkResponseStatus {
    case success
    case error(string: String?)
}


class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indiaButton: UIButton!
    @IBOutlet weak var worldwideButton: UIButton!
    @IBOutlet weak var sortPopularityButton: UIButton!
    @IBOutlet weak var sortDateButton: UIButton!
    
    let defaults = UserDefaults.standard
    var selectedCountry: String!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var allNewsData : [NewsData] = [];
    var sortedNewsData : [NewsData] = [];
    
    @IBAction func refreshButton(_ sender: Any) {
        self.getNews()
    }
    
    #if LITE_VERSION
        @IBAction func upgradeButton(_ sender: Any) {
            UIApplication.shared.openURL(URL(string: "https://itunes.apple.com/app/id1266256984")!)
        }
    #endif

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.selectedCountry = self.defaults.string(forKey: "selectedCountry")
        
        if self.selectedCountry == "india" {
            self.indiaButton.setTitle("🇮🇳", for: .normal)
        }
        else if self.selectedCountry == "usa" {
            self.indiaButton.setTitle("🇺🇸", for: .normal)
        }
        
        self.indiaButton.setTitleColor(UIColor.white, for: .selected)
        self.worldwideButton.setTitleColor(UIColor.white, for: .selected)
        
        self.indiaButton.isSelected = true
        self.worldwideButton.isSelected = false
        
        self.sortPopularityButton.layer.cornerRadius = 5
        self.sortDateButton.layer.cornerRadius = 5
        self.sortPopularityButton.backgroundColor = UIColor.lightGray

        self.sortPopularityButton.isSelected = true
        self.sortDateButton.isSelected = false
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)

        self.getNews()
        
        self.indiaButton.addTarget(self, action: #selector(newsButtonTapped), for: .touchUpInside)
        self.worldwideButton.addTarget(self, action: #selector(newsButtonTapped), for: .touchUpInside)

        self.sortPopularityButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        self.sortDateButton.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)


        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        self.addLeftBarButtonWithImage(UIImage(named: "icons8-menu")!)
    }
    
    @objc func newsButtonTapped() {
        indiaButton.isSelected = !self.indiaButton.isSelected
        worldwideButton.isSelected = !self.worldwideButton.isSelected
        getNews()
    }
    
    @objc func sortButtonTapped() {
        activityIndicator.startAnimating()
        sortPopularityButton.isSelected = !self.sortPopularityButton.isSelected
        sortDateButton.isSelected = !self.sortDateButton.isSelected
        if sortPopularityButton.isSelected {
            sortPopularityButton.backgroundColor = UIColor.lightGray
            sortDateButton.backgroundColor = UIColor.white
        }
        else if sortDateButton.isSelected {
            sortDateButton.backgroundColor = UIColor.lightGray
            sortPopularityButton.backgroundColor = UIColor.white
        }
        activityIndicator.stopAnimating()
        tableView.reloadData()
        tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func getNews() {
        self.allNewsData = []
        self.tableView.reloadData()
        self.activityIndicator.startAnimating()

        if (self.indiaButton.isSelected) {
            self.getIndiaNews()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getIndiaNews() {
        var url: String! = "https://news.google.com/news/rss/search/section/q/bitcoin%20india/bitcoin%20india?hl=en&ned=us"
        
        if self.selectedCountry == "india" {
            url = "https://news.google.com/news/rss/search/section/q/bitcoin%20india/bitcoin%20india?hl=en&ned=us"
        }
        else if self.selectedCountry == "usa" {
            url = "https://news.google.com/news/rss/search/section/q/bitcoin%20usa/bitcoin%20usa?hl=en&ned=us"
        }
        self.getRSSFeedResponse(path: url) { (rssFeed: RSSFeed?, status: NetworkResponseStatus) in
            
            #if PRO_VERSION
                for item in (rssFeed?.items)! {
                    let newsData = NewsData(title: item.title!, pubDate: item.pubDate!, link: item.link!)
                    self.allNewsData.append(newsData)
                }
            #endif
        
            #if LITE_VERSION
                for index in 0..<10 {
                    if let item = rssFeed?.items[index] {
                        let newsData = NewsData(title: item.title!, pubDate: item.pubDate!, link: item.link!)
                        self.allNewsData.append(newsData)
                    }
                }
                let updateNewsCell = NewsData(title: "Upgrade to view more of the latest news", pubDate: Date(), link: "https://itunes.apple.com/app/id1266256984")
                self.allNewsData.append(updateNewsCell)
            #endif
            
            self.sortedNewsData = self.sortNewsDataByDate(newsData: self.allNewsData)
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    func getWorldwideNews() {
        self.getRSSFeedResponse(path: "https://news.google.com/news/rss/search/section/q/bitcoin/bitcoin?hl=en&ned=us") { (rssFeed: RSSFeed?, status: NetworkResponseStatus) in
            #if PRO_VERSION
                for item in (rssFeed?.items)! {
                    let newsData = NewsData(title: item.title!, pubDate: item.pubDate!, link: item.link!)
                    self.allNewsData.append(newsData)
                }
            #endif
            
            #if LITE_VERSION
                for index in 0..<10  {
                    if let item = rssFeed?.items[index] {
                        let newsData = NewsData(title: item.title!, pubDate: item.pubDate!, link: item.link!)
                        self.allNewsData.append(newsData)
                    }
                }
                let updateNewsCell = NewsData(title: "Upgrade to view more of the latest news", pubDate: Date(), link: "https://itunes.apple.com/app/id1266256984")
                self.allNewsData.append(updateNewsCell)
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

}