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
        
        // Create a fresh ListView with the current skate parks
        let listView = ListView(
            skateParks: mapViewController.skateParks,
            onParkSelected: { [weak self] selectedPark in
                // Set the selected park in MapViewController
                mapViewController.lastSkatepark = selectedPark
                
                // Zoom to the annotation on the map
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
