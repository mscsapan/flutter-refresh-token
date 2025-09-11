#!/bin/bash

# Flutter Test Runner Script
# This script provides easy commands to run different types of tests

echo "🧪 Flutter Template - Test Runner"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Main menu
show_menu() {
    echo ""
    echo "Available test options:"
    echo "1) Run all unit tests"
    echo "2) Run all widget tests" 
    echo "3) Run all integration tests"
    echo "4) Run specific test file"
    echo "5) Run tests with coverage"
    echo "6) Generate mock files"
    echo "7) Run all tests (unit + widget + integration)"
    echo "8) Analyze code"
    echo "9) Exit"
    echo ""
}

# Run unit tests
run_unit_tests() {
    print_status "Running unit tests..."
    if flutter test test/unit/; then
        print_success "Unit tests completed successfully!"
    else
        print_error "Unit tests failed!"
    fi
}

# Run widget tests
run_widget_tests() {
    print_status "Running widget tests..."
    if flutter test test/widget/; then
        print_success "Widget tests completed successfully!"
    else
        print_warning "No widget tests found or tests failed!"
    fi
}

# Run integration tests
run_integration_tests() {
    print_status "Running integration tests..."
    if flutter test integration_test/; then
        print_success "Integration tests completed successfully!"
    else
        print_warning "No integration tests found or tests failed!"
    fi
}

# Run specific test file
run_specific_test() {
    echo "Enter the path to the test file (e.g., test/unit/core/utils/validators_test.dart):"
    read -r test_file
    
    if [ -f "$test_file" ]; then
        print_status "Running $test_file..."
        flutter test "$test_file"
    else
        print_error "Test file not found: $test_file"
    fi
}

# Run tests with coverage
run_tests_with_coverage() {
    print_status "Running tests with coverage..."
    flutter test --coverage
    
    if command -v genhtml &> /dev/null; then
        print_status "Generating HTML coverage report..."
        genhtml coverage/lcov.info -o coverage/html
        print_success "Coverage report generated at coverage/html/index.html"
        
        if command -v open &> /dev/null; then
            open coverage/html/index.html
        elif command -v xdg-open &> /dev/null; then
            xdg-open coverage/html/index.html
        else
            print_warning "Please open coverage/html/index.html in your browser"
        fi
    else
        print_warning "genhtml not found. Install lcov to generate HTML reports:"
        print_warning "  macOS: brew install lcov"
        print_warning "  Ubuntu: sudo apt-get install lcov"
    fi
}

# Generate mock files
generate_mocks() {
    print_status "Generating mock files with build_runner..."
    flutter packages pub run build_runner build --delete-conflicting-outputs
    print_success "Mock files generated successfully!"
}

# Run all tests
run_all_tests() {
    print_status "Running all tests (unit + widget + integration)..."
    
    echo "📱 Running unit tests..."
    flutter test test/unit/ || print_warning "Some unit tests failed"
    
    echo "🎨 Running widget tests..."
    flutter test test/widget/ || print_warning "Some widget tests failed"
    
    echo "🔄 Running integration tests..."
    flutter test integration_test/ || print_warning "Some integration tests failed"
    
    print_success "All tests completed!"
}

# Analyze code
analyze_code() {
    print_status "Analyzing code..."
    flutter analyze
    print_success "Code analysis completed!"
}

# Main loop
while true; do
    show_menu
    echo "Enter your choice (1-9):"
    read -r choice
    
    case $choice in
        1) run_unit_tests ;;
        2) run_widget_tests ;;
        3) run_integration_tests ;;
        4) run_specific_test ;;
        5) run_tests_with_coverage ;;
        6) generate_mocks ;;
        7) run_all_tests ;;
        8) analyze_code ;;
        9) 
            print_success "Happy testing! 🧪"
            exit 0
            ;;
        *)
            print_error "Invalid option. Please choose 1-9."
            ;;
    esac
    
    echo ""
    echo "Press Enter to continue..."
    read -r
done
