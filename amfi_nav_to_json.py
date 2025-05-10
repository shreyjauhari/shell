#!/usr/bin/env python3

"""
AMFI NAV Data Extractor
This script downloads mutual fund NAV data from AMFI India and converts it to JSON format
with better error handling and performance than the shell script version.
"""

import requests
import json
import csv
from datetime import datetime
import sys
import os

def download_nav_data():
    """Download NAV data from AMFI website"""
    url = "https://www.amfiindia.com/spages/NAVAll.txt"
    print(f"Downloading data from {url}...")
    
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()  # Raise exception for 4XX/5XX responses
        return response.text
    except requests.exceptions.RequestException as e:
        print(f"Error downloading data: {e}")
        sys.exit(1)

def parse_nav_data(data):
    """Parse NAV data and extract Scheme Name and NAV values"""
    print("Parsing NAV data...")
    
    nav_data = []
    lines = data.split('\n')
    valid_entries = 0
    
    for line in lines:
        if not line.strip() or "Scheme Name" in line:
            continue
            
        fields = line.split(';')
        if len(fields) < 5:
            continue
            
        scheme_name = fields[3].strip()
        nav_value = fields[4].strip()
        
        # Check if NAV is a valid number
        try:
            nav_float = float(nav_value)
            nav_data.append({
                "scheme_name": scheme_name,
                "nav": nav_float
            })
            valid_entries += 1
        except ValueError:
            # Skip entries with non-numeric NAV values
            continue
    
    print(f"Successfully parsed {valid_entries} valid entries")
    return nav_data

def save_as_json(nav_data, filename=None):
    """Save NAV data as JSON"""
    if filename is None:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"amfi_nav_data_{timestamp}.json"
    
    output = {
        "data": nav_data,
        "meta": {
            "total_entries": len(nav_data),
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "source": "https://www.amfiindia.com/spages/NAVAll.txt"
        }
    }
    
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(output, f, indent=2, ensure_ascii=False)
    
    print(f"Data saved as JSON: {filename}")
    return filename

def save_as_tsv(nav_data, filename=None):
    """Save NAV data as TSV"""
    if filename is None:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"amfi_nav_data_{timestamp}.tsv"
    
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f, delimiter='\t')
        writer.writerow(["Scheme Name", "NAV"])
        
        for entry in nav_data:
            writer.writerow([entry["scheme_name"], entry["nav"]])
    
    print(f"Data saved as TSV: {filename}")
    return filename

def main():
    """Main function"""
    print("AMFI NAV Data Extractor")
    print("======================")
    
    # Create output directory if it doesn't exist
    os.makedirs('amfi_data', exist_ok=True)
    
    # Download data
    data = download_nav_data()
    
    # Parse data
    nav_data = parse_nav_data(data)
    
    if not nav_data:
        print("No valid data found. Exiting.")
        sys.exit(1)
    
    # Save data
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Save as TSV
    tsv_filename = os.path.join('amfi_data', f"amfi_nav_data_{timestamp}.tsv")
    save_as_tsv(nav_data, tsv_filename)
    
    # Save as JSON (also save a non-timestamped version for consistent access)
    json_filename = os.path.join('amfi_data', f"amfi_nav_data_{timestamp}.json")
    save_as_json(nav_data, json_filename)
    save_as_json(nav_data, os.path.join('amfi_data', "amfi_nav_data_latest.json"))
    
    print("\nExtraction complete!")
    print(f"Total entries: {len(nav_data)}")
    print("\nWhich format should you use?")
    print("- TSV: Good for spreadsheet applications and quick analysis")
    print("- JSON: Better for programmatic access, includes metadata, and preserves data types")

if __name__ == "__main__":
    main()
