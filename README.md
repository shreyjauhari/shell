AMFI NAV Data Extractor
This repository contains tools to extract Scheme Name and Net Asset Value (NAV) data from AMFI India's daily NAV file and save it in both TSV and JSON formats.
Contents

amfi_nav_extractor.sh - Bash script to download and extract the data
amfi_nav_to_json.py - Python alternative with improved error handling
Sample output files (generated during the last run)

Features

Downloads the latest NAV data from AMFI India's website
Extracts Scheme Name and NAV information
Saves data in both TSV and JSON formats
Creates timestamped output files for historical tracking
Handles invalid or non-numeric NAV values
Includes metadata in the JSON output

Requirements
For the Bash script:

Bash shell
curl (for downloading the data)

For the Python script:

Python 3.6+
requests library

Usage
Bash Script
bash# Make the script executable
chmod +x amfi_nav_extractor.sh

# Run the script
./amfi_nav_extractor.sh
Python Script
bash# Install dependencies
pip install requests

# Run the script
python amfi_nav_to_json.py
Output Files
The scripts generate the following files:

amfi_nav_data.tsv - Current NAV data in TSV format
amfi_nav_data.json - Current NAV data in JSON format
amfi_nav_data_YYYYMMDD_HHMMSS.tsv - Timestamped TSV file
amfi_nav_data_YYYYMMDD_HHMMSS.json - Timestamped JSON file
amfi_nav_data_latest.json - Always contains the latest data (Python script only)

TSV vs. JSON: Which Format to Use?
TSV (Tab-Separated Values)

Pros: Easy to open in Excel or other spreadsheet software, smaller file size
Cons: Limited to string representation, no metadata, no nested data

JSON (JavaScript Object Notation)

Pros: Preserves data types (numbers as numbers), includes metadata, hierarchical structure, better for programmatic access
Cons: Slightly larger file size, requires a parser to read

Recommendation
Use JSON for applications and data analysis, especially if you need programmatic access or proper type handling. Use TSV for quick visual analysis in spreadsheet software.
Data Source
The data is sourced from the official AMFI India website:
https://www.amfiindia.com/spages/NAVAll.txt
License
MIT License
