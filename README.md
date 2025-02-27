# skatecreteordie 🛹
custom skatepark map and path tracking for iOS. 


## Custom Skatepark Map: World-Class Skateparks at your immediate finger tips

skatecreteordie features a meticulously curated database of premium skateparks, with an obsessive focus on accuracy and discoverability.

### Features

- 🎯 **Precise Pin Placement**
   * Every park pin is guaranteed to drop you on the actual concrete
   * No more searching around approximate addresses

- 🏗️ **Builder Recognition**
   * Custom pin icons identify renowned park builders
   * Celebrating the architects of skate culture

- 📏 **Detailed Specifications**
   * At least one photo per park
   * Verified square footage
   * Lighting information [help wanted]
   * Coverage details [help wanted]
   * Park elements/features [help wanted]
   * Direct links to builders' project pages

- 📍 **Reliable Navigation**
   * Google Maps integration with precise coordinates
   * Especially crucial for parks without formal addresses


## Path Tracking: Show Off Your Lines ✨

Map your skating journey in real-time with skatecreteordie's advanced path tracking feature. Whether you're hitting every corner of the park or perfecting your favorite line, the app creates a visual story of your session.

### Features

- 🟢 **Live Trail Mapping**  
  Watch your path appear as a green line while you skate

- ⏱️ **Session Stats**  
  Track your elapsed time and distance (mi/km)

- 🔒 **Privacy First**  
  Your location data stays on your device - never stored nor transmitted

- 🌐 **Works Everywhere**  
  Functions with or without cell coverage (GPS only)

- 🔋 **Background Ready**  
  Keeps tracking even when your phone is locked or app is minimized

- 📍 **Quick Navigation**  
  Instantly center on your location

- 📋 **Easy Sharing**  
  Copy exact coordinates to share your spot with friends

- 🔄 **Fresh Start**  
  Reset your path anytime to begin a new line

Perfect for documenting your favorite park lines, sharing your creative routes, or just seeing how much ground you covered in a session. Enable tracking with a single tap and start drawing your story across the park.

---

*Note: Path tracking requires "Always" location permission with "Precise location" enabled for optimal performance.*


## Installation

