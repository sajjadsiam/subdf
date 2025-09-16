#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Formatting
BOLD='\033[1m'
UNDERLINE='\033[4m'

# Function to print section headers
print_section() {
    echo -e "\n${BLUE}${BOLD}═══════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}              $1              ${NC}"
    echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════${NC}\n"
}

print_subsection() {
    echo -e "\n${YELLOW}${BOLD}[+] $1...${NC}"
}

# Print welcome message
echo -e "\n${GREEN}${BOLD}${UNDERLINE}Welcome to SubdomainFury Installation${NC}"
print_section "Initializing Installation Process"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to retry commands with timeout
retry_command() {
    local cmd="$1"
    local retries=3
    local timeout=30
    local count=0
    
    until $cmd || [ $count -eq $retries ]; do
        echo -e "${YELLOW}Command failed, retrying ($((count+1))/$retries)...${NC}"
        count=$((count+1))
        sleep 5
    done
    
    if [ $count -eq $retries ]; then
        echo -e "${RED}Failed after $retries attempts${NC}"
        return 1
    fi
    return 0
}

# Function to install Go if not present
install_go() {
    if ! command_exists go; then
        echo -e "${YELLOW}Installing Go...${NC}"
        export TIMEOUT=30
        if retry_command "wget --timeout=30 https://golang.org/dl/go1.19.linux-amd64.tar.gz"; then
            sudo tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz
            rm go1.19.linux-amd64.tar.gz
            echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
            echo 'export GOPATH=$HOME/go' >> ~/.bashrc
            echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
            source ~/.bashrc
        else
            echo -e "${RED}Failed to download Go. Please check your internet connection.${NC}"
            exit 1
        fi
    fi
}

# Install basic requirements
print_section "System Requirements"
print_subsection "Updating system packages"
sudo apt update
print_subsection "Installing basic dependencies"
sudo apt install -y git curl wget python3 python3-pip jq

# Install Go
print_section "Go Installation"
install_go

# Install Go-based tools
print_section "Go-based Tools Installation"
print_subsection "Installing reconnaissance tools"
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install -v github.com/tomnomnom/assetfinder@latest
go install -v github.com/tomnomnom/anew@latest
go install -v github.com/bp0lr/gauplus@latest
go install -v github.com/d3mondev/puredns/v2@latest
go install -v github.com/lc/gau/v2/cmd/gau@latest
go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest
go install -v github.com/ffuf/ffuf/v2@latest
go install -v github.com/tomnomnom/waybackurls@latest
go install -v github.com/jaeles-project/gospider@latest
go install -v github.com/haccer/subjack@latest
go install -v github.com/tomnomnom/unfurl@latest
go install -v github.com/projectdiscovery/asnmap/cmd/asnmap@latest
go install -v github.com/sw33tLie/sns/cmd/sns@latest
go install -v github.com/deletescape/goop@latest
go install -v github.com/hakluke/hakrawler@latest
go install -v github.com/003random/getJS@latest
go install -v github.com/lc/subjs@latest
go install -v github.com/hahwul/urldedupe@latest
go install -v github.com/tomnomnom/gf@latest

# Install other tools
print_section "Additional Tools Installation"
print_subsection "Installing system packages"
sudo apt install -y amass findomain aquatone chromium-browser
print_subsection "Installing Python packages"
pip3 install arjun dirsearch
print_subsection "Installing Node.js packages"
npm install -g wappalyzer

# Install github-subdomains
print_section "GitHub Subdomain Tools Installation"
print_subsection "Setting up github-subdomains"
git clone https://github.com/gwen001/github-subdomains
cd github-subdomains
pip3 install -r requirements.txt
sudo ln -s "$(pwd)/github-subdomains.py" /usr/local/bin/github-subdomains
cd ..
rm -rf github-subdomains

# Final check
print_section "Installation Verification"
print_subsection "Verifying installed tools"

tools=("amass" "subfinder" "assetfinder" "findomain" "github-subdomains" "httpx" "chaos" "gau" "gauplus" "nuclei" "dnsx" "anew" "puredns")

echo -e "\n${BOLD}Tool Status:${NC}"
echo -e "${BLUE}════════════════════════════════════${NC}"
for tool in "${tools[@]}"; do
    if command_exists "$tool"; then
        printf "${GREEN}%-25s %s${NC}\n" "$tool" "✓ installed"
    else
        printf "${RED}%-25s %s${NC}\n" "$tool" "✗ failed"
    fi
done
echo -e "${BLUE}════════════════════════════════════${NC}\n"

print_section "Installation Complete"
echo -e "${GREEN}${BOLD}✓ SubdomainFury has been successfully installed!${NC}"
echo -e "${YELLOW}${BOLD}▶ Action Required:${NC} Run '${CYAN}source ~/.bashrc${NC}' to update your PATH"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"