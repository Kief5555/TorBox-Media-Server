#!/usr/bin/env bash

# Shared test utilities for TorBox Media Server test suites
# Source this file from individual test files.

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

passed=0
failed=0

pass() { echo -e "${GREEN}[PASS]${NC} $1"; passed=$((passed + 1)); }
fail() { echo -e "${RED}[FAIL]${NC} $1"; failed=$((failed + 1)); }

# Mask API key for display (show first/last 4 chars)
mask_key() {
    local k="$1"
    if [[ ${#k} -gt 4 ]]; then
        echo "${k:0:4}...${k: -4}"
    else
        echo "$k"
    fi
}

# Generate a deterministic-length API key (32-char hex)
generate_api_key() {
    local key=""
    if key=$(openssl rand -hex 16 2>/dev/null); then
        :
    elif key=$(xxd -p -l 16 /dev/urandom 2>/dev/null); then
        :
    elif key=$(od -An -tx1 -N16 /dev/urandom 2>/dev/null | tr -d ' \t\n'); then
        :
    elif key=$(head -c 16 /dev/urandom 2>/dev/null | od -An -tx1 | tr -d ' \t\n'); then
        :
    else
        echo ""
        return 1
    fi
    key=$(echo "$key" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-f0-9' | head -c 32)
    if [[ ${#key} -ne 32 ]]; then
        echo ""
        return 1
    fi
    echo "$key"
}

print_summary() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${GREEN}$passed passed${NC}  ${RED}$failed failed${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    if [[ $failed -eq 0 ]]; then
        echo -e "\n${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "\n${RED}$failed test(s) failed.${NC}"
        return 1
    fi
}
