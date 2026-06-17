1. open skateparkdata.csv in your favorite spreadsheet editor 
2. make your changes
3. sort by id
4. save/export to skateparkdata.csv
5. run convert.sh (runs python3 convert_skateparkdata_csv_to_json.py) 
6. this creates skateparkdata20241209.js
7. move skateparkdata20241209.js to skateparkdata20241209.json
8. submit a PR for skateparkdata.csv and skateparkdata20241209.json
9. deploy to your server pointed to ParkDataBaseURL in Configuration.plist
