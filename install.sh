#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Detect AI Agent from environment variable, command line argument, or prompt user
detect_ai_agent() {
  local ai_agent=""

  # Check environment variable (suggested name: AI_AGENT)
  if [[ -n "${AI_AGENT}" ]]; then
    ai_agent="${AI_AGENT}"
    log_info "Using AI Agent from environment variable AI_AGENT: ${ai_agent}"
  fi

  # Check command line argument (--agent or -a)
  for arg in "$@"; do
    if [[ "${arg}" =~ ^--agent= ]] || [[ "${arg}" =~ ^-a= ]]; then
      ai_agent="${arg#*=}"
      log_info "Using AI Agent from command line argument: ${ai_agent}"
      break
    elif [[ "${arg}" == "--agent" ]] || [[ "${arg}" == "-a" ]]; then
      # Next argument should be the agent name
      for next_arg in "$@"; do
        if [[ "${next_arg}" != "${arg}" ]]; then
          ai_agent="${next_arg}"
          log_info "Using AI Agent from command line argument: ${ai_agent}"
          break 2
        fi
      done
    fi
  done

  # If still not set, prompt user
  if [[ -z "${ai_agent}" ]]; then
    echo -e "\n${BLUE}Select your AI Agent:${NC}" >&2
    echo "1) copilot" >&2
    echo "2) codex" >&2
    echo "3) vscode" >&2
    echo "4) claude" >&2
    echo "" >&2
    echo "These are the supported runtimes from 'apm install --help'" >&2
    echo "" >&2

    while true; do
      read -p "Enter choice (1-4) or agent name: " choice
      case "${choice}" in
      1 | copilot)
        ai_agent="copilot"
        break
        ;;
      2 | codex)
        ai_agent="codex"
        break
        ;;
      3 | vscode)
        ai_agent="vscode"
        break
        ;;
      4 | claude)
        mkdir -p .claude
        ai_agent="claude"
        break
        ;;
      copilot | codex | vscode | claude)
        [[ "${choice}" == "claude" ]] && mkdir -p .claude
        ai_agent="${choice}"
        break
        ;;
      *)
        log_error "Invalid choice. Please enter 1-3 or one of: copilot, codex, vscode, claude"
        ;;
      esac
    done
  fi

  echo "${ai_agent}"
}

# Install uv package manager if not installed
install_uv() {
  if command -v uv &>/dev/null; then
    log_success "uv is already installed"
  else
    log_info "Installing uv package manager..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    if command -v uv &>/dev/null; then
      log_success "uv installed successfully"
    else
      log_error "Failed to install uv"
      exit 1
    fi
  fi
}

