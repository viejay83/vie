#!/usr/bin/env bash
set -euo pipefail

INPUT="$(cat)"
COMMAND="$(echo "$INPUT" | jq -r '.tool_input.command // ""')"

block() {
  echo "Blocked by NorthSea policy: $1" >&2
  exit 2
}

case "$COMMAND" in
  *"--no-verify"*)
    block "Never use git commit --no-verify."
    ;;
  *"docker compose down"*|*"docker volume rm"*|*"docker system prune"*)
    block "Destructive Docker command requires explicit approval, rollback plan, and test step."
    ;;
  *"rm -rf /"*|*"rm -rf ~"*|*"rm -rf ."*)
    block "Dangerous deletion command."
    ;;
  *"cat .env"*|*"cat .env."*)
    block "Reading .env secrets is not allowed."
    ;;
  *"cat "*"/credentials.json"*)
    block "Reading credentials is not allowed."
    ;;
  *"find / "*)
    block "Broad root filesystem scan blocked. Use targeted path with -maxdepth."
    ;;
  *"grep -R "*" /"*)
    block "Broad root filesystem grep blocked. Use targeted path."
    ;;
esac

exit 0
