#!/bin/bash
# scripts/generate_report.sh

# Create report directory
mkdir -p security-results

# Generate the report
cat << 'EOF' > report_template.html
<!DOCTYPE html>
<html>
<head>
    <title>Security Scan Results</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 20px;
            line-height: 1.6;
            color: #333;
        }
        .tool-section { 
            margin-bottom: 40px;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .severity-critical { color: darkred; font-weight: bold; }
        .severity-high { color: red; }
        .severity-medium { color: orange; }
        .severity-low { color: #999900; }
        .status-failed { color: red; }
        .status-passed { color: green; }
        .status-skipped { color: gray; }
        .vulnerability-item {
            margin: 10px 0;
            padding: 10px;
            background-color: #f9f9f9;
            border-left: 4px solid #ddd;
        }
        .summary-box {
            background-color: #f0f0f0;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .no-results {
            color: #666;
            font-style: italic;
        }
        .stats {
            display: flex;
            justify-content: space-around;
            margin: 20px 0;
        }
        .stat-item {
            text-align: center;
            padding: 10px;
        }
    </style>
</head>
<body>
    <h1>Security Scan Results</h1>
    <div class='summary-box'>
        <h2>Executive Summary</h2>
        <p>Scan completed at DATETIME</p>
        <p>Repository: REPO_NAME</p>
        <p>Branch: BRANCH_NAME</p>
    </div>
    
    SCAN_RESULTS
</body>
</html>
EOF

# Function to process scan results
process_results() {
    local output=""
    
    # Process SonarQube Results
    output+="<div class='tool-section'>"
    output+="<h2>Static Application Security Testing (SonarQube)</h2>"
    if [ -f "security-results/sonarqube/issues.json" ]; then
        output+=$(jq -r '.issues[] | "<div class=\"vulnerability-item severity-\(.severity)\"><h3>\(.message)</h3><p>Location: \(.component)</p><p>Type: \(.type)</p></div>"' security-results/sonarqube/issues.json 2>/dev/null || echo "<p class='no-results'>No issues found</p>")
    else
        output+="<p class='no-results'>SonarQube scan was not completed</p>"
    fi
    output+="</div>"
    
    # Process Snyk Results
    output+="<div class='tool-section'>"
    output+="<h2>Software Composition Analysis (Snyk)</h2>"
    if [ -f "security-results/snyk/scan-results.json" ]; then
        output+=$(jq -r '.vulnerabilities[]? | "<div class=\"vulnerability-item severity-\(.severity)\"><h3>\(.title)</h3><p>Package: \(.package)</p><p>Version: \(.version)</p><p>Fix: \(.fix.upgradeTo // "No fix available")</p></div>"' security-results/snyk/scan-results.json 2>/dev/null || echo "<p class='no-results'>No vulnerabilities found</p>")
    else
        output+="<p class='no-results'>Snyk scan was not completed</p>"
    fi
    output+="</div>"
    
    # Process Trivy Results
    output+="<div class='tool-section'>"
    output+="<h2>Container Security (Trivy)</h2>"
    if [ -f "security-results/trivy/scan-results.json" ]; then
        output+=$(jq -r '.Results[]? | .Vulnerabilities[]? | "<div class=\"vulnerability-item severity-\(.Severity | ascii_downcase)\"><h3>\(.VulnerabilityID): \(.Title)</h3><p>Package: \(.PkgName)</p><p>Installed Version: \(.InstalledVersion)</p><p>Fixed Version: \(.FixedVersion // "No fix available")</p></div>"' security-results/trivy/scan-results.json 2>/dev/null || echo "<p class='no-results'>No vulnerabilities found</p>")
    else
        output+="<p class='no-results'>Trivy scan was not completed</p>"
    fi
    output+="</div>"
    
    # Process ZAP Results
    output+="<div class='tool-section'>"
    output+="<h2>Dynamic Application Security Testing (ZAP)</h2>"
    if [ -f "security-results/zap/zap-output.json" ]; then
        output+=$(jq -r '.site[]?.alerts[]? | "<div class=\"vulnerability-item severity-\(.risk | ascii_downcase)\"><h3>\(.name)</h3><p>Risk Level: \(.risk)</p><p>Description: \(.description)</p><p>Solution: \(.solution)</p></div>"' security-results/zap/zap-output.json 2>/dev/null || echo "<p class='no-results'>No vulnerabilities found</p>")
    else
        output+="<p class='no-results'>ZAP scan was not completed</p>"
    fi
    output+="</div>"
    
    echo "$output"
}

# Generate the final report
SCAN_RESULTS=$(process_results)
DATETIME=$(date)
REPO_NAME=$GITHUB_REPOSITORY
BRANCH_NAME=$GITHUB_REF

# Replace placeholders in template
sed -e "s|DATETIME|$DATETIME|g" \
    -e "s|REPO_NAME|$REPO_NAME|g" \
    -e "s|BRANCH_NAME|$BRANCH_NAME|g" \
    -e "s|SCAN_RESULTS|$SCAN_RESULTS|g" \
    report_template.html > security-results/report.html

# Clean up template
rm report_template.html#!/bin/bash
# scripts/generate_report.sh

# Create report directory
mkdir -p security-results

# Generate the report
cat << 'EOF' > report_template.html
<!DOCTYPE html>
<html>
<head>
    <title>Security Scan Results</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 20px;
            line-height: 1.6;
            color: #333;
        }
        .tool-section { 
            margin-bottom: 40px;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .severity-critical { color: darkred; font-weight: bold; }
        .severity-high { color: red; }
        .severity-medium { color: orange; }
        .severity-low { color: #999900; }
        .status-failed { color: red; }
        .status-passed { color: green; }
        .status-skipped { color: gray; }
        .vulnerability-item {
            margin: 10px 0;
            padding: 10px;
            background-color: #f9f9f9;
            border-left: 4px solid #ddd;
        }
        .summary-box {
            background-color: #f0f0f0;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .no-results {
            color: #666;
            font-style: italic;
        }
        .stats {
            display: flex;
            justify-content: space-around;
            margin: 20px 0;
        }
        .stat-item {
            text-align: center;
            padding: 10px;
        }
    </style>
</head>
<body>
    <h1>Security Scan Results</h1>
    <div class='summary-box'>
        <h2>Executive Summary</h2>
        <p>Scan completed at DATETIME</p>
        <p>Repository: REPO_NAME</p>
        <p>Branch: BRANCH_NAME</p>
    </div>
    
    SCAN_RESULTS
</body>
</html>
EOF

# Function to process scan results
process_results() {
    local output=""
    
    # Process SonarQube Results
    output+="<div class='tool-section'>"
    output+="<h2>Static Application Security Testing (SonarQube)</h2>"
    if [ -f "security-results/sonarqube/issues.json" ]; then
        output+=$(jq -r '.issues[] | "<div class=\"vulnerability-item severity-\(.severity)\"><h3>\(.message)</h3><p>Location: \(.component)</p><p>Type: \(.type)</p></div>"' security-results/sonarqube/issues.json 2>/dev/null || echo "<p class='no-results'>No issues found</p>")
    else
        output+="<p class='no-results'>SonarQube scan was not completed</p>"
    fi
    output+="</div>"
    
    # Process Snyk Results
    output+="<div class='tool-section'>"
    output+="<h2>Software Composition Analysis (Snyk)</h2>"
    if [ -f "security-results/snyk/scan-results.json" ]; then
        output+=$(jq -r '.vulnerabilities[]? | "<div class=\"vulnerability-item severity-\(.severity)\"><h3>\(.title)</h3><p>Package: \(.package)</p><p>Version: \(.version)</p><p>Fix: \(.fix.upgradeTo // "No fix available")</p></div>"' security-results/snyk/scan-results.json 2>/dev/null || echo "<p class='no-results'>No vulnerabilities found</p>")
    else
        output+="<p class='no-results'>Snyk scan was not completed</p>"
    fi
    output+="</div>"
    
    # Process Trivy Results
    output+="<div class='tool-section'>"
    output+="<h2>Container Security (Trivy)</h2>"
    if [ -f "security-results/trivy/scan-results.json" ]; then
        output+=$(jq -r '.Results[]? | .Vulnerabilities[]? | "<div class=\"vulnerability-item severity-\(.Severity | ascii_downcase)\"><h3>\(.VulnerabilityID): \(.Title)</h3><p>Package: \(.PkgName)</p><p>Installed Version: \(.InstalledVersion)</p><p>Fixed Version: \(.FixedVersion // "No fix available")</p></div>"' security-results/trivy/scan-results.json 2>/dev/null || echo "<p class='no-results'>No vulnerabilities found</p>")
    else
        output+="<p class='no-results'>Trivy scan was not completed</p>"
    fi
    output+="</div>"
    
    # Process ZAP Results
    output+="<div class='tool-section'>"
    output+="<h2>Dynamic Application Security Testing (ZAP)</h2>"
    if [ -f "security-results/zap/zap-output.json" ]; then
        output+=$(jq -r '.site[]?.alerts[]? | "<div class=\"vulnerability-item severity-\(.risk | ascii_downcase)\"><h3>\(.name)</h3><p>Risk Level: \(.risk)</p><p>Description: \(.description)</p><p>Solution: \(.solution)</p></div>"' security-results/zap/zap-output.json 2>/dev/null || echo "<p class='no-results'>No vulnerabilities found</p>")
    else
        output+="<p class='no-results'>ZAP scan was not completed</p>"
    fi
    output+="</div>"
    
    echo "$output"
}

# Generate the final report
SCAN_RESULTS=$(process_results)
DATETIME=$(date)
REPO_NAME=$GITHUB_REPOSITORY
BRANCH_NAME=$GITHUB_REF

# Replace placeholders in template
sed -e "s|DATETIME|$DATETIME|g" \
    -e "s|REPO_NAME|$REPO_NAME|g" \
    -e "s|BRANCH_NAME|$BRANCH_NAME|g" \
    -e "s|SCAN_RESULTS|$SCAN_RESULTS|g" \
    report_template.html > security-results/report.html

# Clean up template
rm report_template.html