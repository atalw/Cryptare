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

public enum NetworkResponseStatus {
    case success
    case error(string: String?)
}


class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var allNewsData : [NewsData] = [];
    
    @IBAction func refreshButton(_ sender: Any) {
        self.allNewsData = []
        self.tableView.reloadData()
        self.getRSSFeedResponse(path: "https://news.google.com/news/rss/search/section/q/bitcoin%20india/bitcoin%20india?hl=en&ned=us") { (rssFeed: RSSFeed?, status: NetworkResponseStatus) in
            for item in (rssFeed?.items)! {
                var newsData = NewsData(title: item.title!, pubDate: item.pubDate!, link: item.link!)
                self.allNewsData.append(newsData)
            }
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.reloadData()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.getRSSFeedResponse(path: "https://news.google.com/news/rss/search/section/q/bitcoin%20india/bitcoin%20india?hl=en&ned=us") { (rssFeed: RSSFeed?, status: NetworkResponseStatus) in
            for item in (rssFeed?.items)! {
                var newsData = NewsData(title: item.title!, pubDate: item.pubDate!, link: item.link!)
                self.allNewsData.append(newsData)
            }
            self.tableView.dataSource = self
            self.tableView.delegate = self
            self.tableView.reloadData()
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: Notification.Name.UIApplicationWillResignActive, object: nil)

    }
    
    func appMovedToBackground() {
        if let row = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: row, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let entry = allNewsData[indexPath.row]
        cell.title.text = entry.title
        
        let timeInMilliSeconds = entry.pubDate.timeIntervalSinceNow
        let time = floor(abs(timeInMilliSeconds)/3600)
        let intTime = Int(time)
        if time < 24 {
            cell.pubDate.text = "\(intTime)h ago"
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

