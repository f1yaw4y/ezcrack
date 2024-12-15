#!/bin/bash

# Directory to store the converted files
HASHES_DIR="$HOME/hashes"
RESULTS_FILE="$HASHES_DIR/hashcat_results.txt"

# Check if the "hashes" directory exists, create it if it doesn't
if [ ! -d "$HASHES_DIR" ]; then
    echo "Creating directory: $HASHES_DIR"
    mkdir -p "$HASHES_DIR"
fi

# Initialize the results file
> "$RESULTS_FILE"
echo "Hashcat results will be saved to $RESULTS_FILE"

# Prompt the user for input if no files are provided
if [ $# -eq 0 ]; then
    echo "No .pcap files provided!"
    echo "Please drag and drop the .pcap files into this terminal window (space-separated) and press Enter:"
    read -r -a pcap_files
    if [ ${#pcap_files[@]} -eq 0 ]; then
        echo "No files entered. Exiting."
        exit 1
    fi
else
    pcap_files=("$@")
fi

# Process each file provided as an argument or via input
for pcap_file in "${pcap_files[@]}"; do
    # Resolve potential issues with drag-and-drop paths
    clean_pcap_file=$(echo "$pcap_file" | sed "s/^'//;s/'$//")

    # Check if the file exists and is readable
    if [ ! -f "$clean_pcap_file" ]; then
        echo "Error: File '$pcap_file' does not exist or is not accessible. Skipping."
        continue
    fi

    # Get the base name of the file (without extension)
    base_name="$(basename "$clean_pcap_file" .pcap)"

    # Define the output file path
    output_file="$HASHES_DIR/$base_name.hc22000"

    # Convert the file using hcxpcapngtool
    echo "Converting '$clean_pcap_file' to '$output_file'..."
    hcxpcapngtool -o "$output_file" "$clean_pcap_file"

    # Check if the conversion was successful
    if [ $? -eq 0 ] && [ -f "$output_file" ]; then
        echo "Conversion successful: '$output_file'"
    else
        echo "Error during conversion of '$pcap_file'."
    fi

done

# Prompt the user for a dictionary file to use with hashcat
echo "Please drag and drop the dictionary file into this terminal window and press Enter:"
read -r dictionary_file

# Resolve potential issues with drag-and-drop paths
clean_dictionary_file=$(echo "$dictionary_file" | sed "s/^'//;s/'$//")

# Check if the dictionary file exists
if [ ! -f "$clean_dictionary_file" ]; then
    echo "Error: Dictionary file '$dictionary_file' does not exist or is not accessible. Exiting."
    exit 1
fi

# Run hashcat on all hc22000 files
found_files=0
for hash_file in "$HASHES_DIR"/*.hc22000; do
    if [ -f "$hash_file" ]; then
        found_files=1
        echo "Running hashcat on '$hash_file' with dictionary '$clean_dictionary_file'..." | tee -a "$RESULTS_FILE"
        hashcat -m 22000 "$hash_file" "$clean_dictionary_file" | tee -a "$RESULTS_FILE"
        if [ $? -eq 0 ]; then
            echo "Hashcat processing completed for '$hash_file'." | tee -a "$RESULTS_FILE"
        else
            echo "Error during hashcat processing for '$hash_file'." | tee -a "$RESULTS_FILE"
        fi
    fi
done

if [ $found_files -eq 0 ]; then
    echo "No .hc22000 files found in '$HASHES_DIR'. Skipping hashcat."
fi

echo "All done! Check results in the '$HASHES_DIR' directory and review the output in '$RESULTS_FILE'."

