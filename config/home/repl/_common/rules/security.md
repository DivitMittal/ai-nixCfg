# Security Rules

## Secrets
- NEVER commit secrets, API keys, passwords, or tokens
- Use agenix/ragenix for encrypted secrets
- Check `.env` files are in `.gitignore`
- Audit file permissions for sensitive data

## Code
- Validate all external input
- Use parameterized queries (no string interpolation for commands)
- Prefer allowlists over denylists
- Log security events but never log secrets
