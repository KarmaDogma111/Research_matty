#!/bin/bash

# Mermaid header content to add
read -r -d '' MERMAID_HEADER << 'EOF'
<!-- Mermaid support for diagrams, flowcharts, and Gantt charts -->
<!-- Usage examples:
```mermaid
graph TD;
    A[Company] --> B[Offerings];
    A --> C[Target Audience];
    A --> D[Approach];
    B --> E[AI-Powered Learning];
    B --> F[Research-backed Content];
```

```mermaid
gantt
    title Implementation Timeline
    dateFormat  YYYY-MM-DD
    section Adoption
    Planning      :done, a1, 2025-05-01, 30d
    Training      :active, a2, after a1, 45d
    section Usage
    Initial Use   :a3, after a2, 60d
    Mastery       :a4, after a3, 45d
```

```mermaid
mindmap
  root((Company))
    Offerings
      Feature 1
      Feature 2
    Audience
      Primary
      Secondary
    Approach
      Strategy 1
      Strategy 2
```
-->

EOF

# Process each markdown file
find . -name "*.md" | while read -r file; do
  # Skip already processed files
  if grep -q "Mermaid support" "$file"; then
    echo "Skipping already processed file: $file"
    continue
  fi
  
  # Add header to the file
  echo "Adding Mermaid support to: $file"
  temp_file=$(mktemp)
  echo "$MERMAID_HEADER" > "$temp_file"
  cat "$file" >> "$temp_file"
  mv "$temp_file" "$file"
done

echo "Completed adding Mermaid support to markdown files"
