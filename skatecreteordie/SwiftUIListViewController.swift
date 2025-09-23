import UIKit
import SwiftUI

class SwiftUIListViewController: UIHostingController<ListView> {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get the current skate parks from MapViewController
        guard let tabBarController = self.tabBarController,
              let mapViewController = tabBarController.viewControllers?[0] as? MapViewController else {
            return
        }
        
        // Filter parks based on current map filter
        let parksToShow: [SkatePark]
        if let currentFilter = mapViewController.currentFilterPinImage {
            parksToShow = mapViewController.skateParks.filter { $0.pinimage == currentFilter }
        } else {
            parksToShow = mapViewController.skateParks
        }
        
        // Create a fresh ListView with the filtered skate parks
        let listView = ListView(
            skateParks: parksToShow,
            onParkSelected: { [weak self] selectedPark in
                // Set the selected park in MapViewController
                mapViewController.lastSkatepark = selectedPark
                
                // Zoom to the annotation on the map (no filter clearing needed!)
                if let parkId = selectedPark.id {
                    mapViewController.zoomToAnnotation(withId: parkId)
                }
                
                // Switch to the details tab
                self?.tabBarController?.selectedIndex = 1
            }
        )
        self.rootView = listView
    }
    
    // Initialize with a placeholder view
    init() {
        let listView = ListView(skateParks: [], onParkSelected: { _ in })
        super.init(rootView: listView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        let listView = ListView(skateParks: [], onParkSelected: { _ in })
        super.init(coder: aDecoder, rootView: listView)
    }
}
