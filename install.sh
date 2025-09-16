#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installing required tools for SubdomainFury...${NC}"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Go if not present
install_go() {
    if ! command_exists go; then
        echo -e "${YELLOW}Installing Go...${NC}"
        wget https://golang.org/dl/go1.19.linux-amd64.tar.gz
        sudo tar -C /usr/local -xzf go1.19.linux-amd64.tar.gz
        rm go1.19.linux-amd64.tar.gz
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        echo 'export GOPATH=$HOME/go' >> ~/.bashrc
        echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
        source ~/.bashrc
    fi
}

# Install basic requirements
echo -e "${YELLOW}Installing basic requirements...${NC}"
sudo apt update
sudo apt install -y git curl wget python3 python3-pip jq

# Install Go
install_go

# Install Go-based tools
echo -e "${YELLOW}Installing Go-based tools...${NC}"
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
go install -v github.com/tomnomnom/assetfinder@latest
go install -v github.com/tomnomnom/anew@latest
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
echo -e "${YELLOW}Installing additional tools...${NC}"
sudo apt install -y amass findomain aquatone chromium-browser
pip3 install arjun dirsearch
npm install -g wappalyzer

# Install github-subdomains
echo -e "${YELLOW}Installing github-subdomains...${NC}"
git clone https://github.com/gwen001/github-subdomains
cd github-subdomains
pip3 install -r requirements.txt
sudo ln -s "$(pwd)/github-subdomains.py" /usr/local/bin/github-subdomains
cd ..
rm -rf github-subdomains

# Final check
echo -e "${GREEN}Installation completed!${NC}"
echo -e "${YELLOW}Checking installed tools...${NC}"

tools=("amass" "subfinder" "assetfinder" "findomain" "github-subdomains" "httpx" "chaos" "gau" "nuclei" "dnsx" "anew" "puredns")

for tool in "${tools[@]}"; do
    if command_exists "$tool"; then
        echo -e "${GREEN}✓ $tool installed successfully${NC}"
    else
        echo -e "${RED}✗ $tool installation failed${NC}"
    fi
done

echo -e "\n${GREEN}SubdomainFury is ready to use!${NC}"
echo -e "${YELLOW}Please run 'source ~/.bashrc' to update your PATH${NC}"