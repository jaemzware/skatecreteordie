import csv
import json

def convert_csv_to_json(csv_file, json_file):
    # Read the CSV file
    with open(csv_file, 'r', encoding='utf-8') as file:
        # Use CSV DictReader to automatically handle headers and field parsing
        csv_reader = csv.DictReader(file)
        # Convert rows to list of dictionaries
        data = list(csv_reader)

    # Create the final structure
    json_data = {
        "skateparks": data
    }

    # Write to JSON file
    with open(json_file, 'w', encoding='utf-8') as file:
        json.dump(json_data, file, indent=4)

if __name__ == "__main__":
    try:
        convert_csv_to_json('skateparkdata.csv', 'skateparks.json')
        print("Successfully converted CSV to JSON!")
    except Exception as e:
        print(f"An error occurred: {e}")
