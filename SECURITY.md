# Security Policy

## Supported Versions

We actively support and provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability within this repository, please follow these steps:

### 1. Do NOT create a public issue

To avoid exposing the vulnerability to potential attackers, please do not create a public GitHub issue for security-related concerns.

### 2. Contact Us Directly

Please report security vulnerabilities by emailing:

- **Email**: [security@aglobaltec.com](mailto:security@aglobaltec.com)
- **Subject**: Security Vulnerability Report - Intune Remediation Scripts

### 3. Include the Following Information

When reporting a vulnerability, please include:

- A clear description of the vulnerability
- Steps to reproduce the issue
- Potential impact and affected components
- Any suggested fixes or mitigations
- Your contact information for follow-up questions

### 4. Response Timeline

We take security seriously and will respond to your report within:

- **Initial acknowledgment**: Within 24 hours
- **Initial assessment**: Within 72 hours
- **Status update**: Weekly until resolution

### 5. Responsible Disclosure

We follow responsible disclosure practices:

- We will work with you to understand and validate the reported vulnerability
- We will develop and test a fix
- We will coordinate the disclosure timeline with you
- We will credit you for the discovery (unless you prefer to remain anonymous)

## Security Best Practices

When using these scripts in your environment:

### For Administrators

- **Test thoroughly**: Always test scripts in a non-production environment first
- **Review code**: Examine script content before deployment
- **Principle of least privilege**: Run scripts with minimum required permissions
- **Monitor execution**: Use Intune reporting to track script execution and results
- **Keep updated**: Regularly check for script updates and security patches

### For Contributors

- **Secure coding**: Follow PowerShell security best practices
- **Input validation**: Validate all user inputs and parameters
- **No secrets**: Never hardcode credentials, API keys, or sensitive data
- **Error handling**: Implement proper error handling to prevent information disclosure
- **Code review**: All contributions undergo security review

## Security Considerations for PowerShell Scripts

### Execution Policy

- Scripts should respect PowerShell execution policies
- Consider signing scripts in enterprise environments
- Use appropriate execution context (user vs. system)

### Data Protection

- Encrypt sensitive data in transit and at rest
- Use secure communication protocols
- Implement proper logging without exposing sensitive information

### Access Control

- Implement proper authentication and authorization
- Use service accounts with minimal required permissions
- Regularly rotate service account credentials

## Known Security Considerations

### PowerShell Remoting

Some scripts may require PowerShell remoting. Ensure:

- WinRM is securely configured
- Use HTTPS for remote connections
- Implement proper authentication mechanisms

### Registry Modifications

Scripts that modify the registry:

- Backup registry keys before modification
- Validate registry paths and values
- Implement rollback mechanisms

### File System Operations

Scripts that interact with the file system:

- Validate file paths to prevent directory traversal
- Use appropriate file permissions
- Implement proper error handling for file operations

## Security Updates

Security updates will be:

- Released as soon as possible after identification
- Documented in the CHANGELOG.md
- Announced through GitHub releases
- Tagged with security-related labels

## Compliance

This repository follows:

- Microsoft Security Development Lifecycle (SDL) principles
- PowerShell security best practices
- Industry standard security practices for enterprise IT management

## Contact Information

For security-related questions or concerns:

- **Primary Contact**: [security@aglobaltec.com](mailto:security@aglobaltec.com)
- **Backup Contact**: [support@aglobaltec.com](mailto:support@aglobaltec.com)

## Acknowledgments

We thank the security research community for their responsible disclosure of vulnerabilities and their contributions to improving the security of this project.

---

*This security policy is subject to change. Please check back regularly for updates.*
