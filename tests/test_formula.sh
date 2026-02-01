#!/usr/bin/env bash
# Test runner for Salt formulas
# Applies formula states and validates using test YAML definitions

set -e
set -o pipefail

RED='\x1b[31;01m'
GREEN='\x1b[32;01m'
RESET='\x1b[0m'

pass() {
    echo -e "  ${GREEN}PASS${RESET}: $1"
}

fail() {
    echo -e "  ${RED}FAIL${RESET}: $1"
    FAILED=1
}

# Parse and run tests from a YAML file
run_tests() {
    local test_file="$1"
    local formula_name=$(echo "$test_file" | cut -d/ -f2)

    echo ""
    echo "Testing formula: $formula_name"
    echo "================================"

    # Apply the formula first
    echo "Applying state: $formula_name"
    if ! salt-call --local state.apply "$formula_name" --out=quiet 2>/dev/null; then
        # Try with state.sls if state.apply fails
        salt-call --local state.sls "$formula_name" --out=quiet 2>/dev/null || true
    fi

    # Parse the test YAML and run checks
    # Simple parser for file tests
    local current_path=""
    local in_file_block=false

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Check for file: block
        if [[ "$line" =~ ^file: ]]; then
            in_file_block=true
            continue
        fi

        # Check for path (starts with / and ends with :)
        if [[ "$in_file_block" == true && "$line" =~ ^[[:space:]]+(/[^:]+): ]]; then
            current_path="${BASH_REMATCH[1]}"
            continue
        fi

        # Check for exists: true/false
        if [[ -n "$current_path" && "$line" =~ exists:[[:space:]]*(true|false) ]]; then
            local expected="${BASH_REMATCH[1]}"
            if [[ "$expected" == "true" ]]; then
                if [[ -e "$current_path" ]]; then
                    pass "$current_path exists"
                else
                    fail "$current_path should exist but doesn't"
                fi
            else
                if [[ ! -e "$current_path" ]]; then
                    pass "$current_path does not exist (as expected)"
                else
                    fail "$current_path should not exist but does"
                fi
            fi
        fi

        # Check for is_directory: true/false
        if [[ -n "$current_path" && "$line" =~ is_directory:[[:space:]]*(true|false) ]]; then
            local expected="${BASH_REMATCH[1]}"
            if [[ "$expected" == "true" ]]; then
                if [[ -d "$current_path" ]]; then
                    pass "$current_path is a directory"
                else
                    fail "$current_path should be a directory"
                fi
            fi
        fi

        # Check for owner
        if [[ -n "$current_path" && "$line" =~ owner:[[:space:]]*([a-zA-Z0-9_-]+) ]]; then
            local expected="${BASH_REMATCH[1]}"
            if [[ -e "$current_path" ]]; then
                local actual=$(stat -c '%U' "$current_path" 2>/dev/null || stat -f '%Su' "$current_path" 2>/dev/null)
                if [[ "$actual" == "$expected" ]]; then
                    pass "$current_path owner is $expected"
                else
                    fail "$current_path owner is '$actual', expected '$expected'"
                fi
            fi
        fi

        # Check for group
        if [[ -n "$current_path" && "$line" =~ group:[[:space:]]*([a-zA-Z0-9_-]+) ]]; then
            local expected="${BASH_REMATCH[1]}"
            if [[ -e "$current_path" ]]; then
                local actual=$(stat -c '%G' "$current_path" 2>/dev/null || stat -f '%Sg' "$current_path" 2>/dev/null)
                if [[ "$actual" == "$expected" ]]; then
                    pass "$current_path group is $expected"
                else
                    fail "$current_path group is '$actual', expected '$expected'"
                fi
            fi
        fi

        # Check for mode
        if [[ -n "$current_path" && "$line" =~ mode:[[:space:]]*[\'\"]*([0-9]+)[\'\"]*  ]]; then
            local expected="${BASH_REMATCH[1]}"
            if [[ -e "$current_path" ]]; then
                local actual=$(stat -c '%a' "$current_path" 2>/dev/null || stat -f '%Lp' "$current_path" 2>/dev/null)
                # Normalize to compare (remove leading zeros)
                expected=$(echo "$expected" | sed 's/^0*//')
                actual=$(echo "$actual" | sed 's/^0*//')
                if [[ "$actual" == "$expected" ]]; then
                    pass "$current_path mode is $expected"
                else
                    fail "$current_path mode is '$actual', expected '$expected'"
                fi
            fi
        fi

    done < "$test_file"
}

# Main
FAILED=0

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <test_file.yaml> [test_file2.yaml ...]"
    exit 1
fi

for test_file in "$@"; do
    if [[ -f "$test_file" ]]; then
        run_tests "$test_file"
    else
        echo "Warning: Test file not found: $test_file"
    fi
done

echo ""
if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${RESET}"
    exit 0
else
    echo -e "${RED}Some tests failed!${RESET}"
    exit 1
fi
