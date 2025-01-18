.PHONY: install test test-unit test-integration clean clean-all init localstack-up localstack-down

# Variables
PYTHON := python3
PIP := $(PYTHON) -m pip
TEST_DIR := tests
PYTEST := $(PYTHON) -m pytest
TF := terraform
TIMEOUT := 60
UNIT_TIMEOUT := 30
INTEGRATION_TIMEOUT := 120

# Colors for output
YELLOW := \033[1;33m
GREEN := \033[1;32m
RED := \033[1;31m
NC := \033[0m

# Environment variables for testing
export AWS_ACCESS_KEY_ID := mock_access_key
export AWS_SECRET_ACCESS_KEY := mock_secret_key
export AWS_SESSION_TOKEN := mock_session_token
export AWS_DEFAULT_REGION := us-east-1
export TF_VAR_environment := test
export TF_VAR_project_name := test-project
export TF_VAR_domain_name := example.com
export TF_VAR_health_check_path := /health/status.json

# Install dependencies
install:
	@echo -e "$(YELLOW)Installing dependencies...$(NC)"
	$(PIP) install -r $(TEST_DIR)/requirements.txt
	@echo -e "$(GREEN)Dependencies installed successfully$(NC)"

# Initialize terraform
init:
	@echo -e "$(YELLOW)Initializing Terraform...$(NC)"
	$(TF) init -backend=false
	@echo -e "$(GREEN)Terraform initialized successfully$(NC)"

# Run all tests
test: install init
	@echo -e "$(YELLOW)Running all tests...$(NC)"
	$(PYTEST) $(TEST_DIR) -v --timeout=$(TIMEOUT) --log-cli-level=INFO || (echo -e "$(RED)Tests failed$(NC)" && exit 1)
	@echo -e "$(GREEN)All tests completed successfully$(NC)"

# Run unit tests only
test-unit: install init
	@echo -e "$(YELLOW)Running unit tests...$(NC)"
	$(PYTEST) $(TEST_DIR)/unit -v --timeout=$(UNIT_TIMEOUT) --log-cli-level=INFO || (echo -e "$(RED)Unit tests failed$(NC)" && exit 1)
	@echo -e "$(GREEN)Unit tests completed successfully$(NC)"

# Run integration tests only
test-integration: install init
	@echo -e "$(YELLOW)Running integration tests...$(NC)"
	$(PYTEST) $(TEST_DIR)/integration -v --timeout=$(INTEGRATION_TIMEOUT) --log-cli-level=INFO || (echo -e "$(RED)Integration tests failed$(NC)" && exit 1)
	@echo -e "$(GREEN)Integration tests completed successfully$(NC)"

# Clean up test artifacts
clean:
	@echo -e "$(YELLOW)Cleaning test artifacts...$(NC)"
	rm -rf .pytest_cache
	rm -rf __pycache__
	rm -rf $(TEST_DIR)/__pycache__
	rm -rf $(TEST_DIR)/unit/__pycache__
	rm -rf $(TEST_DIR)/integration/__pycache__
	@echo -e "$(GREEN)Test artifacts cleaned successfully$(NC)"

# Clean up all artifacts including Terraform
clean-all: clean
	@echo -e "$(YELLOW)Cleaning all artifacts...$(NC)"
	rm -rf .terraform
	rm -rf terraform.tfstate*
	rm -rf .terraform.lock.hcl
	find . -type d -name ".terraform" -exec rm -rf {} +
	@echo -e "$(GREEN)All artifacts cleaned successfully$(NC)"

# Gitpod workspace setup
create-workspace:
	@echo -e "$(YELLOW)Setting up Gitpod workspace...$(NC)"
	$(PIP) install --upgrade pip
	$(PIP) install -r $(TEST_DIR)/requirements.txt
	$(TF) init -backend=false
	@echo -e "$(GREEN)Workspace setup completed successfully$(NC)"

# Start Gitpod workspace
start-workspace: create-workspace
	@echo -e "$(YELLOW)Starting Gitpod workspace...$(NC)"
	$(TF) fmt -recursive
	$(PYTEST) $(TEST_DIR) -v --setup-show --log-cli-level=INFO
	@echo -e "$(GREEN)Workspace started successfully$(NC)"

# LocalStack commands
localstack-up:
	@echo -e "$(YELLOW)Starting LocalStack...$(NC)"
	docker-compose up -d
	@echo -e "$(GREEN)LocalStack started successfully$(NC)"

localstack-down:
	@echo -e "$(YELLOW)Stopping LocalStack...$(NC)"
	docker-compose down
	@echo -e "$(GREEN)LocalStack stopped successfully$(NC)"
