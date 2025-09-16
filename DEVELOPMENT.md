# SubdomainFury Development Guide

## Project Structure

```
subdomainfury/
├── subdf.sh              # Main script
├── install.sh            # Installation script
├── README.md            # Documentation
├── CONTRIBUTING.md      # Contributing guidelines
├── LICENSE             # MIT License
├── tests/              # Test suite
│   └── run_tests.sh    # Test runner
└── assets/             # Project assets
    └── logo.png        # Project logo
```

## Development Guidelines

### 1. Code Style
- Use 4 spaces for indentation
- Use meaningful variable names
- Add comments for complex operations
- Follow shell script best practices
- Use functions for modular code

### 2. Feature Implementation Process
1. Create a new branch for the feature
2. Write tests first (TDD approach)
3. Implement the feature
4. Run the test suite
5. Update documentation
6. Submit pull request

### 3. Testing
Before submitting any changes:
1. Run `./tests/run_tests.sh`
2. Ensure all tests pass
3. Add new tests for new features
4. Test on different environments

### 4. Performance Considerations
- Use parallel processing where possible
- Implement proper rate limiting
- Clean up temporary files
- Optimize resource usage
- Handle large inputs efficiently

### 5. Security Best Practices
- Validate all inputs
- Handle API keys securely
- Implement rate limiting
- Follow principle of least privilege
- Handle errors gracefully

### 6. Documentation
Update the following when making changes:
- README.md
- Command help text
- Code comments
- CONTRIBUTING.md if needed

### 7. Error Handling
- Provide meaningful error messages
- Log errors appropriately
- Implement proper exit codes
- Handle edge cases

### 8. Feature Integration Checklist
- [ ] Write tests
- [ ] Implement feature
- [ ] Update documentation
- [ ] Add error handling
- [ ] Optimize performance
- [ ] Security review
- [ ] Test in different environments

### 9. Contribution Process
1. Fork the repository
2. Create feature branch
3. Make changes
4. Run tests
5. Update documentation
6. Submit pull request

### 10. Release Process
1. Update version number
2. Run full test suite
3. Update changelog
4. Create release notes
5. Tag release
6. Update documentation

## Tool Integration Guidelines

### Adding New Tools

When adding new reconnaissance tools:

1. Update install.sh:
```bash
# Add installation command
go install -v github.com/author/tool@latest
```

2. Add tool check in subdf.sh:
```bash
if ! command -v tool &> /dev/null; then
    echo "tool not found"
    exit 1
fi
```

3. Implement in main script:
```bash
run_tool() {
    log "Running tool..."
    tool -d "$DOMAIN" [options] > "output/tool.txt"
}
```

### API Integration

When adding new API integrations:

1. Add API key parameter:
```bash
-k) API_KEY=$OPTARG ;;
```

2. Validate API key:
```bash
if [ -n "$API_KEY" ]; then
    validate_api_key "$API_KEY"
fi
```

3. Implement API call:
```bash
curl -H "Authorization: $API_KEY" "https://api.example.com"
```

## Debugging Tips

1. Enable verbose mode:
```bash
./subdf.sh -d domain.com -v
```

2. Check logs:
```bash
tail -f "$WORKING_DIR/debug.log"
```

3. Common issues:
- Rate limiting
- API key validation
- Tool dependencies
- Permission issues

## Performance Optimization

1. Parallel execution:
```bash
tool1 "$DOMAIN" > output1.txt &
tool2 "$DOMAIN" > output2.txt &
wait
```

2. Resource management:
```bash
# Clean up temp files
trap 'rm -rf "$TEMP_DIR"' EXIT
```

3. Rate limiting:
```bash
sleep 1  # Add delay between requests
```