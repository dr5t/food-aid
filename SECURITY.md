# 🛡️ Security Policy

The Food Aid team takes the security of our software and the data it manages very seriously. 

## 🟢 Supported Versions

We provide security updates and patches for the following versions:

| Version | Status             | End of Life |
| ------- | ------------------ | ----------- |
| 2.x.x   | :white_check_mark: | Active      |
| 1.x.x   | :x:                | Deprecated  |

## 🚨 Reporting a Vulnerability

We strongly encourage responsible disclosure of security vulnerabilities. **Please do not report security vulnerabilities through public GitHub issues.**

If you believe you have found a security vulnerability in Food Aid, please report it to us immediately via email to the project maintainers. 

### What to Include in Your Report:
- A detailed description of the vulnerability.
- Steps to reproduce the issue.
- Potential impact and an assessment of the severity.
- Any proof-of-concept (PoC) code or screenshots.

### Our Commitment:
- We will acknowledge receipt of your vulnerability report within 48 hours.
- We will investigate the issue and determine its validity and severity.
- If verified, we will work on a patch and notify you when it is resolved.
- We will credit you (if desired) in our release notes for responsibly disclosing the vulnerability.

## 🔐 Security Architecture & Best Practices

To maintain a secure environment, Food Aid implements the following measures:

1. **Role-Based Access Control (RBAC):**
   Users are assigned specific roles (Admin, Donor, NGO, Logistics). Firestore security rules strictly enforce read/write permissions based on these roles, ensuring users can only access data relevant to their authorization level.

2. **Secure Authentication:**
   We leverage Firebase Authentication. Sensitive data such as passwords are encrypted and managed securely by Google Cloud.

3. **Data Validation:**
   Both client-side (Flutter forms) and server-side (Firestore Rules) validation are employed to prevent malicious data injections.

4. **Environment Variables:**
   Sensitive configuration parameters (like API keys for Google Maps) are managed via `.env` files and are explicitly excluded from version control via `.gitignore`.
