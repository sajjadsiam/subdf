# SubdomainFury - Advanced Usage Guide

## Advanced Features

### 1. Custom Module Development

Create custom modules in `modules/` directory:

```bash
# Template for custom module
#!/bin/bash

custom_module() {
    local domain=$1
    local output_dir=$2
    
    # Your custom logic here
    echo "[+] Running custom module for $domain"
}
```

### 2. Advanced JavaScript Analysis

Fine-tune JavaScript analysis:

```bash
# Custom JavaScript patterns
./subdf.sh -d example.com --js-patterns custom_patterns.txt

# Pattern file format:
aws_key_pattern=AWS_KEY_ID_[A-Z0-9]{16,}
api_key_pattern=api[_-]key[_-]?[A-Za-z0-9]{32}
```

### 3. Advanced Parameter Discovery

Custom parameter discovery settings:

```bash
# Aggressive parameter discovery
./subdf.sh -d example.com -p --aggressive

# Custom parameter wordlist
./subdf.sh -d example.com -p --param-wordlist custom_params.txt

# Specific HTTP methods
./subdf.sh -d example.com -p --methods GET,POST,PUT
```

### 4. Custom Workflows

Create custom workflow files:

```yaml
# workflow.yml
name: Custom Workflow
steps:
  - name: Passive Enumeration
    tools:
      - subfinder
      - assetfinder
    options:
      timeout: 300
      
  - name: Active Scanning
    tools:
      - amass
      - ffuf
    options:
      rate_limit: 100
      
  - name: Analysis
    tools:
      - httpx
      - nuclei
    options:
      threads: 50
```

### 5. Advanced Output Filtering

Filter and format output:

```bash
# Filter by status codes
./subdf.sh -d example.com --status-codes 200,301,302

# Filter by content type
./subdf.sh -d example.com --content-type html,javascript

# Custom output format
./subdf.sh -d example.com --format "{{.subdomain}},{{.status}},{{.ip}}"
```

## Advanced Configuration

### 1. Rate Limiting Configuration

Fine-tune rate limiting:

```bash
# Config file: config/rate_limits.conf
SUBFINDER_RATE=100
GITHUB_RATE=30
VIRUSTOTAL_RATE=4
CUSTOM_RATE=50

# Apply configuration
./subdf.sh -d example.com --config config/rate_limits.conf
```

### 2. Proxy Configuration

Set up proxy settings:

```bash
# Direct proxy configuration
./subdf.sh -d example.com --proxy http://proxy.example.com:8080

# Proxy chains
./subdf.sh -d example.com --proxy-chains proxychains.conf

# SOCKS proxy
./subdf.sh -d example.com --socks5 127.0.0.1:9050
```

### 3. Custom DNS Configuration

Configure DNS settings:

```bash
# Custom resolvers
./subdf.sh -d example.com --resolvers resolvers.txt

# DNS over HTTPS
./subdf.sh -d example.com --doh https://cloudflare-dns.com/dns-query

# Custom DNS timeout
./subdf.sh -d example.com --dns-timeout 5
```

## Advanced Analysis

### 1. Pattern Matching

Create custom pattern files:

```bash
# patterns.txt
# Format: name:pattern
aws_key:[A-Z0-9]{20}
api_key:api[_-]key[_-]?[A-Za-z0-9]{32}
password:(?i)password['"]\s*[:=]\s*['"][^'"]+['"]

# Use patterns
./subdf.sh -d example.com --patterns patterns.txt
```

### 2. Custom Nuclei Templates

Create and use custom templates:

```yaml
# custom-template.yaml
id: custom-check
info:
  name: Custom Security Check
  severity: medium
requests:
  - method: GET
    path:
      - "{{BaseURL}}/api/v1/config"
    matchers:
      - type: word
        words:
          - "api_key"
          - "secret"
```

### 3. Advanced Screenshot Configuration

Configure screenshot capture:

```bash
# Screenshot specific paths
./subdf.sh -d example.com -sc --paths /login,/admin,/dashboard

# Custom screenshot timeout
./subdf.sh -d example.com -sc --screenshot-timeout 60000

# Capture full page
./subdf.sh -d example.com -sc --full-page
```

## Performance Optimization

### 1. Memory Management

Control memory usage:

```bash
# Set memory limits
./subdf.sh -d example.com --max-memory 4G

# Chunk processing
./subdf.sh -d example.com --chunk-size 1000
```

### 2. Parallel Processing

Configure parallel execution:

```bash
# Set thread count
./subdf.sh -d example.com --threads 50

# Process distribution
./subdf.sh -d example.com --distributed
```

### 3. Cache Management

Configure caching:

```bash
# Enable caching
./subdf.sh -d example.com --cache

# Set cache duration
./subdf.sh -d example.com --cache-ttl 3600

# Clear cache
./subdf.sh --clear-cache
```

## Integration Examples

### 1. CI/CD Integration

```yaml
# .github/workflows/subdomainfury.yml
name: SubdomainFury Scan
on:
  schedule:
    - cron: '0 0 * * *'
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install SubdomainFury
        run: ./install.sh
      - name: Run Scan
        run: ./subdf.sh -d ${{ secrets.TARGET_DOMAIN }} -t ${{ secrets.GITHUB_TOKEN }}
```

### 2. API Integration

```python
import requests

def subdomainfury_scan(domain, api_key):
    url = f"https://api.subdomainfury.com/v1/scan"
    headers = {"Authorization": f"Bearer {api_key}"}
    data = {"domain": domain}
    response = requests.post(url, headers=headers, json=data)
    return response.json()
```

## Troubleshooting Advanced Issues

### 1. Debug Mode

Enable detailed debugging:

```bash
# Enable debug mode
./subdf.sh -d example.com --debug

# Save debug logs
./subdf.sh -d example.com --debug --log-file debug.log
```

### 2. Performance Analysis

Monitor performance:

```bash
# Enable performance monitoring
./subdf.sh -d example.com --perf-monitor

# Generate performance report
./subdf.sh -d example.com --perf-report
```

### 3. Error Analysis

Analyze errors:

```bash
# Show error details
./subdf.sh -d example.com --show-errors

# Error statistics
./subdf.sh -d example.com --error-stats
```

## Custom Reporting

### 1. Report Templates

Create custom report templates:

```html
<!-- template.html -->
<html>
<body>
    <h1>Scan Report: {{.domain}}</h1>
    <table>
        {{range .subdomains}}
        <tr>
            <td>{{.name}}</td>
            <td>{{.ip}}</td>
            <td>{{.status}}</td>
        </tr>
        {{end}}
    </table>
</body>
</html>
```

### 2. Export Formats

Configure export formats:

```bash
# Export as JSON
./subdf.sh -d example.com --export json

# Export as CSV
./subdf.sh -d example.com --export csv

# Custom template
./subdf.sh -d example.com --template template.html
```