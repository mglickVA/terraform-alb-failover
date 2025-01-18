# Contributing to Terraform ALB Failover

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing.

## Development Environment Setup

1. Fork and clone the repository
2. Install dependencies:
```bash
make install
```
3. Initialize Terraform:
```bash
make init
```

## Branch Naming Convention

Use the following format for branch names:
```
devin/{timestamp}-{descriptive-slug}
```
Example:
```
devin/1234567890-add-custom-health-check
```

## Development Workflow

1. Create a new branch from main
2. Make your changes
3. Run tests:
```bash
make test
```
4. Ensure all tests pass before submitting PR
5. Update documentation if necessary

## Testing Requirements

- All new features must include tests
- Run the full test suite before submitting PR:
```bash
make test          # Run all tests
make test-unit     # Run unit tests
make test-integration  # Run integration tests
```

## Code Style and Formatting

### Terraform
- Use consistent naming conventions
- Format code using `terraform fmt`
- Follow [HashiCorp Style Conventions](https://www.terraform.io/docs/language/syntax/style.html)

### Python
- Follow PEP 8 style guide
- Use type hints where possible
- Format code using your IDE's Python formatter
- Maximum line length: 100 characters

## Pull Request Process

1. Update the README.md with details of changes if applicable
2. Update the version numbers following [Semantic Versioning](https://semver.org/)
3. Include the Devin run link in your PR description
4. Ensure all tests pass
5. Update documentation as needed

## Commit Messages

Follow the conventional commits specification:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation only
- style: Code style changes
- refactor: Code changes that neither fix bugs nor add features
- test: Test-related changes
- chore: Maintenance tasks

Example:
```
feat(alb): add custom health check endpoint

- Added new health check endpoint
- Updated documentation
- Added tests

Closes #123
```

## Code Review Process

1. All PRs require at least one review
2. Address review comments promptly
3. Maintain a constructive dialogue
4. Update PR based on feedback

## Testing Guidelines

### Unit Tests
- Test individual components in isolation
- Mock AWS resources using tftest
- Verify resource configurations
- Test error conditions

### Integration Tests
- Test complete infrastructure deployment
- Verify component interactions
- Test failover scenarios
- Validate health check behavior

## Documentation

- Update README.md for user-facing changes
- Update inline documentation for code changes
- Include examples for new features
- Document any new environment variables

## Environment Variables

Required for testing:
```bash
AWS_ACCESS_KEY_ID=mock_access_key
AWS_SECRET_ACCESS_KEY=mock_secret_key
AWS_SESSION_TOKEN=mock_session_token
AWS_DEFAULT_REGION=us-east-1
TF_VAR_environment=test
TF_VAR_project_name=test-project
TF_VAR_domain_name=example.com
TF_VAR_health_check_path=/health/status.json
```

## Getting Help

- Create an issue for bugs
- Use PR discussions for implementation questions
- Tag maintainers for urgent issues

## License

By contributing, you agree that your contributions will be licensed under the project's MIT License.
