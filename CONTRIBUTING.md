# Contributing Guidelines

We welcome contributions to the Microsoft Intune Remediation Scripts project! This document provides guidelines for contributing to this repository.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

## How to Contribute

### Reporting Issues

- Search existing issues before creating a new one
- Use clear, descriptive titles
- Provide detailed reproduction steps
- Include relevant system information

### Submitting Scripts

1. **Fork the repository**
2. **Create a feature branch**
3. **Follow naming conventions**:
   - Detection scripts: `[category]-[description]-detection.ps1`
   - Remediation scripts: `[category]-[description]-remediation.ps1`

### Script Standards

#### Code Quality
- Use PowerShell best practices
- Include proper error handling
- Add comprehensive comments
- Follow consistent formatting

#### Testing Requirements
- Test in isolated environment first
- Validate on multiple Windows versions
- Document testing procedures
- Include expected outcomes

#### Documentation
- Add clear script descriptions
- Document parameters and variables
- Include usage examples
- Update relevant README sections

### Pull Request Process

1. **Create descriptive PR title**
2. **Fill out PR template completely**
3. **Link related issues**
4. **Request reviews from maintainers**
5. **Address feedback promptly**

## Security Considerations

- Never include credentials or secrets
- Follow principle of least privilege
- Validate all inputs
- Consider potential security impacts

## Getting Help

- Check existing documentation
- Search closed issues
- Create new issue with questions
- Join community discussions

Thank you for contributing!
