# 🎯 SubdomainFury Documentation

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)
- [Configuration](#configuration)
- [Modules](#modules)
- [Output](#output)
- [API Integration](#api-integration)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Installation

### Prerequisites
```bash
# Required packages
- Go 1.19 or higher
- Python 3.8 or higher
- jq
- git
```

### Quick Install
```bash
# Clone the repository
git clone https://github.com/sajjadsiam/subdf.git
y.git

# Navigate to directory
cd subdf


# Make scripts executable
chmod +x install.sh subdf.sh

# Run installation script
./install.sh
```

### Manual Installation
If you prefer to install tools manually:

```bash
# Go tools
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest
go install -v github.com/ffuf/ffuf/v2@latest
go install -v github.com/tomnomnom/assetfinder@latest
go install -v github.com/tomnomnom/waybackurls@latest
go install -v github.com/hakluke/hakrawler@latest

# Python tools
pip3 install arjun dirsearch

# System packages
sudo apt install -y amass findomain aquatone chromium-browser
```

## Usage

### Basic Usage
```bash
./subdf.sh -d example.com -o output.txt -t GITHUB_TOKEN
```

### Advanced Usage
```bash
./subdf.sh -d example.com -o output.txt -t GITHUB_TOKEN -vt VIRUSTOTAL_API -a -sc -js -p -w wordlist.txt -v
```

### Command Line Arguments
```
Options:
  -d   Target domain (e.g., target.com)
  -o   Output file to save alive subdomains
  -a   Run active subdomain enumeration
  -t   GitHub token for github-subdomains tool
  -v   Verbose output (shows progress)
  -vt  VirusTotal API key
  -sc  Enable screenshot capture using aquatone
  -js  Enable JavaScript file analysis
  -p   Enable parameter discovery
  -w   Custom wordlist for content discovery
```

## Features

### 1. Passive Enumeration
- Certificate Transparency (crt.sh)
- Wayback Machine
- VirusTotal
- GitHub
- DNS Records
- Search Engines

### 2. Active Enumeration
- DNS Bruteforcing
- Zone Transfer
- AXFR Records
- Wildcard Detection
- Port Scanning

### 3. JavaScript Analysis
- Secret Detection
- API Endpoint Discovery
- Sensitive Information
- Third-party Services

### 4. Parameter Discovery
- GET/POST Parameters
- Hidden Fields
- API Parameters
- URL Parameters

### 5. Visual Reconnaissance
- Screenshot Capture
- Technology Detection
- Visual Similarity
- Layout Analysis

## Configuration

### API Keys Configuration
Create a `.env` file:
```bash
GITHUB_TOKEN=your_github_token
VIRUSTOTAL_API=your_vt_api_key
CHAOS_API=your_chaos_key
```

### Tool Configuration
```bash
# Configure rate limiting
RATE_LIMIT=50
TIMEOUT=30

# Configure threads
MAX_THREADS=10

# Configure output
SCREENSHOT_TIMEOUT=30000
```

## Modules

### 1. Passive Module
```bash
# Individual passive tools
./subdf.sh -d example.com --passive-only
```

### 2. Active Module
```bash
# Active enumeration with custom wordlist
./subdf.sh -d example.com -a -w custom_wordlist.txt
```

### 3. JavaScript Module
```bash
# JavaScript analysis only
./subdf.sh -d example.com --js-only
```

### 4. Parameter Discovery
```bash
# Parameter discovery with custom settings
./subdf.sh -d example.com -p --param-wordlist wordlist.txt
```

## Output Structure

```
example.com-recon/
├── passive/
│   ├── subfinder.txt
│   ├── findomain.txt
│   ├── crtsh.txt
│   └── github.txt
├── active/
│   ├── amass.txt
│   ├── ffuf.json
│   └── dnsx.txt
├── js-analysis/
│   ├── jsfiles.txt
│   ├── secrets.txt
│   └── endpoints.txt
├── parameters/
│   ├── urls.txt
│   └── discovered.json
├── screenshots/
├── report.txt
└── output.txt
```

## API Integration

### 1. VirusTotal
```bash
# Using VirusTotal API
./subdf.sh -d example.com -vt YOUR_VT_API_KEY
```

### 2. GitHub
```bash
# Using GitHub API
./subdf.sh -d example.com -t YOUR_GITHUB_TOKEN
```

## Examples

### 1. Basic Enumeration
```bash
# Quick scan
./subdf.sh -d example.com -o results.txt -t GITHUB_TOKEN
```

### 2. Full Scan
```bash
# Comprehensive scan
./subdf.sh -d example.com -o results.txt -t GITHUB_TOKEN -a -sc -js -p -v
```

### 3. Custom Scan
```bash
# Custom configuration
./subdf.sh -d example.com -w custom_wordlist.txt --rate-limit 100
```

## Troubleshooting

### Common Issues

1. Tool Installation Failures
```bash
# Retry installation
./install.sh --force
```

2. API Rate Limiting
```bash
# Adjust rate limiting
export RATE_LIMIT=30
```

3. Memory Issues
```bash
# Reduce parallel processes
export MAX_THREADS=5
```

### Debug Mode
```bash
# Enable debug output
./subdf.sh -d example.com -v --debug
```

### Logs
```bash
# Check logs
tail -f example.com-recon/debug.log
```

## Contributing

### Development Setup
```bash
# Setup development environment
./setup_dev.sh

# Run tests
./tests/run_tests.sh
```

### Pull Request Process
1. Fork the repository
2. Create feature branch
3. Add tests
4. Update documentation
5. Submit pull request

### Code Style
- Follow shell script best practices
- Add comments for complex operations
- Use meaningful variable names
- Include error handling

## Support

### Community
- GitHub Issues: [Link to Issues]
- Discord: [Discord Invite Link]
- Twitter: [@SubdomainFury]

### Updates
- Star the repository for updates
- Watch releases for notifications
- Check CHANGELOG.md for changes