# engineer-workspace

AI-powered troubleshooting skills for Platform Support Engineers, managed via [APM](https://github.com/microsoft/apm).

## Quick Start

**Prerequisites:** `kubectl`, `go`

```sh
git clone <repo-url> && cd engineer-workspace
./install.sh
```

The script installs all dependencies (`uv`, `apm-cli`, `tscli`) and prompts for your AI agent (`copilot` | `codex` | `vscode` | `claude`).

Non-interactive:

```sh
./install.sh --agent=claude
```

### Installation demo

[![asciicast](https://asciinema.org/a/KkXX81S98qFUd22f.svg)](https://asciinema.org/a/KkXX81S98qFUd22f)

## Skills in action

[![asciicast](https://asciinema.org/a/Ck6PnU9SigWTrOAG.svg)](https://asciinema.org/a/Ck6PnU9SigWTrOAG)

## What gets installed

`install.sh` performs:

1. Installs [uv](https://github.com/astral-sh/uv) (Python package manager)
2. Installs [tscli](https://github.com/vlsi/troubleshooting-cli) (troubleshooting MCP server)
3. Installs `apm-cli` via uv and configures `apm` alias
4. Runs `apm compile` + `apm install` for the selected runtime
5. Starts the AI agent

Skills deployed via APM include: PostgreSQL diagnostics (health, performance, logs, backups, connections, storage), Patroni reference, pgskipper operator checks, DBaaS API/architecture, common troubleshooting methodology, Kubernetes context, and more. Full list is defined in `apm.yml` / `apm.lock.yaml`.

## Manual setup

If `install.sh` doesn't fit your environment:

```sh
# Install apm-cli
uv tool install --python 3.12 apm-cli --force
alias apm='uv tool run --python 3.12 --from apm-cli apm'

# Install skills
apm install --runtime <agent> --force
apm compile -t <agent>

```

Supported runtimes: [APM runtime compatibility](https://microsoft.github.io/apm/integrations/runtime-compatibility/#overview)

