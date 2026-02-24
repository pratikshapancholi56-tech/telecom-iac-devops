#!/bin/bash

set -e

echo "=========================================="
echo "Telecom System Test Script"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Test configuration
BASE_URL="${1:-http://localhost:5000}"
FAILED_TESTS=0
PASSED_TESTS=0

print_info "Testing application at: $BASE_URL"
echo ""

# Test 1: Check if application is running
print_info "Test 1: Checking if application is accessible..."
if curl -f -s "$BASE_URL" > /dev/null; then
    print_success "Application is accessible"
    ((PASSED_TESTS++))
else
    print_error "Application is not accessible"
    ((FAILED_TESTS++))
    exit 1
fi

# Test 2: Check Airtel plans API
print_info "Test 2: Testing Airtel plans API..."
RESPONSE=$(curl -s "$BASE_URL/api/plans/airtel")
if echo "$RESPONSE" | grep -q "air_1"; then
    print_success "Airtel plans API working"
    ((PASSED_TESTS++))
else
    print_error "Airtel plans API failed"
    ((FAILED_TESTS++))
fi

# Test 3: Check Jio plans API
print_info "Test 3: Testing Jio plans API..."
RESPONSE=$(curl -s "$BASE_URL/api/plans/jio")
if echo "$RESPONSE" | grep -q "jio_1"; then
    print_success "Jio plans API working"
    ((PASSED_TESTS++))
else
    print_error "Jio plans API failed"
    ((FAILED_TESTS++))
fi

# Test 4: Check Vi plans API
print_info "Test 4: Testing Vi plans API..."
RESPONSE=$(curl -s "$BASE_URL/api/plans/vi")
if echo "$RESPONSE" | grep -q "vi_1"; then
    print_success "Vi plans API working"
    ((PASSED_TESTS++))
else
    print_error "Vi plans API failed"
    ((FAILED_TESTS++))
fi

# Test 5: Check BSNL plans API
print_info "Test 5: Testing BSNL plans API..."
RESPONSE=$(curl -s "$BASE_URL/api/plans/bsnl")
if echo "$RESPONSE" | grep -q "bsnl_1"; then
    print_success "BSNL plans API working"
    ((PASSED_TESTS++))
else
    print_error "BSNL plans API failed"
    ((FAILED_TESTS++))
fi

# Test 6: Test recharge API with valid data
print_info "Test 6: Testing recharge API with valid data..."
RESPONSE=$(curl -s -X POST "$BASE_URL/api/recharge" \
    -H "Content-Type: application/json" \
    -d '{"mobile":"9876543210","operator":"airtel","plan_id":"air_1"}')

if echo "$RESPONSE" | grep -q "success.*true"; then
    print_success "Recharge API working with valid data"
    ((PASSED_TESTS++))
else
    print_error "Recharge API failed with valid data"
    echo "Response: $RESPONSE"
    ((FAILED_TESTS++))
fi

# Test 7: Test recharge API with invalid mobile
print_info "Test 7: Testing recharge API with invalid mobile..."
RESPONSE=$(curl -s -X POST "$BASE_URL/api/recharge" \
    -H "Content-Type: application/json" \
    -d '{"mobile":"123","operator":"airtel","plan_id":"air_1"}')

if echo "$RESPONSE" | grep -q "Invalid mobile number"; then
    print_success "Recharge API correctly validates mobile number"
    ((PASSED_TESTS++))
else
    print_error "Recharge API validation failed"
    ((FAILED_TESTS++))
fi

# Test 8: Test recharge API with invalid operator
print_info "Test 8: Testing recharge API with invalid operator..."
RESPONSE=$(curl -s -X POST "$BASE_URL/api/recharge" \
    -H "Content-Type: application/json" \
    -d '{"mobile":"9876543210","operator":"invalid","plan_id":"air_1"}')

if echo "$RESPONSE" | grep -q "Invalid operator"; then
    print_success "Recharge API correctly validates operator"
    ((PASSED_TESTS++))
else
    print_error "Recharge API operator validation failed"
    ((FAILED_TESTS++))
fi

# Test 9: Check transactions API
print_info "Test 9: Testing transactions API..."
RESPONSE=$(curl -s "$BASE_URL/api/transactions")
if [ -n "$RESPONSE" ]; then
    print_success "Transactions API working"
    ((PASSED_TESTS++))
else
    print_error "Transactions API failed"
    ((FAILED_TESTS++))
fi

# Test 10: Verify HTML page loads
print_info "Test 10: Testing HTML page load..."
RESPONSE=$(curl -s "$BASE_URL")
if echo "$RESPONSE" | grep -q "Indian Telecom Recharge"; then
    print_success "HTML page loads correctly"
    ((PASSED_TESTS++))
else
    print_error "HTML page failed to load"
    ((FAILED_TESTS++))
fi

# Summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Passed: $PASSED_TESTS"
echo "Failed: $FAILED_TESTS"
echo "Total: $((PASSED_TESTS + FAILED_TESTS))"

if [ $FAILED_TESTS -eq 0 ]; then
    print_success "All tests passed!"
    exit 0
else
    print_error "Some tests failed!"
    exit 1
fi
