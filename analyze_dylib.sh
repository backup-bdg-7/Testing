#!/bin/bash

# Script to analyze .dylib files in the repository root
# Creates an HTML report and individual text files with detailed analysis

# Set up output directory
OUTPUT_DIR="analysis_output"
mkdir -p "$OUTPUT_DIR"

# Find all .dylib files in the repository root
DYLIB_FILES=$(find . -maxdepth 1 -name "*.dylib" -type f)

# Check if any .dylib files were found
if [ -z "$DYLIB_FILES" ]; then
    echo "No .dylib files found in the repository root."
    # Create an empty report
    cat > "$OUTPUT_DIR/dylib_report.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DyLib Analysis Report</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        h1, h2, h3 {
            color: #2c3e50;
        }
        .alert {
            background-color: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <h1>DyLib Analysis Report</h1>
    <div class="alert">
        <p>No .dylib files were found in the repository root.</p>
        <p>To analyze .dylib files, please add them to the root directory of your repository.</p>
    </div>
</body>
</html>
EOF
    exit 0
fi

# Start HTML report
cat > "$OUTPUT_DIR/dylib_report.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DyLib Analysis Report</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        h1, h2, h3 {
            color: #2c3e50;
        }
        .file-section {
            margin-bottom: 40px;
            border: 1px solid #e1e4e8;
            border-radius: 6px;
            padding: 20px;
            background-color: #f6f8fa;
        }
        .section {
            margin-bottom: 20px;
        }
        table {
            border-collapse: collapse;
            width: 100%;
            margin-bottom: 20px;
        }
        th, td {
            text-align: left;
            padding: 12px;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f2f2f2;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        pre {
            background-color: #f6f8fa;
            border: 1px solid #e1e4e8;
            border-radius: 3px;
            padding: 16px;
            overflow: auto;
            font-family: SFMono-Regular, Consolas, 'Liberation Mono', Menlo, monospace;
            font-size: 85%;
        }
        .collapsible {
            background-color: #f2f2f2;
            color: #444;
            cursor: pointer;
            padding: 18px;
            width: 100%;
            border: none;
            text-align: left;
            outline: none;
            font-size: 15px;
            border-radius: 4px;
            margin-bottom: 10px;
        }
        .active, .collapsible:hover {
            background-color: #e6e6e6;
        }
        .content {
            padding: 0 18px;
            display: none;
            overflow: hidden;
            background-color: #f9f9f9;
            border-radius: 0 0 4px 4px;
        }
        .error {
            color: #721c24;
            background-color: #f8d7da;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <h1>DyLib Analysis Report</h1>
    <p>Analysis performed on $(date)</p>
    <p>Total .dylib files found: $(echo "$DYLIB_FILES" | wc -l | tr -d ' ')</p>
    
    <div id="toc">
        <h2>Table of Contents</h2>
        <ul>
EOF

# Process each .dylib file
for DYLIB in $DYLIB_FILES; do
    FILENAME=$(basename "$DYLIB")
    SAFE_FILENAME="${FILENAME//[^a-zA-Z0-9]/_}"
    
    echo "Analyzing $FILENAME..."
    
    # Create directory for this dylib's output files
    DYLIB_OUTPUT_DIR="$OUTPUT_DIR/${SAFE_FILENAME}_analysis"
    mkdir -p "$DYLIB_OUTPUT_DIR"
    
    # Add to table of contents
    echo "<li><a href=\"#${SAFE_FILENAME}\">${FILENAME}</a></li>" >> "$OUTPUT_DIR/dylib_report.html"
    
    # Start file section in HTML
    cat >> "$OUTPUT_DIR/dylib_report.html" << EOF
        </ul>
    </div>
    
    <div id="${SAFE_FILENAME}" class="file-section">
        <h2>${FILENAME}</h2>
EOF
    
    # File type and architecture
    FILE_INFO=$(file "$DYLIB" 2>&1)
    if [ $? -eq 0 ]; then
        echo "$FILE_INFO" > "$DYLIB_OUTPUT_DIR/file_info.txt"
        cat >> "$OUTPUT_DIR/dylib_report.html" << EOF
        <div class="section">
            <h3>File Type and Architecture</h3>
            <pre>$FILE_INFO</pre>
        </div>
EOF
    else
        cat >> "$OUTPUT_DIR/dylib_report.html" << EOF
        <div class="section">
            <h3>File Type and Architecture</h3>
            <div class="error">Error analyzing file type: $FILE_INFO</div>
        </div>
EOF
    fi
    
    # Mach-O header
    HEADER_INFO=$(otool -h "$DYLIB" 2>&1)
    if [ $? -eq 0 ]; then
        echo "$HEADER_INFO" > "$DYLIB_OUTPUT_DIR/header_info.txt"
        cat >> "$OUTPUT_DIR/dylib_report.html" << EOF
        <div class="section">
            <h3>Mach-O Header</h3>
            <pre>$HEADER_INFO</pre>
        </div>
EOF
    else
        cat >> "$OUTPUT_DIR/dylib_report.html" << EOF
        <div class="section">
            <h3>Mach-O Header</h3>
            <div class="error">Error analyzing Mach-O header: $HEADER_INFO</div>
        </div>
EOF
    fi
    
    # Install name
    INSTALL_NAME=$(otool -D "$DYLIB" 2>&1)
    if [ $? -eq 0 ]; then
        echo "$INSTALL_NAME" > "$DYLIB_OUTPUT_DIR/install_name.txt"
        cat >> "$OUTPUT_DIR/dylib_report.html" << EOF
        <div class="section">
            <h3>Install Name</h3>
            <pre>$INSTALL_NAME</pre>
        </div>
EOF
    else
        cat >> "$OUTPUT_DIR/dylib_report.html" << EOF
        <div class="section">
            <h3>Install Name</h3>
            <div class="error">Error retrieving install name: $INSTALL_NAME</div>
        </div>
EOF
    fi
    
    # Dependent libraries
    DEPENDENCIES=$(otool -L "$DYLIB" 2>&1)
    if [ $? -eq 0 ]; then
        echo "$DEPENDENCIES" > "$DYLIB_OUTPUT_DIR/dependencies.txt"
        cat >> "$OUTPUT_DIR/dylib_report.html" << EOF
        <div class="section">
            <h3>Dependent Libraries</h3>
            <pre>$DEPENDENCIES</pre>
        </div>
EOF
    else
        cat >> "$OUTPUT_DIR/dylib_report.html" << EOF
        <div class="section">
            <h3>Dependent Libraries</h3>
            <div class="error">Error analyzing dependencies: $DEPENDENCIES</div>
        </div>
EOF
    fi
    
    # Symbols
    SYMBOLS=$(nm "$DYLIB" 2>&1)
    if [ $? -eq 0 ]; then
        echo "$SYMBOLS" > "$DYLIB_OUTPUT_DIR/symbols.txt"
        # Get a limited subset for the HTML report
        SYMBOLS_PREVIEW=$(echo "$SYMBOLS" | head -n 100)
        SYMBOLS_COUNT=$(echo "$SYMBOLS" | wc -l | tr -d ' ')
        
        cat >> "$OUTPUT_DIR/dylib_report.html" << EOF
        <div class="section">
            <h3>Symbols (showing first 100 of $SYMBOLS_COUNT)</h3>
            <button class="collapsible">Show/Hide Symbols</button>
            <div class="content">
                <pre>$SYMBOLS_PREVIEW</pre>
                <p>Full symbols list available in <a href="${SAFE_FILENAME}_analysis/symbols.txt">symbols.txt</a></p>
            </div>
        </div>
EOF
    else
        cat >> "$OUTPUT_DIR/dylib_report.html" << EOF
        <div class="section">
            <h3>Symbols</h3>
            <div class="error">Error extracting symbols: $SYMBOLS</div>
        </div>
EOF
    fi
    
    # Strings
    STRINGS_OUTPUT=$(strings "$DYLIB" 2>&1)
    if [ $? -eq 0 ]; then
        echo "$STRINGS_OUTPUT" > "$DYLIB_OUTPUT_DIR/strings.txt"
        # Get a limited subset for the HTML report
        STRINGS_PREVIEW=$(echo "$STRINGS_OUTPUT" | head -n 100)
        STRINGS_COUNT=$(echo "$STRINGS_OUTPUT" | wc -l | tr -d ' ')
        
        cat >> "$OUTPUT_DIR/dylib_report.html" << EOF
        <div class="section">
            <h3>Strings (showing first 100 of $STRINGS_COUNT)</h3>
            <button class="collapsible">Show/Hide Strings</button>
            <div class="content">
                <pre>$STRINGS_PREVIEW</pre>
                <p>Full strings list available in <a href="${SAFE_FILENAME}_analysis/strings.txt">strings.txt</a></p>
            </div>
        </div>
EOF
    else
        cat >> "$OUTPUT_DIR/dylib_report.html" << EOF
        <div class="section">
            <h3>Strings</h3>
            <div class="error">Error extracting strings: $STRINGS_OUTPUT</div>
        </div>
EOF
    fi
    
    # Disassembly
    DISASSEMBLY=$(otool -tv "$DYLIB" 2>&1)
    if [ $? -eq 0 ]; then
        echo "$DISASSEMBLY" > "$DYLIB_OUTPUT_DIR/disassembly.txt"
        # Get a limited subset for the HTML report
        DISASSEMBLY_PREVIEW=$(echo "$DISASSEMBLY" | head -n 100)
        DISASSEMBLY_COUNT=$(echo "$DISASSEMBLY" | wc -l | tr -d ' ')
        
        cat >> "$OUTPUT_DIR/dylib_report.html" << EOF
        <div class="section">
            <h3>Disassembly (showing first 100 of $DISASSEMBLY_COUNT lines)</h3>
            <button class="collapsible">Show/Hide Disassembly</button>
            <div class="content">
                <pre>$DISASSEMBLY_PREVIEW</pre>
                <p>Full disassembly available in <a href="${SAFE_FILENAME}_analysis/disassembly.txt">disassembly.txt</a></p>
            </div>
        </div>
EOF
    else
        cat >> "$OUTPUT_DIR/dylib_report.html" << EOF
        <div class="section">
            <h3>Disassembly</h3>
            <div class="error">Error disassembling code: $DISASSEMBLY</div>
        </div>
EOF
    fi
    
    # Close file section
    echo "</div>" >> "$OUTPUT_DIR/dylib_report.html"
done

# Finish HTML report
cat >> "$OUTPUT_DIR/dylib_report.html" << EOF
    <script>
        // JavaScript for collapsible sections
        var coll = document.getElementsByClassName("collapsible");
        for (var i = 0; i < coll.length; i++) {
            coll[i].addEventListener("click", function() {
                this.classList.toggle("active");
                var content = this.nextElementSibling;
                if (content.style.display === "block") {
                    content.style.display = "none";
                } else {
                    content.style.display = "block";
                }
            });
        }
    </script>
</body>
</html>
EOF

echo "Analysis complete. Results saved to $OUTPUT_DIR/dylib_report.html"

