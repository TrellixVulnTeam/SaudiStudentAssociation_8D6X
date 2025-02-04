//
//  EventViewController.swift
//  SSUAkron
//
//  Created by Muhannad Mousa on 3/22/18.
//  Copyright © 2018 Muhannad Mousa. All rights reserved.
//

import UIKit
import Firebase

var currentUser = SaudiUser()
class EventViewController: UITableViewController {
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        showAlert(title: "ما غرض هذه الصفحة؟", message: "هذه الصفحة موجودة لعرض الفعاليات التي يعلن عنها النادي السعودي")
    }
    
    // MARK:-  Properties

    var events : [EventCellInfo]  = []
    private let cellID = "cell"
    lazy var colors :[String:UIColor] = {
        var dic = [String:UIColor]()
        dic["pink"] =  UIColor.init(red: 1, green: 0.7, blue: 0.7, alpha: 1)
        dic["white"] = .white
        dic["blue"] = .blue
        dic["orange"] = .orange
        dic["black"] = .black
        return dic
        
    }()
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(requestCalenderData), for: .valueChanged)
        return refreshControl
    }()
    
    lazy var timer : Timer = {
        let timer = Timer()
        return timer
    }()
    
    
    
    
    // MARK:-  UIViewController LifeCycle
      
    func updateStyle()  {
        self.navigationController?.navigationBar.largeTitleTextAttributes = [ .font: UIFont.notoKufiArabicLarge,  .foregroundColor : UIColor.white]
        if currentUser.job != "admin" {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(segueToEventPost))
        }
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "CardHighlightCell", bundle: nil), forCellReuseIdentifier: cellID)
        tableView.refreshControl = refresher
        addReloadingIndicator(for: 1)
        refreshCurrentUserInfo()
        requestCalenderData()
        updateNavBar()
        updateStyle()
    }
    
 
    
    @objc func segueToEventPost(){
        self.performSegue(withIdentifier: SegueTo.EventPost, sender: self)
    }
    
    
    // MARK: - Networking
  
    @objc func requestCalenderData() {
        events.removeAll()
        ref.child("Event").observe(.childAdded) { (snapshot) in
            
            let dic  = snapshot.value! as! [String: AnyObject]
            let card = EventCellInfo(dic)
//            card.cardId = snapshot.key
            
            self.events.insert(card, at: 0)
            self.timer.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.handleDataReload), userInfo: nil, repeats: false)
        }

//        self.events.sort{ $0.time?.intValue > $1.time?.intValue}
    }
    
    
    // MARK:- TableView Delegates
    
    @objc func handleDataReload(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.refresher.endRefreshing()
        })
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        cell.populate(for: self.events[indexPath.row])
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = EventInformation(event: self.events[indexPath.row])
        self.navigationController?.pushViewController(event, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}


// MARK: - UITableViewCell Extension


extension UITableViewCell{
    func populate(for event: EventCellInfo) {
        
        textLabel?.text = event.title
        textLabel?.font = .notoKufiBoldArabicMedium

        detailTextLabel?.text = event.catagory
        detailTextLabel?.font = .notoKufiArabicSmall

        imageView?.image = event.icon
        imageView?.clipsToBounds = true
    }
}
