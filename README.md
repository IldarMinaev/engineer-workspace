# engineer-workspace

APM dependency workspace for AI skills used in troubleshooting by Platform Support Engineers.

## Overview

This repository manages [APM](https://github.com/microsoft/apm) dependencies for AI-powered troubleshooting skills. It serves as the central workspace for Platform Support Engineers to access and maintain diagnostic tooling.

## Usage

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

## Structure

- `apm.yml` — package manifest defining skill dependencies
- `apm_modules/` — installed dependencies (not committed)
