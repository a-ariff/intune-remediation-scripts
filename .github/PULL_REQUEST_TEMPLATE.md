# Pull Request

## Description

<!-- Provide a brief description of the changes in this PR -->

## Type of Change

<!-- Mark the relevant option with an 'x' -->

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Script improvement
- [ ] Performance enhancement
- [ ] Security fix

## Changes Made

<!-- List the specific changes made in this PR -->

-
-
-

## Related Issue

<!-- Link to the related issue if applicable -->

Fixes #(issue number)

## Testing

<!-- Describe how you tested your changes -->

- [ ] Tested locally with PowerShell 5.1
- [ ] Tested locally with PowerShell 7.x
- [ ] Tested with `-WhatIf` parameter
- [ ] Tested in Intune environment
- [ ] PowerShell Script Analyzer passes with no errors
- [ ] All existing tests pass

### Test Environment

- **OS**: <!-- e.g., Windows 10/11, macOS, Linux -->
- **PowerShell Version**: <!-- e.g., 5.1, 7.4 -->
- **Intune Version**: <!-- if applicable -->

## Checklist

<!-- Mark completed items with an 'x' -->

- [ ] My code follows the [PowerShell style guidelines](https://poshcode.gitbooks.io/powershell-practice-and-style/)
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings from PowerShell Script Analyzer
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published

## Script-Specific Checklist (if applicable)

- [ ] Detection script returns correct exit codes (0 = compliant, 1 = needs remediation)
- [ ] Remediation script returns correct exit codes (0 = success, 1 = failure)
- [ ] Script supports `-WhatIf` parameter (remediation scripts)
- [ ] Script includes proper error handling
- [ ] Script uses `Write-Information` for logging
- [ ] Script includes a README.md with usage instructions
- [ ] Script does not use `Set-ExecutionPolicy`
- [ ] Script does not contain hardcoded credentials or sensitive data

## Screenshots (if applicable)

<!-- Add screenshots to help explain your changes -->

## Additional Notes

<!-- Any additional information or context -->

## Reviewer Guidelines

- Verify that scripts follow PowerShell best practices
- Check for security concerns
- Ensure documentation is clear and complete
- Test scripts in a safe environment before approving

---

**Thank you for contributing to this project!**
