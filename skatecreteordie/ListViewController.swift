//
//  ListViewController.swift
//  skatecreteordie
//
//  Created by JAMES K ARASIM on 3/26/16.
//  Copyright 2016-2024 jaemzware llc
//  Licensed under the Apache License, Version 2.0
//
import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var locationGroupArray = [String]() //["ID", "MT", "BOZEMAN", "HELENA"]
    var mvcLocationGroupOrderedSkateParks: [SkatePark] = []
    
    @IBOutlet var parkListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register the table view cell class and its reuse id
        self.parkListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LocationGroupCell")
        // Register the custom header view.
        self.parkListTableView.register(MyCustomHeader.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        // This view controller itself will provide the delegate methods and row data for the table view.
        parkListTableView.delegate = self
        parkListTableView.dataSource = self
        // Get the skateparks from the first view controller, and sort them by group, then name ascending
        let mvc = self.tabBarController!.viewControllers![0] as! MapViewController
        mvcLocationGroupOrderedSkateParks = mvc.skateParks.sorted {
            ($0.group!, $0.name!) < ($1.group!, $1.name!)
        }
    }
    
    //number of sections - number of unique location groups (WA, OR, ID, CA, MT, DK). this also builds the locationGroupDictinoary
    func numberOfSections(in tableView: UITableView) -> Int {
        //wa,or,id,mt,ca,dk
        for skatepark in 0...mvcLocationGroupOrderedSkateParks.count-1 {
            if let skateParkLocationGroup = mvcLocationGroupOrderedSkateParks[skatepark].group {
                if !locationGroupArray.contains(skateParkLocationGroup){
                    locationGroupArray.append(skateParkLocationGroup)
                }
            }
        }
        return locationGroupArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:"sectionHeader") as! MyCustomHeader
        view.title.text = "\(locationGroupArray[section])"
        view.image.image = UIImage(named: "\(locationGroupArray[section])")
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let parkName = mvcLocationGroupOrderedSkateParks.filter {
            $0.group==locationGroupArray[section]
        }
        return parkName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier:"LocationGroupCell") {
            let parkName = mvcLocationGroupOrderedSkateParks.filter {
                $0.group==locationGroupArray[indexPath.section]
            }
            cell.textLabel?.text = parkName[indexPath.row].name
            cell.detailTextLabel?.text = parkName[indexPath.row].address
            cell.imageView?.image = UIImage(named: "\(locationGroupArray[indexPath.section])")
            return cell;
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let park = mvcLocationGroupOrderedSkateParks.filter {
            $0.group==locationGroupArray[indexPath.section]
        }
        let mvc = self.tabBarController!.viewControllers![0] as! MapViewController
        mvc.lastSkatepark = park[indexPath.row]
        
        // Safely unwrap the park id before calling zoomToAnnotation
        if let parkId = park[indexPath.row].id {
            mvc.zoomToAnnotation(withId: parkId)
        }
        
        tabBarController?.selectedIndex = 1
    }
}

//This is the view for the section header
class MyCustomHeader: UITableViewHeaderFooterView {
    let title = UILabel()
    let image = UIImageView()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents() {
        image.translatesAutoresizingMaskIntoConstraints = false
        title.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(image)
        contentView.addSubview(title)

        // Center the image vertically and place it near the leading
        // edge of the view. Constrain its width and height to 50 points.
        NSLayoutConstraint.activate([
            image.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            image.widthAnchor.constraint(equalToConstant: 60),
            image.heightAnchor.constraint(equalToConstant: 60),
            image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        
            // Center the label vertically, and use it to fill the remaining
            // space in the header view.
            title.heightAnchor.constraint(equalToConstant: 30),
            title.leadingAnchor.constraint(equalTo: image.trailingAnchor,
                   constant: 8),
            title.trailingAnchor.constraint(equalTo:
                   contentView.layoutMarginsGuide.trailingAnchor),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
