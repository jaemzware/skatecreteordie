//
//  DetailsViewController.swift
//  skatecreteordie
//
//  Created by JAMES K ARASIM on 3/26/16.
//  Copyright 2016-2024 jaemzware llc
//  Licensed under the Apache License, Version 2.0
//
import UIKit

extension UIImageView {
    func load(link: String, contentMode mode: UIView.ContentMode) {
            //async download image. when it is downloaded, kill the animation and splash
            guard
                let url = URL(string: SkatePark.imageHostUrl+link)
                else {return}
            contentMode = mode
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.image = image
                        }
                    }
                }
            }
        }
}

class DetailsViewController: UIViewController, UIScrollViewDelegate {
    
    var photosArrayCurrentIndex:Int! = 0
    var photosArray:[String]! = ["loading"]
    
    @IBOutlet weak var parkImageScrollView: UIScrollView!
    @IBOutlet weak var parkNameLabel: UILabel!
    @IBOutlet weak var exactLocationButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var parkImageView: UIImageView!
    @IBOutlet weak var lineOneLabel: UILabel!
    @IBOutlet weak var lineTwoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        parkImageScrollView.minimumZoomScale = 1.0
        parkImageScrollView.maximumZoomScale = 1.0
        parkImageScrollView.contentSize = parkImageView.frame.size
        parkImageScrollView.delegate = self
        parkImageView.contentMode = .scaleAspectFit
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return parkImageView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///get the last skatepark tapped from the map view for information in this details view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        //note: photosArray is initialized with one entry, the loading image, then set to the array of the park later
        parkImageView.image = UIImage(named: photosArray[0])
        
        let mvc:MapViewController = self.tabBarController!.viewControllers![0] as! MapViewController
        parkNameLabel.text = mvc.lastSkatepark!.name
        if let lastSkatepark = mvc.lastSkatepark {
            let builder = lastSkatepark.builder ?? "n/a"
            let sqft = lastSkatepark.sqft ?? "n/a"
            let lights = lastSkatepark.lights ?? "n/a"
            let covered = lastSkatepark.covered ?? "n/a"
            let address = lastSkatepark.address ?? "n/a"

            lineOneLabel.text = "\(builder) Sz:\(sqft) Lt:\(lights) Cv:\(covered)"
            lineTwoLabel.text = "\(address)"
        }
        
        //gesture recognizer for address label
        let tapGestureAddress = UITapGestureRecognizer(target: self, action: #selector(labelTwoTapped))
        lineTwoLabel.isUserInteractionEnabled = true
        lineTwoLabel.addGestureRecognizer(tapGestureAddress)
        
        //load image url asynchronous, if it can be gotten
        photosArray = mvc.lastSkatepark!.photos;
        photosArrayCurrentIndex = 0;
        parkImageView.load(link: photosArray[photosArrayCurrentIndex], contentMode: UIView.ContentMode.scaleAspectFit )
        
        parkImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DetailsViewController.handleTap(_:)))
        parkImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // Increment the current index
        photosArrayCurrentIndex += 1
        
        // If the current index is out of bounds, wrap around to the beginning
        if photosArrayCurrentIndex >= photosArray.count {
            photosArrayCurrentIndex = 0
        }
        
        // Load the image at the current index
        parkImageView.load(link: photosArray[photosArrayCurrentIndex], contentMode: .scaleAspectFit)
    }
    
    @IBAction func clickExactLocation(_ sender: Any) {
        let fvc:MapViewController = self.tabBarController!.viewControllers![0] as! MapViewController
        if let url = URL(string: "https://www.google.com/search?q=\(fvc.lastSkatepark!.latitude!)%2C\(fvc.lastSkatepark!.longitude!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @IBAction func clickWebsite(_ sender: Any) {
        let fvc:MapViewController = self.tabBarController!.viewControllers![0] as! MapViewController
        if let inputString = fvc.lastSkatepark?.url {
            if let range = inputString.range(of: "http[^\\s]*", options: .regularExpression) {
                let substring = inputString[range]
                if let url = URL(string: String(substring)) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    @objc func labelTwoTapped() {
            // Copy the label's text to the clipboard
            UIPasteboard.general.string = lineTwoLabel.text

            // Optionally, provide visual feedback to the user (e.g., animate the label)
            UIView.animate(withDuration: 0.2) {
                self.lineTwoLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.lineTwoLabel.transform = .identity
                }
            }
        }
}

