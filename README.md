# engineer-workspace

APM dependency workspace for AI skills used in troubleshooting by Platform Support Engineers.

## Overview

This repository manages [APM](https://github.com/microsoft/apm) dependencies for AI-powered troubleshooting skills. It serves as the central workspace for Platform Support Engineers to access and maintain diagnostic tooling.

## Usage

Get Context7 API Token

Export env variable for token:

```sh
export CONTEXT7_API_KEY="..."
```

Install apm:

```sh
curl -sSL https://aka.ms/apm-unix | sh
```

Test it works:

```sh
# TODO
```

If it show error like this:

```txt
curl: /usr/local/lib/apm/_internal/libssl.so.3: version `OPENSSL_3.2.0' not found (required by /lib64/libcurl.so.4)
```

Install `uv`, and configure alias for apm:

```sh
pip install uv
alias apm='uv tool run --python 3.12 --from apm-cli apm'
```

Install dependencies:

```sh
apm install
```

## Quick Setup (New!)

For a complete automated setup, use the `install.sh` script:

```bash
# Local usage after git clone
chmod +x install.sh
./install.sh

# Or via curl (specify your AI agent)
curl -sSL https://raw.githubusercontent.com/your-username/repo/main/install.sh | sh -s -- --agent=codex

# Or with environment variable
AI_AGENT=codex ./install.sh

# One-liner for quick setup
curl -sSL https://raw.githubusercontent.com/your-username/repo/main/install.sh | sh

The script will:
1. Install uv package manager for Python
2. Install nvm and Node.js 22 (for MCP servers)
3. Install apm-cli via uv
4. Set up alias: `apm='uv tool run --python 3.12 --from apm-cli apm'`
5. Run `apm install --runtime <AI_AGENT>`
6. Attempt to start your AI agent

Supported AI Agents: see <https://microsoft.github.io/apm/integrations/runtime-compatibility/#overview>

