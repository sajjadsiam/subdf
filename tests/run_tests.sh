#!/bin/bash

# Test suite for SubdomainFury
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TEST_DOMAIN="example.com"
TEST_GITHUB_TOKEN="your_test_token"
TOTAL_TESTS=0
PASSED_TESTS=0

# Function to run a test
run_test() {
    local test_name=$1
    local test_command=$2
    
    echo -e "\n${YELLOW}Running test: $test_name${NC}"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if eval "$test_command"; then
        echo -e "${GREEN}✓ Test passed: $test_name${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ Test failed: $test_name${NC}"
    fi
}

# Test dependency installation
test_dependencies() {
    run_test "Check required tools installation" "bash ../install.sh"
}

# Test basic functionality
test_basic_functionality() {
    run_test "Basic subdomain enumeration" "../subdf.sh -d $TEST_DOMAIN -o test_output.txt -t $TEST_GITHUB_TOKEN"
    run_test "Output file creation" "[ -f test_output.txt ]"
    run_test "Report generation" "[ -f report.txt ]"
}

# Test passive enumeration
test_passive_enumeration() {
    run_test "Subfinder execution" "subfinder -d $TEST_DOMAIN -silent"
    run_test "Findomain execution" "findomain -t $TEST_DOMAIN -q"
    run_test "Assetfinder execution" "assetfinder --subs-only $TEST_DOMAIN"
}

# Test active enumeration
test_active_enumeration() {
    run_test "Active enumeration with amass" "../subdf.sh -d $TEST_DOMAIN -o test_active.txt -t $TEST_GITHUB_TOKEN -a"
    run_test "FFUF execution" "ffuf -u https://FUZZ.$TEST_DOMAIN -w /usr/share/wordlists/seclists/Discovery/DNS/namelist.txt -mc 200,301,302 -c"
}

# Test JavaScript analysis
test_js_analysis() {
    run_test "JavaScript file discovery" "../subdf.sh -d $TEST_DOMAIN -o test_js.txt -t $TEST_GITHUB_TOKEN -js"
    run_test "JS analysis output" "[ -d js-analysis ]"
}

# Test screenshot functionality
test_screenshots() {
    run_test "Screenshot capture" "../subdf.sh -d $TEST_DOMAIN -o test_screenshots.txt -t $TEST_GITHUB_TOKEN -sc"
    run_test "Screenshot directory creation" "[ -d screenshots ]"
}

# Test parameter discovery
test_parameter_discovery() {
    run_test "Parameter discovery" "../subdf.sh -d $TEST_DOMAIN -o test_params.txt -t $TEST_GITHUB_TOKEN -p"
    run_test "Parameter output" "[ -d parameters ]"
}

# Run all tests
echo "Starting SubdomainFury test suite..."
mkdir -p test_results

test_dependencies
test_basic_functionality
test_passive_enumeration
test_active_enumeration
test_js_analysis
test_screenshots
test_parameter_discovery

# Print summary
echo -e "\n${YELLOW}Test Summary:${NC}"
echo -e "Total tests: $TOTAL_TESTS"
echo -e "Passed tests: $PASSED_TESTS"
echo -e "Failed tests: $((TOTAL_TESTS - PASSED_TESTS))"

# Calculate success rate
SUCCESS_RATE=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
echo -e "Success rate: $SUCCESS_RATE%"

if [ $TOTAL_TESTS -eq $PASSED_TESTS ]; then
    echo -e "${GREEN}All tests passed successfully!${NC}"
else
    echo -e "${RED}Some tests failed. Please check the output above.${NC}"
    exit 1
fi