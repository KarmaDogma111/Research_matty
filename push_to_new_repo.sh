#!/bin/bash

# Set up variables
GH_BIN=~/gh-cli/gh_2.39.1_macOS_amd64/bin/gh
SOURCE_DIR="/Users/alexschwartz/Documents/Windsurf Files/Research /Docs"
REPO="KarmaDogma111/Research_matty"

# Check if repository exists, if not create it
echo "Checking if repository exists..."
$GH_BIN repo view $REPO > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Creating new repository: $REPO"
  $GH_BIN repo create $REPO --public --description "AI Adoption Research with Enhanced Styling"
  sleep 2
else
  echo "Repository $REPO already exists"
fi

# Create temporary directory for processing
TEMP_DIR=$(mktemp -d)
echo "Created temp directory: $TEMP_DIR"

# Process files by type to ensure correct upload order
echo "Starting file uploads..."

# Function to upload a file
upload_file() {
  local file="$1"
  local rel_path="${file#"$SOURCE_DIR/"}"
  
  # Skip .git files
  if [[ "$rel_path" == .git* ]]; then
    return
  fi
  
  echo "Processing: $rel_path"
  
  # Create temporary file with content
  local temp_file="$TEMP_DIR/$(basename "$file")"
  cat "$file" > "$temp_file"
  
  # Upload file using GitHub CLI
  $GH_BIN api --method PUT "repos/$REPO/contents/$rel_path" \
    -f message="Add $rel_path" \
    -f content="$(base64 < "$temp_file")" || true
    
  echo "Uploaded: $rel_path"
  # Sleep to avoid rate limiting
  sleep 1
}

# Upload README.md first (important to be the first file in the repo)
if [ -f "$SOURCE_DIR/README.md" ]; then
  echo "Uploading README.md first..."
  upload_file "$SOURCE_DIR/README.md"
fi

# Upload configuration files
echo "Uploading configuration files..."
find "$SOURCE_DIR" -name "_config.yml" -type f | while read file; do
  upload_file "$file"
done

# Upload style files
echo "Uploading style files..."
find "$SOURCE_DIR/assets" -type f 2>/dev/null | while read file; do
  upload_file "$file"
done

# Upload markdown files from each directory in order
directories=("01_Executive_Summary" "02_Company_Profiles" "03_Comparative_Analysis" "04_AI_Adoption_Research")

for dir in "${directories[@]}"; do
  if [ -d "$SOURCE_DIR/$dir" ]; then
    echo "Uploading files from $dir..."
    find "$SOURCE_DIR/$dir" -name "*.md" -type f | while read file; do
      upload_file "$file"
    done
  fi
done

# Upload any remaining files (scripts, etc.)
echo "Uploading remaining files..."
find "$SOURCE_DIR" -type f -not -path "*/\.*" -not -path "*/assets/*" -not -name "README.md" -not -name "_config.yml" -not -path "*/0[1-4]_*/*.md" | while read file; do
  upload_file "$file"
done

# Clean up
rm -rf "$TEMP_DIR"
echo "Upload complete! Repository is available at: https://github.com/$REPO"
echo "GitHub Pages site will be available at: https://karmdogma111.github.io/Research_matty/ (may take a few minutes to deploy)"