Download skatecreteordie from the [App Store](https://apps.apple.com/us/app/skatecreteordie/id1099516729)

### Requirements
- iOS 15.6 or later
- iPhone or iPad

Want to try the beta? Join our [TestFlight](https://testflight.apple.com/join/m6u17wRD)


## Quick Start

### Finding Parks

1. Install from [App Store](https://apps.apple.com/us/app/skatecreteordie/id1099516729)

2. Explore skatepark pins on the **Map** screen
   * Tap any pin, then tap its information bubble to open the **Details** screen
   * When **Path Tracking** is **off**, the geocoordinate of the park is displayed

3. Browse all parks by name on the **List** screen
   * Tap any park name to open its **Details** screen

4. See the parks
   * Tap image on the **Details** screen
   * Progresses through other images of the park (if any)
   
5. Navigate to parks
   * Tap **Directions** on the **Details** screen
   * Opens Google Maps in your browser with precise coordinates

6. Learn more about parks
   * Tap **Website** on the **Details** screen
   * Opens builder's website or park information in your browser

### Path Tracking

1. Enable tracking
   * Switch tracking **On** in the **Map** view
   * Allow "Always" and "Precise Location" permissions when prompted
   * Your exact geocoordinate is displayed

2. Track your skate runs
   * With skatecreteordie path tracking active, lock your phone, put it in your pocket, and take a run
   * A thin green line will trace your path in real-time
   * View your total time, distance, and kilometers after your run
   * Your path stays recorded until you reset it

3. Manage your path
   * Tap **Reset** to clear your current path and distance
   * Your new path will begin recording immediately

4. Find your location
   * Tap **Pin My Location** to center on your position
   * Zoom out to discover nearby skateparks

5. Share coordinates
   * Tap **Copy** to save your current coordinates
   * Paste them anywhere (messages, notes, etc.)
   
   
## Prerequisites

### Device Requirements
* iPhone or iPad with iOS 15.6 or later
* GPS capabilities
* 90MB free storage space

### Location Settings
* Location Services must be enabled with:
  * "Always" permission
  * "Precise Location" enabled
* These settings are required for path tracking

### Network & Location
* Internet connection recommended for:
  * Latest map data
  * Directions
  * Builder / park-related websites

### Offline Capabilities
* The following features work without internet:
  * All skatepark pins and locations
  * Nearest address information
  * Geocoordinate data in **Directions** links
  * Path tracking (green line and current position)
  * Note: Map background may not render or zoom while offline

*Data available offline reflects the latest information from the most recent app update.*

---

# Developer Documentation

The following sections are for developers who want to build, modify, and contribute to skatecreteordie. If you're just looking to use the app, you can download it directly from the [App Store](https://apps.apple.com/us/app/skatecreteordie/id1099516729).

## Building Locally

### Prerequisites
- Xcode 15 or later
- iOS Development environment set up

### Configuration
1. Clone the repository:
   ```bash
   git clone https://github.com/jaemzware/skatecreteordie.git
   ```

2. Set up configuration files:
   - Copy `Configuration.template.plist` to `Configuration.plist`
   - Add the new `Configuration.plist` to your Xcode project

3. Configure server endpoints in `Configuration.plist`:
   - `ParkDataBaseURL`: Your park data endpoint
     - Points to latest `skateparkdata.js`
     - Example: `https://myserver.com/skateparkdata20240303.js`
   
   - `ParkImagesBaseURL`: Your image server root
     - Base URL for all skatepark photos
     - Must include trailing slash (/)
     - Example: `https://myserver.com/media/skateparks/`

   *Note: The project will not build without a properly configured `Configuration.plist` file.*

4. Build and run:
   - Open `skatecreteordie.xcodeproj` in Xcode
   - Select your target device
   - Build and run the project

## Documentation

### Technical Overview

- 📱 **Dependencies**
  * Apple frameworks only: Foundation, UIKit, MapKit, CoreLocation
  * No external databases or third-party APIs required

- 🔄 **Data Management**
  * Single JSON data file hosting required
  * Dynamic park data updates without app releases
  * Fetches from `ParkDataBaseURL` on app launch
  * Falls back to bundled data if fetch fails

- 🖼️ **Image System**
  * Photos served from `ParkImagesBaseURL`
  * Image filenames defined in park data JSON
  * Automatic endpoint construction and download

### Data Contribution

- 📊 **Source Files**
  * Main spreadsheet: `skateparkdata20240303.numbers`
  * Generated file: `skateparkdata20240303.js`
  * Submit park data PRs to `skateparkdata20240303.js`

### Park Data Schema

```json
{
    "name": "Muckleshoot Skatepark",
    "address": "39015 172nd Ave SE, Auburn, WA 98092",
    "id": "muckelshoot",
    "builder": "Grindline.",
    "sqft": "7,000sqft.",
    "lights": "No",
    "covered": "No",
    "url": "http://grindline.com/skateparks/muckleshoot/",
    "elements": "Concrete Skatepark.",
    "pinimage": "grindlinepin",
    "photos": "mukilshoot.jpg mukilshoot2.jpg mukilshoot3.jpg mukilshoot4.jpg ",
    "latitude": "47.249883",
    "longitude": "-122.112783",
    "group": "WA"
}
```

### Field Definitions

- **name**: Official city park name or "{city name} skatepark"
- **address**: Park address or nearest viewable address
- **id**: Unique alphabetic identifier (no spaces)
- **builder**: Company/companies that designed/built the park
- **sqft**: Approximate square footage
- **lights**: Lighting information (yes, no, or descriptive)
- **covered**: Coverage information (yes, no, or descriptive)
- **url**: Builder's project page or relevant park information
- **elements**: Park description (feature in development)
- **pinimage**: Map marker asset name (must match Assets file "*pin" images)
- **photos**: Space-separated image filenames, served from `ParkImagesBaseURL`
- **latitude**: Valid coordinate within park concrete
- **longitude**: Valid coordinate within park concrete
- **group**: Two-letter code (US state or non-US country)

    
## Contributing

Instructions for potential contributors:
1. Fork the repository
2. Create a feature branch
3. Submit a Pull Request (Submit park data PRs to `skateparkdata20240303.js`)


## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) and [NOTICE](NOTICE) files for details.


## Acknowledgments

### Dedication 💫
This project is dedicated to the memory and spirit of Mark "Monk" Hubbard (1970-2018), founder of Grindline Skateparks. His dedication, grit, skill, and heart for skateparks and the skateboarding community inspired the creation of skatecreteordie when I had no idea how to build an app. Monk's masterful craft of building skateparks is the primary driving force behind this project. Thank you, Monk, for showing us all what passion truly means.

### About the Project 🛹
skatecreteordie is a DIY passion project born from 37 years of skateboarding experience. The project spans multiple platforms:
- iOS: skatecreteordie
- Android: skate.crete.or.die
- Web: [skatecreteordie.com](https://skatecreteordie.com)
- Instagram: [@skatecreteordie](https://instagram.com/skatecreteordie)

### Mission & Values 🌟
- **Community First**: Built as a free resource for skateboarders worldwide
- **Zero Monetization**: No ads, no in-app purchases, no registration required
- **Open Source**: All skatepark data freely available and community-maintained
- **Precision Focused**: Every pin placed within actual park boundaries
- **Builder Recognition**: Showcasing the artistry of skatepark builders

### Special Thanks 🙏
This project celebrates:
- The master artisan builders creating world-class skateparks
- The global skateboarding community
- Everyone who has contributed park data and photos
- All skaters pushing themselves to new limits with the tracking feature

*The entire project is independently funded, developed, and maintained as a contribution to skateboarding culture.*

Want to help? Visit the [Submission page](https://skatecreteordie.com/submission) to contribute park data or corrections.