# Install nvm and Node.js 22 if needed
install_nodejs_22() {
  # Check if Node.js 22 is already available
  if command -v node &>/dev/null; then
    local node_version
    node_version=$(node --version 2>/dev/null || echo "")
    if [[ "${node_version}" =~ ^v22\. ]]; then
      log_success "Node.js 22 is already installed (${node_version})"
      return 0
    fi
  fi

  # Install nvm if not installed
  if [[ ! -d "${HOME}/.nvm" ]] && [[ ! -f "${HOME}/.nvm/nvm.sh" ]]; then
    log_info "Installing nvm (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

    # Load nvm for current shell
    export NVM_DIR="${HOME}/.nvm"
    [ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"
    [ -s "${NVM_DIR}/bash_completion" ] && \. "${NVM_DIR}/bash_completion"

    # Add to shell rc for future shells
    if ! grep -q "NVM_DIR" ~/.bashrc 2>/dev/null; then
      echo 'export NVM_DIR="$HOME/.nvm"' >>~/.bashrc
      echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >>~/.bashrc
      echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >>~/.bashrc
    fi

    # Also add to .bashrc.d/apm directory
    local bashrc_dir="${HOME}/.bashrc.d"
    local apm_bashrc="${bashrc_dir}/apm"
    mkdir -p "${bashrc_dir}"
    echo 'export NVM_DIR="$HOME/.nvm"' >"${apm_bashrc}"
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >>"${apm_bashrc}"
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >>"${apm_bashrc}"
  else
    log_info "nvm is already installed"
  fi

  # Load nvm
  export NVM_DIR="${HOME}/.nvm"
  [ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"
  [ -s "${NVM_DIR}/bash_completion" ] && \. "${NVM_DIR}/bash_completion"

  # Install Node.js 22
  log_info "Installing Node.js 22 via nvm..."
  nvm install 22
  nvm use 22

  log_success "Node.js 22 installed successfully"
}

# Install apm-cli via uv and set up alias
install_apm_and_alias() {
  # Install apm-cli if not already installed via uv
  log_info "Installing apm-cli via uv..."
  uv tool install --python 3.12 apm-cli --force

  # Create .bashrc.d/apm directory if it doesn't exist
  local bashrc_dir="${HOME}/.bashrc.d"
  local apm_bashrc="${bashrc_dir}/apm"
  mkdir -p "${bashrc_dir}"

  # Set alias in .bashrc.d/apm
  log_info "Setting up apm alias in ${apm_bashrc}..."
  if ! grep -q "alias apm=" "${apm_bashrc}" 2>/dev/null; then
    echo "alias apm='uv tool run --python 3.12 --from apm-cli apm'" >>"${apm_bashrc}"
  fi

  # Also add to .bashrc if not already there (for immediate use)
  if ! grep -q "alias apm=" ~/.bashrc 2>/dev/null; then
    echo "alias apm='uv tool run --python 3.12 --from apm-cli apm'" >>~/.bashrc
  fi

  # Make alias available in current shell
  alias apm='uv tool run --python 3.12 --from apm-cli apm'

  log_success "apm alias configured"
}

# Run apm install with the specified runtime
run_apm_install() {
  local ai_agent="$1"

  log_info "Running apm install for runtime: ${ai_agent}..."

  # Use the alias we just created
  if command -v apm &>/dev/null; then
    apm install --runtime "${ai_agent}"
  else
    # Fallback to uv tool run
    uv tool run --python 3.12 --from apm-cli apm install --runtime "${ai_agent}"
  fi

  if [[ $? -eq 0 ]]; then
    log_success "apm install completed successfully"
  else
    log_error "apm install failed"
    exit 1
  fi
}

# Run the AI agent
run_ai_agent() {
  local ai_agent="$1"

  log_info "Starting AI Agent: ${ai_agent}"
  log_warning "Note: This script assumes the AI agent command is the same as the runtime name"
  log_warning "You may need to adjust this based on your specific setup"

  # Based on the agent name, run the appropriate command
  case "${ai_agent}" in
  copilot)
    log_info "To use GitHub Copilot, ensure it's installed and configured in your editor"
    ;;
  codex)
    log_info "To use OpenAI Codex, ensure you have API access and proper configuration"
    ;;
  vscode)
    log_info "Starting VS Code with APM configuration..."
    # Try to start VS Code if installed
    if command -v code &>/dev/null; then
      code .
    else
      log_warning "VS Code command 'code' not found in PATH"
      log_info "Please install VS Code or use 'open .' (macOS) or another method"
    fi
    ;;
  claude)
    log_info "To use Claude, ensure you have API access and proper configuration"
    claude
    ;;
  *)
    log_warning "Unknown AI Agent: ${ai_agent}"
    log_info "Please start your AI agent manually"
    ;;
  esac
}

# Main execution
main() {
  echo -e "\n${BLUE}=== APM Workspace Setup Script ===${NC}\n"

  # Detect AI Agent
  AI_AGENT=$(detect_ai_agent "$@")
  log_info "Selected AI Agent: ${AI_AGENT}"

  # Install dependencies
  install_uv
  install_nodejs_22
  install_apm_and_alias

  # Run apm install
  run_apm_install "${AI_AGENT}"

  # Run AI Agent
  run_ai_agent "${AI_AGENT}"

  echo -e "\n${GREEN}=== Setup Complete! ===${NC}"
  echo "Summary:"
  echo "  - AI Agent: ${AI_AGENT}"
  echo "  - uv: Installed"
  echo "  - Node.js 22: Installed via nvm"
  echo "  - apm alias: Configured in ~/.bashrc.d/apm"
  echo "  - apm install: Completed for runtime ${AI_AGENT}"
  echo ""
  echo "To use the 'apm' alias in future terminal sessions, run:"
  echo "  source ~/.bashrc.d/apm"
  echo "Or restart your terminal"
  echo ""
  echo "Environment variable option:"
  echo "  export AI_AGENT=\"${AI_AGENT}\""
  echo "  ./install.sh"
  echo ""
  echo "Command line option:"
  echo "  ./install.sh --agent=${AI_AGENT}"
}

# Show usage information
show_usage() {
  echo -e "${BLUE}Usage:${NC}"
  echo "  ./install.sh [OPTIONS]"
  echo ""
  echo "${BLUE}Options:${NC}"
  echo "  --agent=<agent>, -a=<agent>    Specify AI Agent (copilot, codex, vscode, claude)"
  echo "  --help, -h                     Show this help message"
  echo ""
  echo "${BLUE}Environment Variables:${NC}"
  echo "  AI_AGENT                       Set AI Agent (copilot, codex, vscode, claude)"
  echo ""
  echo "${BLUE}Examples:${NC}"
  echo "  ./install.sh                    # Interactive mode"
  echo "  ./install.sh --agent=copilot    # Non-interactive"
  echo "  AI_AGENT=codex ./install.sh     # Using env var"
  echo "  curl -sSL https://raw.githubusercontent.com/.../install.sh | sh -s -- --agent=vscode"
  echo ""
  echo "${BLUE}Supported AI Agents (from 'apm install --help'):${NC}"
  echo "  copilot, codex, vscode"
}

# Check for help option
for arg in "$@"; do
  case "${arg}" in
  --help | -h)
    show_usage
    exit 0
    ;;
  esac
done

# Run main function with all arguments
main "$@"
