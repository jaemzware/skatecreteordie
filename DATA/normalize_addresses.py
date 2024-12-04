import pandas as pd
from geopy.geocoders import GoogleV3
from geopy.exc import GeocoderTimedOut, GeocoderUnavailable, GeocoderQueryError
from geopy.distance import geodesic
import time

def test_api_key(api_key):
    """Test if the API key is valid"""
    geolocator = GoogleV3(api_key=api_key)
    try:
        # Try to geocode a known address
        result = geolocator.geocode("1600 Amphitheatre Parkway, Mountain View, CA")
        if result:
            print("API key is valid and working")
            return True
        else:
            print("API key seems invalid - no results returned")
            return False
    except Exception as e:
        print(f"API key validation failed: {str(e)}")
        return False

def format_us_address(location_data):
    """Format US addresses with the specific [street], [city], [state] [zip], US format"""
    components = location_data.raw.get('address_components', [])
    original_formatted = location_data.address
    formatted_parts = original_formatted.split(',')
    
    # Get all parts before the city to preserve place names and street addresses
    street = ', '.join(part.strip() for part in formatted_parts[:-3])
    
    # Check for intersection indicators in both original and formatted address
    intersection_indicators = ['&', ' and ', ' AND ', ' And ']
    is_intersection = (
        any(x in street.lower() for x in ['&', ' and ']) or
        any(t.get('types', []) == ['intersection'] for t in components)
    )
    
    if is_intersection:
        # Get all route components
        routes = [c['long_name'] for c in components if 'route' in c['types']]
        if len(routes) >= 2:
            street = f"{routes[0]} & {routes[1]}"
        else:
            # If we can't get both routes from components, try to preserve original format
            street = street.replace(' and ', ' & ').replace(' AND ', ' & ').replace(' And ', ' & ')
    
    city = next((
        comp['long_name'] for comp in components
        if 'locality' in comp['types']
    ), '')
    
    state = next((
        comp['short_name'] for comp in components
        if 'administrative_area_level_1' in comp['types']
    ), '')
    
    postal_code = next((
        comp['long_name'] for comp in components
        if 'postal_code' in comp['types']
    ), '')
    
    return f"{street}, {city}, {state} {postal_code}, US"

def find_nearest_valid_address(lat, lon, valid_addresses):
    """Find the nearest valid address based on latitude and longitude"""
    if not valid_addresses:
        return None
        
    point = (lat, lon)
    min_distance = float('inf')
    nearest_address = None
    
    for addr in valid_addresses:
        addr_point = (addr['lat'], addr['lon'])
        distance = geodesic(point, addr_point).miles
        
        if distance < min_distance:
            min_distance = distance
            nearest_address = addr['formatted_address']
            
    return nearest_address

def validate_and_format_addresses(df, api_key):
    """Main function to validate and format addresses"""
    geolocator = GoogleV3(api_key=api_key)
    valid_addresses = []
    result_df = df.copy()
    
    for idx, row in df.iterrows():
        try:
            print(f"\nProcessing address: {row['address']}")
            original_address = row['address']
            
            try:
                location = geolocator.geocode(
                    original_address,
                    exactly_one=True,
                    language='en'
                )
                if location and hasattr(location, 'raw'):
                    # Get country code
                    country_code = next((
                        comp['short_name'] for comp in location.raw.get('address_components', [])
                        if 'country' in comp['types']
                    ), None)
                    
                    if country_code:
                        print(f"Detected country: {country_code}")
                        
                        # Format address based on country
                        if country_code == 'US':
                            formatted_address = format_us_address(location)
                            # Check if we got an incomplete address (no street)
                            if formatted_address.startswith(", "):
                                if 'latitude' in row and 'longitude' in row and valid_addresses:
                                    nearest = find_nearest_valid_address(row['latitude'], row['longitude'], valid_addresses)
                                    if nearest:
                                        print(f"Incomplete address found. Using nearest address: {nearest}")
                                        result_df.at[idx, 'address'] = nearest
                                        continue
                        else:
                            formatted_address = location.address.replace(", USA", f", {country_code}")
                            formatted_address = formatted_address.replace(", United States", f", {country_code}")
                        
                        print(f"Formatted address: {formatted_address}")
                        
                        valid_addresses.append({
                            'lat': location.latitude,
                            'lon': location.longitude,
                            'formatted_address': formatted_address
                        })
                        result_df.at[idx, 'address'] = formatted_address
                        continue
                else:
                    # If location not found, use provided coordinates to find nearest
                    if 'latitude' in row and 'longitude' in row and valid_addresses:
                        nearest = find_nearest_valid_address(row['latitude'], row['longitude'], valid_addresses)
                        if nearest:
                            print(f"Original address not found. Using nearest address: {nearest}")
                            result_df.at[idx, 'address'] = nearest
                            continue
            except Exception as e:
                print(f"Error processing address: {str(e)}")
            
            print(f"Could not validate address: {original_address}")
            # Keep original address if no valid alternative found
            result_df.at[idx, 'address'] = original_address
            
        except Exception as e:
            print(f"Unexpected error processing {row['address']}: {str(e)}")
            continue
            
    return result_df
# Read the CSV file
print("Reading CSV file...")
df = pd.read_csv('addressidlatitudelongitude.csv')

# Your Google API key
API_KEY = 'YOUR_GOOGLE_API_KEY_HERE'  # Replace with your actual API key

# Test API key first
if test_api_key(API_KEY):
    print("\nStarting address validation...")
    result_df = validate_and_format_addresses(df, API_KEY)
    
    # Save the results
    result_df.to_csv('validated_addressidlatitudelongitude.csv', index=False)
    print("\nResults saved to validated_addresses.csv")
else:
    print("\nPlease check your API key and make sure it has the Geocoding API enabled in the Google Cloud Console.")
    print("You may need to:")
    print("1. Enable the Geocoding API in your Google Cloud Console")
    print("2. Make sure billing is enabled for your project")
    print("3. Check if you have any API restrictions set up")
    print("4. Verify the API key has access to the Geocoding API")
