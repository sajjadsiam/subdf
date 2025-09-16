#!/bin/bash

# Set system optimizations
if [ "$(id -u)" -eq 0 ]; then
    # Increase file descriptor limits
    ulimit -n 65535 2>/dev/null || true
    # Increase process limits
    ulimit -u 2048 2>/dev/null || true
    # Optimize network settings
    sysctl -w net.ipv4.tcp_max_syn_backlog=8192 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_fin_timeout=30 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_keepalive_time=1200 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_max_tw_buckets=1440000 >/dev/null 2>&1 || true
    sysctl -w net.ipv4.tcp_timestamps=1 >/dev/null 2>&1 || true
fi

# Set script error handling
set -e              # Exit on error
set -o pipefail     # Exit if any command in a pipe fails

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

# Function to check internet connectivity
check_internet() {
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        echo -e "${RED}No internet connection. Please check your connection and try again.${NC}"
        return 1
    fi
    return 0
}

# Function to handle errors
handle_error() {
    local error_msg="$1"
    echo -e "${RED}Error: $error_msg${NC}"
    exit 1
}

# Function to retry commands with timeout and better error handling
retry_command() {
    local cmd="$1"
    local tool_name="$2"
    local retries=3
    local timeout=30
    local count=0
    local wait_time=5
    
    until eval "$cmd" || [ $count -eq $retries ]; do
        echo -e "${YELLOW}[$tool_name] Command failed, retrying in ${wait_time}s ($(($count+1))/$retries)...${NC}"
        count=$((count+1))
        wait_time=$((wait_time * 2))  # Exponential backoff
        sleep $wait_time
    done
    
    if [ $count -eq $retries ]; then
        echo -e "${RED}[$tool_name] Failed after $retries attempts${NC}"
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

# Set Go environment variables for faster installation
export GO111MODULE=on
export GOPROXY=direct,https://proxy.golang.org
export GOSUMDB=off
export GONOSUMDB=github.com/*

# Install Go-based tools with error handling and parallel installation
print_section "Go-based Tools Installation"
print_subsection "Installing reconnaissance tools"

# Function to install massdns (dependency for puredns)
install_massdns() {
    echo -e "${CYAN}Installing massdns (required for puredns)...${NC}"
    if ! command -v massdns &>/dev/null; then
        git clone https://github.com/blechschmidt/massdns.git
        cd massdns
        make
        sudo make install
        cd ..
        rm -rf massdns
    else
        echo -e "${GREEN}massdns is already installed${NC}"
    fi
}

# Define tools to install
declare -A tools=(
    ["subfinder"]="github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    ["httpx"]="github.com/projectdiscovery/httpx/cmd/httpx@latest"
    ["dnsx"]="github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
    ["nuclei"]="github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest"
    ["assetfinder"]="github.com/tomnomnom/assetfinder@latest"
    ["anew"]="github.com/tomnomnom/anew@latest"
    ["gauplus"]="github.com/bp0lr/gauplus@latest"
    ["gau"]="github.com/lc/gau/v2/cmd/gau@latest"
    ["chaos"]="github.com/projectdiscovery/chaos-client/cmd/chaos@latest"
    ["katana"]="github.com/projectdiscovery/katana/cmd/katana@latest"
    ["ffuf"]="github.com/ffuf/ffuf/v2@latest"
    ["waybackurls"]="github.com/tomnomnom/waybackurls@latest"
)

# Install puredns separately due to dependencies
install_puredns() {
    echo -e "${CYAN}Setting up puredns...${NC}"
    install_massdns
    GO111MODULE=on go install github.com/d3mondev/puredns/v2@latest
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Successfully installed puredns${NC}"
    else
        echo -e "${RED}Failed to install puredns${NC}"
        return 1
    fi
}

# Function to test tool functionality
test_tool() {
    local tool_name=$1
    case $tool_name in
        "subfinder")
            $tool_name -version >/dev/null 2>&1
            ;;
        "httpx")
            $tool_name -version >/dev/null 2>&1
            ;;
        "dnsx")
            $tool_name -version >/dev/null 2>&1
            ;;
        "nuclei")
            $tool_name -version >/dev/null 2>&1
            ;;
        "assetfinder")
            $tool_name -h >/dev/null 2>&1
            ;;
        "anew")
            echo "test" | $tool_name >/dev/null 2>&1
            ;;
        "gauplus")
            $tool_name -version >/dev/null 2>&1
            ;;
        "puredns")
            $tool_name -version >/dev/null 2>&1
            ;;
        "gau")
            $tool_name -version >/dev/null 2>&1
            ;;
        "chaos")
            $tool_name -version >/dev/null 2>&1
            ;;
        "katana")
            $tool_name -version >/dev/null 2>&1
            ;;
        "ffuf")
            $tool_name -V >/dev/null 2>&1
            ;;
        "waybackurls")
            $tool_name -h >/dev/null 2>&1
            ;;
        *)
            return 0
            ;;
    esac
    return $?
}

# Function to install a single tool
install_tool() {
    local tool_name=$1
    local tool_path=$2
    echo -e "${CYAN}Installing $tool_name...${NC}"
    
    # Try installation
    if ! retry_command "go install -v $tool_path" "$tool_name"; then
        echo -e "${RED}Failed to install $tool_name${NC}"
        return 1
    fi
    
    # Verify installation
    if ! command -v "$tool_name" >/dev/null 2>&1; then
        echo -e "${RED}$tool_name not found in PATH after installation${NC}"
        return 1
    fi
    
    # Test tool functionality
    echo -e "${CYAN}Testing $tool_name functionality...${NC}"
    if ! test_tool "$tool_name"; then
        echo -e "${RED}$tool_name failed functionality test${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Successfully installed and verified $tool_name${NC}"
    return 0
}

# Install tools with progress tracking
total_tools=${#tools[@]}
current_tool=0
failed_tools=()

for tool_name in "${!tools[@]}"; do
    current_tool=$((current_tool + 1))
    echo -e "\n${YELLOW}[$current_tool/$total_tools] Installing $tool_name${NC}"
    
    if ! install_tool "$tool_name" "${tools[$tool_name]}"; then
        failed_tools+=("$tool_name")
    fi
done

# Report installation results
if [ ${#failed_tools[@]} -eq 0 ]; then
    echo -e "\n${GREEN}${BOLD}All tools installed successfully!${NC}"
    
    # Setup environment optimizations
    cat >> ~/.bashrc << 'EOF'

# SubdomainFury optimizations
export HTTPX_THREADS=50
export HTTPX_TIMEOUT=10
export GAU_THREADS=50
export SUBFINDER_THREADS=50
export GOMAXPROCS=$(nproc)
export GO111MODULE=on
export GODEBUG=netdns=go

# Increase file descriptor limit
ulimit -n 65535 2>/dev/null || true

# Tool-specific rate limits
export HTTPX_RATE_LIMIT=150
export GAU_RATE_LIMIT=150
EOF

    # Create configuration directories
    mkdir -p ~/.config/subfinder
    mkdir -p ~/.config/nuclei
    mkdir -p ~/.config/amass
    
    echo -e "${GREEN}${BOLD}✓ Environment configured successfully!${NC}"
    echo -e "${YELLOW}Please run 'source ~/.bashrc' to apply the changes${NC}"
else
    echo -e "\n${RED}${BOLD}The following tools failed to install:${NC}"
    for tool in "${failed_tools[@]}"; do
        echo -e "${RED}- $tool${NC}"
    done
    echo -e "\n${YELLOW}Please try installing these tools manually or check your internet connection.${NC}"
fi

# Final verification
print_section "Final Verification"
echo -e "${CYAN}Performing comprehensive verification...${NC}"

# Verify critical components
verify_components() {
    local all_good=true
    local total_checks=0
    local passed_checks=0
    
    print_subsection "System Requirements"
    
    # Check system resources
    echo -ne "${CYAN}Checking system resources...${NC}"
    total_checks=$((total_checks + 1))
    if [ $(nproc) -ge 2 ] && [ $(free -m | awk '/Mem:/ {print $2}') -ge 2048 ]; then
        echo -e "${GREEN} ✓${NC}"
        passed_checks=$((passed_checks + 1))
    else
        echo -e "${YELLOW} ⚠ (Limited resources may affect performance)${NC}"
        passed_checks=$((passed_checks + 1))
    fi
    
    # Check Go installation
    echo -ne "${CYAN}Checking Go installation...${NC}"
    total_checks=$((total_checks + 1))
    if go version &>/dev/null; then
        echo -e "${GREEN} ✓ $(go version)${NC}"
        passed_checks=$((passed_checks + 1))
    else
        echo -e "${RED} ✗${NC}"
        all_good=false
    fi
    
    print_subsection "Tool Verification"
    
    # Check each tool with detailed testing
    for tool in "${!tools[@]}"; do
        total_checks=$((total_checks + 3))  # Installation, PATH, and functionality checks
        
        echo -e "\n${CYAN}Checking $tool:${NC}"
        
        # Check if tool is installed
        echo -ne "  ├─ Installation: "
        if command -v "$tool" &>/dev/null; then
            echo -e "${GREEN}✓${NC}"
            passed_checks=$((passed_checks + 1))
        else
            echo -e "${RED}✗${NC}"
            all_good=false
            continue
        fi
        
        # Check if tool is in PATH
        echo -ne "  ├─ PATH: "
        if which "$tool" &>/dev/null; then
            echo -e "${GREEN}✓ ($(which "$tool"))${NC}"
            passed_checks=$((passed_checks + 1))
        else
            echo -e "${RED}✗${NC}"
            all_good=false
            continue
        fi
        
        # Test tool functionality
        echo -ne "  └─ Functionality: "
        if test_tool "$tool"; then
            echo -e "${GREEN}✓${NC}"
            passed_checks=$((passed_checks + 1))
        else
            echo -e "${RED}✗${NC}"
            all_good=false
        fi
    done
    
    print_subsection "Environment Verification"
    
    # Check environment variables
    echo -e "${CYAN}Checking environment variables:${NC}"
    total_checks=$((total_checks + 4))  # We're checking 4 environment variables
    
    # Check GOPATH
    echo -ne "  ├─ GOPATH: "
    if [ ! -z "$GOPATH" ]; then
        echo -e "${GREEN}✓ ($GOPATH)${NC}"
        passed_checks=$((passed_checks + 1))
    else
        echo -e "${RED}✗${NC}"
        export GOPATH=$HOME/go
        echo -e "    └─ ${YELLOW}Fixed: Set GOPATH to $GOPATH${NC}"
    fi
    
    # Check GOROOT
    echo -ne "  ├─ GOROOT: "
    if [ ! -z "$GOROOT" ]; then
        echo -e "${GREEN}✓ ($GOROOT)${NC}"
        passed_checks=$((passed_checks + 1))
    else
        GOROOT=$(go env GOROOT)
        export GOROOT
        echo -e "${YELLOW}Fixed: Set to $GOROOT${NC}"
    fi
    
    # Check PATH includes GOPATH/bin
    echo -ne "  ├─ PATH includes GOPATH/bin: "
    if [[ ":$PATH:" == *":$GOPATH/bin:"* ]]; then
        echo -e "${GREEN}✓${NC}"
        passed_checks=$((passed_checks + 1))
    else
        echo -e "${RED}✗${NC}"
        export PATH="$PATH:$GOPATH/bin"
        echo -e "    └─ ${YELLOW}Fixed: Added GOPATH/bin to PATH${NC}"
    fi
    
    # Check if Go is properly installed
    echo -ne "  └─ Go installation: "
    if go version >/dev/null 2>&1; then
        echo -e "${GREEN}✓ ($(go version))${NC}"
        passed_checks=$((passed_checks + 1))
    else
        echo -e "${RED}✗${NC}"
        all_good=false
    fi
    
    # Calculate success percentage
    local success_rate=$(( (passed_checks * 100) / total_checks ))
    
    echo -e "\n${CYAN}Verification Summary:${NC}"
    echo -e "├─ Total Checks: $total_checks"
    echo -e "├─ Passed: $passed_checks"
    echo -e "└─ Success Rate: $success_rate%"
    
    return $all_good
}

# Function to repair tool installation
repair_tool() {
    local tool_name=$1
    local tool_path=$2
    
    echo -e "${YELLOW}Attempting to repair $tool_name...${NC}"
    
    # Remove existing binary
    echo -e "${CYAN}Removing existing installation...${NC}"
    rm -f "$(which "$tool_name" 2>/dev/null)" 2>/dev/null
    
    # Clean Go cache globally
    echo -e "${CYAN}Cleaning Go cache...${NC}"
    go clean -cache -modcache
    
    # For puredns specific fix
    if [ "$tool_name" = "puredns" ]; then
        echo -e "${CYAN}Installing puredns dependencies...${NC}"
        # Ensure massdns is installed
        if ! command -v massdns &>/dev/null; then
            echo -e "${YELLOW}Installing massdns...${NC}"
            git clone https://github.com/blechschmidt/massdns.git
            cd massdns
            make
            sudo make install
            cd ..
            rm -rf massdns
        fi
    fi
    
    # For gau specific fix
    if [ "$tool_name" = "gau" ]; then
        echo -e "${CYAN}Installing gau with specific version...${NC}"
        GO111MODULE=on go install -v github.com/lc/gau/v2/cmd/gau@latest
        return $?
    fi
    
    # Reinstall tool with verbose output
    echo -e "${CYAN}Reinstalling $tool_name...${NC}"
    GO111MODULE=on go install -v "$tool_path"
    
    # Verify installation
    if command -v "$tool_name" >/dev/null 2>&1 && test_tool "$tool_name"; then
        echo -e "${GREEN}Successfully repaired $tool_name${NC}"
        return 0
    else
        echo -e "${RED}Failed to repair $tool_name${NC}"
        return 1
    fi
}

# Verify and repair if needed
if verify_components; then
    echo -e "\n${GREEN}${BOLD}Installation completed successfully!${NC}"
    echo -e "${CYAN}All tools are properly installed and functioning.${NC}"
else
    echo -e "\n${YELLOW}${BOLD}Some issues were detected. Attempting repairs...${NC}"
    
    for tool_name in "${!tools[@]}"; do
        if ! command -v "$tool_name" &>/dev/null || ! test_tool "$tool_name"; then
            repair_tool "$tool_name" "${tools[$tool_name]}"
        fi
    done
    
    # Final verification after repairs
    if verify_components; then
        echo -e "\n${GREEN}${BOLD}All issues have been resolved!${NC}"
        echo -e "${CYAN}SubdomainFury is ready to use.${NC}"
    else
        echo -e "\n${RED}${BOLD}Some issues could not be resolved automatically.${NC}"
        echo -e "${CYAN}Please try the following:${NC}"
        echo -e "1. Run 'source ~/.bashrc'"
        echo -e "2. Check your Go installation with 'go version'"
        echo -e "3. Ensure GOPATH is set correctly"
        echo -e "4. Try running './install.sh' again"
        echo -e "5. If problems persist, please report the issue"
    fi
fi

# Create a test file to verify all tools
cat > test_tools.sh << 'EOF'
#!/bin/bash
# Tool testing script
echo "Testing all installed tools..."

tools=(subfinder httpx dnsx nuclei assetfinder anew gauplus puredns gau chaos katana ffuf waybackurls)

for tool in "${tools[@]}"; do
    echo -n "Testing $tool... "
    if command -v "$tool" >/dev/null 2>&1; then
        case $tool in
            "subfinder"|"httpx"|"dnsx"|"nuclei"|"gauplus"|"puredns"|"gau"|"chaos"|"katana")
                if $tool -version >/dev/null 2>&1; then
                    echo -e "\e[32m✓\e[0m"
                else
                    echo -e "\e[31m✗\e[0m"
                fi
                ;;
            *)
                if $tool -h >/dev/null 2>&1; then
                    echo -e "\e[32m✓\e[0m"
                else
                    echo -e "\e[31m✗\e[0m"
                fi
                ;;
        esac
    else
        echo -e "\e[31m✗ (not found)\e[0m"
    fi
done
EOF

chmod +x test_tools.sh
echo -e "\n${CYAN}A test script has been created. Run './test_tools.sh' to verify all tools at any time.${NC}"
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