#!/bin/bash

# Array of target files
declare -a target_files=("ERC677Lib.sol" "SmartTokenLib.sol" "SmartController.sol")

# Create the verify directory if it doesn't exist
mkdir -p verify-files

# Iterate through each target file
for target_file in "${target_files[@]}"; do
  # Execute the command and save the output to a variable
  output=$(npx truffle-flattener "contracts/$target_file")

  # Extract the directory name from the target file
  directory_name=${target_file%.sol}

  # Create a directory with the name of the original file inside verify
  mkdir -p "verify-files/$directory_name"

  # Parse the output and copy the files
  echo "$output" | grep -o '// File: .*' | sed 's#// File: ##' | while read -r file_path; do
    # Determine the destination path
    destination="verify-files/$directory_name/$(basename "$file_path")"

    # Check if the file path starts with @openzeppelin
    if [[ $file_path == @openzeppelin/* ]]; then
      cp "node_modules/$file_path" "$destination"
    else
      cp "$file_path" "$destination"
    fi

    # Modify the imports in the destination file (use a temporary file for compatibility)
    sed 's#import .*/\(.*\)#import "./\1"#' "$destination" > "$destination.tmp"
    mv "$destination.tmp" "$destination"
  done

  echo "Files have been copied and modified in verify-files/$directory_name directory"
done
