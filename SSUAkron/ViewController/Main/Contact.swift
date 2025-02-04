//
//  ViewController.swift
//  SSUAkron
//
//  Created by Muhannad Mousa on 3/15/18.
//  Copyright © 2018 Muhannad Mousa. All rights reserved.
//

import UIKit
import MapKit
import FirebaseFirestore
import FirebaseUI

class ContactViewController: UICollectionViewController{
    
    // MARK: Properties
    
    lazy var cellWidth :CGFloat = (self.view.bounds.width / 2) - 20
    lazy var timer = Timer()
    var roaster = [SaudiUser]()
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.blueSSA
        refreshControl.addTarget(self, action: #selector(requestMembersData), for: .valueChanged)
        return refreshControl
        
    }()
    
    
    // MARK: ViewControlelr Life Cycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(UINib(nibName: "ContactCardCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView?.refreshControl = refresher
        requestMembersData()
        updateNavBar()
        
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "outline_account_circle_black_18dp"), style: .plain, target: self, action: #selector(segueToPersonalProfile))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        
        let button = UIButton(type: .system)
        button.setTitle("IUPUI", for: .normal)
        button.titleLabel?.font = .notoKufiBoldArabicMedium
        button.setImage(#imageLiteral(resourceName: "icons8-expand-arrow-96-2"), for: .normal)
        button.imageView?.anchor(trailing: button.titleLabel?.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 2), size: .init(width: 17, height: 17))
        button.addTarget(self, action: #selector(selectUniversity), for: .touchUpInside)
        
        let stackview = UIStackView(arrangedSubviews:  [button])
        stackview.axis = .horizontal
        stackview.distribution = .fill
        stackview.alignment = .center
        stackview.spacing = 4
        
        self.navigationItem.titleView = stackview
        
      

    }
    

    
    // MARK: Handlers
    

    @IBAction func infoButtonTapped(_ sender: Any) {
            showAlert(title: "ما غرض هذه الصفحة؟", message: "كثير منا ما يعرف مين هم القائمين على النادي السعودي، هذه الصفحة غرضها معرفة لائحة النادي وطريقة التواصل معاهم")
    }
    
    
    @objc func requestMembersData() {
        addReloadingIndicator(for: 1)
        
        roaster.removeAll()
        Firestore.firestore().collection("SSA").whereField("name", isEqualTo: "ssa").getDocuments { (snapshot, err) in
            guard let dictionary = snapshot?.documents.first?.data() else {return}
            
            
            let orginizers = dictionary["orginizer"] as! [String]
            print("orginizers: ", orginizers)
            
            
            orginizers.forEach({
                Firestore.firestore().collection("Users").whereField("uid", isEqualTo: $0).getDocuments(completion: { (snapshot2, error) in
                    snapshot2?.documents.forEach({
                        print($0)
                    })
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    if let rosterMemeber = snapshot2?.documents.first?.data() {
                        self.roaster.append(SaudiUser(rosterMemeber))
                    }
                    self.collectionView?.reloadData()
                })
            })
        }
        
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.handleDataReload), userInfo: nil, repeats: false)
        
    }
    
    @objc func handleDataReload(){
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.refresher.endRefreshing()
        })
    }
    
    
    @objc func selectUniversity(){
        showAlert(title: "هذه الخاصية محدودة حالياًَ", message: "نوادي سعودية اخرى ستضاف مع الوقت .. خبروا جماعتكم")
    }
    @objc func segueToPersonalProfile()  {
        performSegue(withIdentifier: SegueTo.PersonalProfile, sender: self)
    }
    @objc func handleLogOut()  {
        do{
            try Auth.auth().signOut()
            let userDefault = UserDefaults.standard
            userDefault.set(false, forKey: "loggedIn")
            let vc = LoginViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            justLoggedOut = true
            
        }catch let error as NSError{
            print(error)
        }
    }
}


// MARK: - CollectionView Delegate



extension ContactViewController: UICollectionViewDelegateFlowLayout{
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roaster.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ContactCardCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ContactCardCell
        
        let user = roaster[indexPath.row]
        cell.nameLabel.text = user.name
        cell.jobLabel.text = user.job ?? " "
        cell.imageView.sd_setImage(with: URL(string: user.imageLink), placeholderImage: #imageLiteral(resourceName: "Unknown_Person"))
        cell.whatsAppNumber = user.phoneNumber
        cell.update()
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellWidth, height: cellWidth * 1.75)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 10, left: 12.5, bottom: 10, right: 12.5)
    }

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12.5
    }
}
