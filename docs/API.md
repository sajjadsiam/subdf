# SubdomainFury API Documentation

## Overview

SubdomainFury provides several API endpoints and integrations for automation and extensibility. This document covers the available APIs and their usage.

## Available APIs

### 1. VirusTotal Integration

```bash
# API Endpoint
https://www.virustotal.com/api/v3/domains/{domain}/subdomains

# Headers
x-apikey: YOUR_VT_API_KEY

# Example Response
{
    "data": [
        {
            "id": "subdomain1.example.com",
            "type": "domain"
        }
    ]
}
```

### 2. GitHub API Integration

```bash
# API Endpoint
https://api.github.com/search/code

# Headers
Authorization: token YOUR_GITHUB_TOKEN

# Parameters
q: "example.com"
per_page: 100

# Example Response
{
    "items": [
        {
            "name": "config.json",
            "path": "src/config.json",
            "content": "..."
        }
    ]
}
```

### 3. URLScan.io Integration

```bash
# API Endpoint
https://urlscan.io/api/v1/search/

# Parameters
q: domain:example.com
size: 10000

# Example Response
{
    "results": [
        {
            "page": {
                "domain": "subdomain.example.com",
                "ip": "1.2.3.4"
            }
        }
    ]
}
```

## Rate Limiting

| API | Rate Limit | Time Window |
|-----|------------|------------|
| VirusTotal | 4 requests | Per minute |
| GitHub | 5000 requests | Per hour |
| URLScan | 1000 requests | Per day |

## Error Handling

### Common Error Codes

```json
{
    "401": "Unauthorized - Check API key",
    "403": "Forbidden - Rate limit exceeded",
    "404": "Not Found - Invalid domain",
    "429": "Too Many Requests",
    "500": "Internal Server Error"
}
```

### Error Response Format

```json
{
    "error": {
        "code": "401",
        "message": "Invalid API key provided",
        "details": "Please check your API key or obtain a new one"
    }
}
```

## Automation Examples

### 1. Bash Script Integration

```bash
#!/bin/bash

# VirusTotal API Call
vt_query() {
    curl -s -H "x-apikey: $VT_API_KEY" \
        "https://www.virustotal.com/api/v3/domains/$1/subdomains"
}

# GitHub API Call
github_query() {
    curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/search/code?q=$1"
}
```

### 2. Python Integration

```python
import requests

def vt_query(domain, api_key):
    headers = {'x-apikey': api_key}
    url = f'https://www.virustotal.com/api/v3/domains/{domain}/subdomains'
    response = requests.get(url, headers=headers)
    return response.json()

def github_query(domain, token):
    headers = {'Authorization': f'token {token}'}
    url = f'https://api.github.com/search/code?q={domain}'
    response = requests.get(url, headers=headers)
    return response.json()
```

## Best Practices

1. API Key Management
```bash
# Store API keys securely
export VT_API_KEY="your_key"
export GITHUB_TOKEN="your_token"
```

2. Rate Limit Handling
```python
import time

def rate_limited_request(url, headers):
    response = requests.get(url, headers=headers)
    if response.status_code == 429:
        retry_after = int(response.headers.get('Retry-After', 60))
        time.sleep(retry_after)
        return requests.get(url, headers=headers)
    return response
```

3. Error Recovery
```python
def resilient_request(url, headers, max_retries=3):
    for attempt in range(max_retries):
        try:
            response = requests.get(url, headers=headers)
            response.raise_for_status()
            return response
        except requests.exceptions.RequestException as e:
            if attempt == max_retries - 1:
                raise
            time.sleep(2 ** attempt)
```

## API Response Schemas

### 1. Subdomain Schema

```json
{
    "type": "object",
    "properties": {
        "subdomain": {
            "type": "string",
            "description": "Discovered subdomain"
        },
        "ip": {
            "type": "string",
            "description": "IP address"
        },
        "status": {
            "type": "integer",
            "description": "HTTP status code"
        }
    }
}
```

### 2. JavaScript Analysis Schema

```json
{
    "type": "object",
    "properties": {
        "url": {
            "type": "string",
            "description": "JavaScript file URL"
        },
        "secrets": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "type": {
                        "type": "string",
                        "description": "Type of secret"
                    },
                    "value": {
                        "type": "string",
                        "description": "Found secret value"
                    }
                }
            }
        }
    }
}
```

## Testing APIs

### 1. API Health Check

```bash
# Check API status
curl -I https://www.virustotal.com/api/v3/
curl -I https://api.github.com/
```

### 2. Test API Keys

```bash
# Test VirusTotal API
curl -H "x-apikey: $VT_API_KEY" \
    "https://www.virustotal.com/api/v3/users/current"

# Test GitHub API
curl -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/user"
```

## API Versioning

Current API versions:
- VirusTotal: v3
- GitHub: v3
- URLScan: v1

## Support

For API-related issues:
- GitHub Issues: [Link to Issues]
- Email: api-support@subdomainfury.com
- Documentation Updates: Check CHANGELOG.md