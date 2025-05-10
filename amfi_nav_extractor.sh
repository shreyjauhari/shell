#!/bin/bash

# amfi_nav_extractor.sh
# Script to extract Scheme Name and NAV from AMFI India data
# Created: May 10, 2025

# Output file names
TSV_OUTPUT="amfi_nav_data.tsv"
JSON_OUTPUT="amfi_nav_data.json"

# Create a timestamp for the filename
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TSV_OUTPUT_TIMESTAMPED="amfi_nav_data_${TIMESTAMP}.tsv"
JSON_OUTPUT_TIMESTAMPED="amfi_nav_data_${TIMESTAMP}.json"

echo "Starting AMFI NAV data extraction..."

# Download the NAV data
echo "Downloading data from amfiindia.com..."
curl -s https://www.amfiindia.com/spages/NAVAll.txt -o navdata_temp.txt

# Check if download was successful
if [ $? -ne 0 ] || [ ! -s navdata_temp.txt ]; then
    echo "Error: Failed to download data from amfiindia.com"
    rm -f navdata_temp.txt
    exit 1
fi

echo "Data download complete. Extracting Scheme Name and NAV values..."

# Create TSV file with header
echo -e "Scheme Name\tNAV" > "$TSV_OUTPUT"

# Initialize JSON file
echo "{" > "$JSON_OUTPUT"
echo "  \"data\": [" >> "$JSON_OUTPUT"

# Process the data
# The AMFI NAV data format has the following structure:
# Scheme Code;ISIN Div Payout/ISIN Growth;ISIN Div Reinvestment;Scheme Name;Net Asset Value;Date
# We need to extract the Scheme Name (field 4) and NAV (field 5)

FIRST_LINE=true
VALID_ENTRIES=0

while IFS=';' read -r code isin_div isin_growth scheme_name nav date || [ -n "$scheme_name" ]; do
    # Skip empty lines and header lines
    if [ -z "$scheme_name" ] || [[ "$scheme_name" == *"Scheme Name"* ]]; then
        continue
    fi

    # Check if NAV is a valid number (some entries might have "N.A." or other non-numeric values)
    if [[ "$nav" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        # For TSV: Escape tab characters in scheme_name if any
        safe_scheme_name="${scheme_name//	/ }"
        
        # Write to TSV
        echo -e "$safe_scheme_name\t$nav" >> "$TSV_OUTPUT"
        
        # Write to JSON
        if [ "$FIRST_LINE" = true ]; then
            FIRST_LINE=false
        else
            echo "," >> "$JSON_OUTPUT"
        fi
        
        # Escape double quotes in scheme name for JSON
        json_scheme_name="${scheme_name//\"/\\\"}"
        echo "    {\"scheme_name\": \"$json_scheme_name\", \"nav\": $nav}" >> "$JSON_OUTPUT"
        
        VALID_ENTRIES=$((VALID_ENTRIES + 1))
    fi
done < navdata_temp.txt

# Finalize JSON file
echo "" >> "$JSON_OUTPUT"
echo "  ]," >> "$JSON_OUTPUT"
echo "  \"meta\": {" >> "$JSON_OUTPUT"
echo "    \"total_entries\": $VALID_ENTRIES," >> "$JSON_OUTPUT"
echo "    \"timestamp\": \"$(date +"%Y-%m-%d %H:%M:%S")\"," >> "$JSON_OUTPUT"
echo "    \"source\": \"https://www.amfiindia.com/spages/NAVAll.txt\"" >> "$JSON_OUTPUT"
echo "  }" >> "$JSON_OUTPUT"
echo "}" >> "$JSON_OUTPUT"

# Create timestamped copies
cp "$TSV_OUTPUT" "$TSV_OUTPUT_TIMESTAMPED"
cp "$JSON_OUTPUT" "$JSON_OUTPUT_TIMESTAMPED"

# Clean up
rm -f navdata_temp.txt

echo "Extraction complete!"
echo "Total valid entries extracted: $VALID_ENTRIES"
echo "Data saved as TSV: $TSV_OUTPUT and $TSV_OUTPUT_TIMESTAMPED"
echo "Data saved as JSON: $JSON_OUTPUT and $JSON_OUTPUT_TIMESTAMPED"
echo ""
echo "Note: Both TSV and JSON formats were created for flexibility."
echo "TSV is better for quick analysis in spreadsheet software."
echo "JSON is better for programmatic access and includes metadata."
