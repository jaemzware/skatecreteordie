import UIKit
import SwiftUI

class SwiftUIDetailsViewController: UIHostingController<DetailsView> {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get the current skate park from MapViewController
        guard let tabBarController = self.tabBarController,
              let mapViewController = tabBarController.viewControllers?[0] as? MapViewController,
              let lastSkatepark = mapViewController.lastSkatepark else {
            return
        }
        
        // Create a fresh DetailsView with the current skate park
        // This ensures zoom is reset when switching parks
        let detailsView = DetailsView(skatePark: lastSkatepark)
        self.rootView = detailsView
    }
    
    // Initialize with a placeholder view
    init() {
        // Create a placeholder SkatePark for initialization
        let placeholderPark = SkatePark(
            name: "Loading...",
            address: "",
            id: "",
            builder: "",
            sqft: "",
            lights: "",
            covered: "",
            url: "",
            elements: "",
            pinimage: "",
            photos: ["loading"],
            latitude: "",
            longitude: "",
            group: ""
        )
        let detailsView = DetailsView(skatePark: placeholderPark)
        super.init(rootView: detailsView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        // Create a placeholder SkatePark for initialization
        let placeholderPark = SkatePark(
            name: "Loading...",
            address: "",
            id: "",
            builder: "",
            sqft: "",
            lights: "",
            covered: "",
            url: "",
            elements: "",
            pinimage: "",
            photos: ["loading"],
            latitude: "",
            longitude: "",
            group: ""
        )
        let detailsView = DetailsView(skatePark: placeholderPark)
        super.init(coder: aDecoder, rootView: detailsView)
    }
}
