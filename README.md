# DyLib Analyzer

This repository contains a GitHub Actions workflow and Bash script to analyze `.dylib` files located in the root of your GitHub repository.

## Features

The analyzer performs the following analysis on each `.dylib` file:

1. Identifies file type and architecture (using `file`)
2. Extracts Mach-O header information (using `otool -h`)
3. Retrieves the install name (using `otool -D`)
4. Lists dependent libraries (using `otool -L`)
5. Extracts symbols, including exported and undefined symbols (using `nm`)
6. Extracts readable strings (using `strings`)
7. Disassembles the code to show assembly instructions (using `otool -tv`)

## How to Use

### Adding .dylib Files

Place any `.dylib` files you want to analyze in the root directory of your repository.

### Running the Analysis

The analysis can be triggered in three ways:

1. **Automatically on Push**: When you push changes to the `main` branch
2. **Automatically on Pull Request**: When a pull request is created against the `main` branch
3. **Manually**: By triggering the workflow from the GitHub Actions tab

### Viewing Results

After the workflow completes:

1. Go to the Actions tab in your GitHub repository
2. Click on the completed workflow run
3. Scroll down to the Artifacts section
4. Download the `dylib-analysis-results` artifact
5. Extract the downloaded zip file
6. Open `dylib_report.html` in a web browser to view the analysis results

The HTML report provides a comprehensive view of all analyzed `.dylib` files with collapsible sections for large outputs like strings and disassembly.

## Running Locally

If you want to run the analysis locally:

1. Clone the repository
2. Place your `.dylib` files in the repository root
3. Make the script executable: `chmod +x analyze_dylib.sh`
4. Run the script: `./analyze_dylib.sh`
5. View the results in the `analysis_output` directory

## Requirements

The script uses macOS-native tools and requires no additional installations when run on a macOS system or the GitHub Actions `macos-latest` runner.

## Error Handling

The script handles errors gracefully:

- If no `.dylib` files are found, it creates an HTML report indicating this
- If any analysis tool fails for a specific file, the error is captured and displayed in the HTML report

