# Repository Guidelines

## Project Structure & Module Organization
This repository packages a Palworld dedicated server as a Docker image. Top-level runtime assets are [`Dockerfile`](G:\SnailCode\github\palworld-server\Dockerfile), [`docker-compose.yml`](G:\SnailCode\github\palworld-server\docker-compose.yml), and helper entry scripts such as [`start-server.sh`](G:\SnailCode\github\palworld-server\start-server.sh) and [`stop-server.sh`](G:\SnailCode\github\palworld-server\stop-server.sh). Container logic lives in [`scripts/`](G:\SnailCode\github\palworld-server\scripts): `entrypoint.sh` coordinates startup, `start.sh` builds Palworld launch arguments, `update.sh` handles SteamCMD updates, and `status.sh` reports server state. CI publishing is defined in [`.github/workflows/docker-ghcr.yml`](G:\SnailCode\github\palworld-server\.github\workflows\docker-ghcr.yml).

## Build, Test, and Development Commands
Use Docker-first workflows:

- `docker compose up -d` or `docker-compose up -d`: start the server container locally.
- `docker compose down`: stop and remove the local stack.
- `docker compose logs -f palworld-server`: follow runtime logs.
- `docker build -t palworld-server .`: build the image manually.
- `./start-server.sh` and `./stop-server.sh`: wrapper scripts for common local operations.
- `docker exec -it palworld-server /scripts/status.sh`: inspect the running container.

## Coding Style & Naming Conventions
Shell scripts are Bash (`#!/bin/bash`) and currently use lowercase file names with verb-oriented names such as `start.sh` and `setup_config.sh`. Match the existing style: 4-space indentation inside conditionals, uppercase environment variables (`SERVER_DIR`, `MAX_PLAYERS`), and direct, operational comments. Keep changes POSIX-friendly where practical, but do not rewrite existing Bash patterns unless needed for correctness.

## Testing Guidelines
There is no automated test suite in this repository today. Validate changes by building the image, starting the Compose stack, and checking container behavior through logs and `/scripts/status.sh`. For script changes, verify the affected path explicitly, for example: startup flow, update checks, and configuration bootstrap. Document manual test steps in the PR when behavior changes.

## Commit & Pull Request Guidelines
Recent history uses short, focused commit subjects in either Chinese or English, for example `修改自动化流程` and `Update docker-ghcr.yml`. Keep commit messages brief and specific to one change. PRs should include a concise summary, note any config or environment-variable changes, and describe manual verification steps. Include log snippets or screenshots only when they clarify an operational issue.

## Security & Configuration Tips
Do not commit live server data, credentials, or machine-specific IPs. Keep user-tunable settings in `docker-compose.yml` environment variables and treat the mounted `./palworld` directory as local runtime state, not source.
