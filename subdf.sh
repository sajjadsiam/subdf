#!/bin/bash

# Function to display help
show_help() {
    echo "Usage: subdf -d <domain> -o <output_file> [-a] -t <github_token> [-v] [-vt <virustotal_api>] [-sc] [-js] [-p] [-w <wordlist>]"
    echo "  -d   Target domain (e.g., target.com)"
    echo "  -o   Output file to save alive subdomains (e.g., target.txt)"
    echo "  -a   Run active subdomain enumeration (default is passive)"
    echo "  -t   GitHub token for github-subdomains tool"
    echo "  -v   Verbose output (shows progress for each tool)"
    echo "  -vt  VirusTotal API key"
    echo "  -sc  Enable screenshot capture using aquatone"
    echo "  -js  Enable JavaScript file analysis"
    echo "  -p   Enable parameter discovery using arjun"
    echo "  -w   Custom wordlist for directory bruteforcing"
    exit 1
}

# Check if required tools are installed
check_requirements() {
    local tools=("amass" "subfinder" "assetfinder" "findomain" "github-subdomains" "httpx" "jq" "curl" "chaos" "gauplus" "waybackurls" "gospider" "nuclei" "dnsx" "anew" "puredns")
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "[-] $tool is not installed. Please install it before running this script."
            exit 1
        fi
    done
    echo "[+] All required tools are installed."
}

# Parse command-line arguments
while getopts "d:o:at:vvt:scjspw:" opt; do
    case "$opt" in
        d) DOMAIN=$OPTARG ;;
        o) OUTPUT_FILE=$OPTARG ;;
        a) ACTIVE=true ;;
        t) GITHUB_TOKEN=$OPTARG ;;
        v) VERBOSE=true ;;
        vt) VT_API_KEY=$OPTARG ;;
        sc) SCREENSHOT=true ;;
        js) JS_ANALYSIS=true ;;
        p) PARAM_DISCOVERY=true ;;
        w) WORDLIST=$OPTARG ;;
        *) show_help ;;
    esac
done

# Ensure both domain and output file are provided
if [ -z "$DOMAIN" ] || [ -z "$OUTPUT_FILE" ] || [ -z "$GITHUB_TOKEN" ]; then
    show_help
fi

# Create necessary directories
WORKING_DIR="$DOMAIN-recon"
mkdir -p "$WORKING_DIR"
cd "$WORKING_DIR"

# Function to log verbose output
log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo "[*] $1"
    fi
}

# Function to discover subdomains
subdf() {
    # Check requirements first
    check_requirements

    echo "[+] Starting subdomain enumeration for $DOMAIN..."
    echo "[+] Results will be saved in $WORKING_DIR"

    # Create temporary files directory
    mkdir -p tmp

    # Passive enumeration tools
    echo "[+] Running passive subdomain discovery..."

    # Amass passive
    log_verbose "Running Amass passive scan..."
    amass enum -passive -d $DOMAIN | anew tmp/amass_passive.txt &

    # Subfinder
    log_verbose "Running Subfinder..."
    subfinder -d $DOMAIN -all -silent | anew tmp/subfinder.txt &

    # Assetfinder
    log_verbose "Running Assetfinder..."
    assetfinder --subs-only $DOMAIN | anew tmp/assetfinder.txt &

    # Findomain
    log_verbose "Running Findomain..."
    findomain -t $DOMAIN -q | anew tmp/findomain.txt &

    # GitHub Subdomains
    log_verbose "Running GitHub-subdomains..."
    github-subdomains -d $DOMAIN -t $GITHUB_TOKEN | anew tmp/github_subdomains.txt &

    # Chaos
    log_verbose "Running Chaos..."
    chaos -d $DOMAIN -silent | anew tmp/chaos.txt &

    # crt.sh
    log_verbose "Querying crt.sh..."
    curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" | jq -r '.[].name_value' | grep -Po '(\w+\.\w+\.\w+)$' | anew tmp/crtsh.txt &

    # Rapid7 Forward DNS
    log_verbose "Querying Rapid7 Forward DNS..."
    curl -s "https://dns.bufferover.run/dns?q=.$DOMAIN" | jq -r .FDNS_A[] | cut -d',' -f2 | grep -F ".$DOMAIN" | anew tmp/rapid7.txt &

    # Web Archive
    log_verbose "Running Waybackurls..."
    waybackurls $DOMAIN | unfurl -u domains | grep "$DOMAIN" | anew tmp/wayback.txt &

    # GAU (Get All URLs)
    log_verbose "Running GAU..."
    gauplus -subs $DOMAIN | unfurl -u domains | grep "$DOMAIN" | anew tmp/gau.txt &

    # Wait for all background processes to complete
    wait
    echo "[+] Passive enumeration completed"

    # Combine all passive results
    cat tmp/*.txt | sort -u > all_passive_subdomains.txt
    echo "[+] Found $(wc -l < all_passive_subdomains.txt) unique subdomains from passive enumeration"

    # Active enumeration if requested
    if [ "$ACTIVE" = true ]; then
        echo "[+] Starting active enumeration..."

        # Amass active
        log_verbose "Running Amass active scan..."
        amass enum -active -d $DOMAIN -config ~/.config/amass/config.ini | anew tmp/amass_active.txt

        # DNS brute forcing with puredns
        log_verbose "Running DNS brute forcing with puredns..."
        puredns bruteforce /usr/share/seclists/Discovery/DNS/dns-Jhaddix.txt $DOMAIN -r /usr/share/seclists/Miscellaneous/dns-resolvers.txt | anew tmp/puredns.txt

        # Combine active results
        cat tmp/amass_active.txt tmp/puredns.txt | anew all_active_subdomains.txt
        echo "[+] Found $(wc -l < all_active_subdomains.txt) unique subdomains from active enumeration"

        # Combine all results
        cat all_passive_subdomains.txt all_active_subdomains.txt | sort -u > all_subdomains.txt
    else
        mv all_passive_subdomains.txt all_subdomains.txt
    fi

    # DNS resolution and service detection
    echo "[+] Resolving and probing discovered subdomains..."
    
    # Resolve domains
    log_verbose "Running DNSx..."
    cat all_subdomains.txt | dnsx -silent -a -aaaa -cname -ns -txt -ptr -mx -soa -resp | anew dns_records.txt

    # Probe for live hosts
    log_verbose "Running httpx..."
    cat all_subdomains.txt | httpx -silent -title -status-code -tech-detect -server -ip -cdn -timeout 5 | anew "$OUTPUT_FILE"

    # Optional: Run Nuclei for vulnerability scanning
    if [ "$ACTIVE" = true ]; then
        echo "[+] Running basic vulnerability scan with Nuclei..."
        cat "$OUTPUT_FILE" | cut -d' ' -f1 | nuclei -silent -severity low,medium,high,critical -o nuclei_results.txt
    fi

    # Clean up temporary files
    if [ "$VERBOSE" != true ]; then
        rm -rf tmp/
    fi

    echo "[+] Enumeration completed! Results saved in:"
    echo "    - All subdomains: all_subdomains.txt"
    echo "    - DNS records: dns_records.txt"
    echo "    - Live hosts with details: $OUTPUT_FILE"
    if [ "$ACTIVE" = true ]; then
        echo "    - Vulnerability scan results: nuclei_results.txt"
    fi
}

# Call the main function
subdf
